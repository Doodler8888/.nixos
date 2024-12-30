{ pkgs ? import <nixpkgs> {} }:

let
  # emacsGitSrc = builtins.fetchGit {
  #   url = "https://github.com/emacs-mirror/emacs.git";
  #   ref = "master";
  # };
emacsGitSrc = pkgs.fetchFromGitHub {
  owner = "emacs-mirror";
  repo = "emacs";
  rev = "7671d50b149edd9e19c29f5fa8ee71c01e2f583d";  # to get the lates 'rev' curl -s https://api.github.com/repos/emacs-mirror/emacs/commits/master | jq -r .sha
   # To get the right hash use this value
   # "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", run in the same directory as the derivation file 
   # "nix profile install .#name-of-the-package-defined-in-flakes.nix". It will give you a correct hash.
  hash = "sha256-r5Ly1VhxTlVpgtn98MM/Ho4BI9HwQke5tDHAfbK5Hjk=";
};
in
pkgs.stdenv.mkDerivation {
  pname = "custom-emacs";
  version = "git-${builtins.substring 0 8 emacsGitSrc.rev}";

  src = emacsGitSrc;

  nativeBuildInputs = with pkgs; [
    autoconf
    automake
    pkg-config
    texinfo
    gcc
    binutils-unwrapped
  ];

  buildInputs = with pkgs; [
    gnutls
    libxml2
    ncurses
    xorg.libXaw
    Xaw3d
    cairo
    giflib
    xorg.libXpm
    libjpeg
    libpng
    librsvg
    libtiff
    libgccjit
    imagemagick
    tree-sitter
    # zlib        # Added from the guide
    # jansson     # Added from the guide
  ];

  # postPatch = pkgs.lib.concatStringsSep "\n" [
  #   ''
  #   for makefile_in in $(find . -name Makefile.in -print); do
  #     substituteInPlace $makefile_in --replace /bin/pwd pwd
  #   done
  #   substituteInPlace src/Makefile.in --replace 'RUN_TEMACS = ./temacs' 'RUN_TEMACS = env -i ./temacs'
  #   substituteInPlace lisp/international/mule-cmds.el --replace /usr/share/locale ${pkgs.gettext}/share/locale
  #   ''
  # ];

  configureFlags = [
    "--with-native-compilation=aot"
    "--with-x-toolkit=lucid"
    "--with-tree-sitter"
    "--with-gif"
    "--with-png"
    "--with-jpeg"
    "--with-rsvg"
    "--with-tiff"
    "--with-imagemagick"
    "--with-json"               # Added from the guide
  ];

  # NIX_CFLAGS_COMPILE = "-I${pkgs.libgccjit}/include/gcc-14.3.0 -I${pkgs.binutils-unwrapped}/include";

env = {
  LIBRARY_PATH = pkgs.lib.concatStringsSep ":" [
    "${pkgs.lib.getLib pkgs.libgccjit}/lib/gcc"
    "${pkgs.lib.getLib pkgs.stdenv.cc.libc}/lib"
    "${pkgs.lib.getLib pkgs.stdenv.cc.cc.lib}/lib"  # This adds libgcc_s
  ];
};

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;

  meta = with pkgs.lib; {
    description = "Custom build of GNU Emacs with Lucid toolkit";
    homepage = "https://www.gnu.org/software/emacs/";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
