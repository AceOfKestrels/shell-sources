{ lib, config, ... }:

let
    cfg = config.programs.shellSources;
in
{
    options = {
        programs.shellSources.enable = lib.mkEnableOption "enable shell kes shell sources";
    };

    config = lib.mkIf cfg.enable {
        environment.interactiveShellInit = '''';
    };
}
