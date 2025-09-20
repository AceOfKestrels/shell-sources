{ lib, ... }:

{
    programs.shellSources.enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
    };
}
