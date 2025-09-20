{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    outputs =
        { ... }:
        {
            module = {
                imports = [ ./default.nix ];
            };
        };
}
