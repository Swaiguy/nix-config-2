{
  description = "NixOS configuration of Ryan Yin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs @ {
    nixpkgs,
    nixos-hardware,
    ...
  }: {
    nixosConfigurations = {
      Computer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // {myvars.username = "kry";};
        modules = [
          {networking.hostName = "Computer";}

          ./configuration.nix

          ../modules/base.nix
          ../modules/nixos/base/i18n.nix
          ../modules/nixos/base/user-group.nix
          ../modules/nixos/base/networking.nix

          ../hosts/idols-ai/hardware-configuration.nix
          ../hosts/idols-ai/impermanence.nix
        ];
      };
    };
  };
}
