{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11"; # for stable Vivaldi
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager }: {
        packages.x86_64-linux.emacs-from-source = 
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
        import ./emacs.nix { inherit pkgs; };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.wurfkreuz = import ./home.nix;
        }
      ];
    };
  };
}
