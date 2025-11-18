{
    lib,
    config,
    pkgs,
    ...
}:

let
    cfg = config.programs.shellSources;
in
{
    options = {
        programs.shellSources.enable = lib.mkEnableOption "enable shell kes shell sources";
    };

    config = lib.mkIf cfg.enable {
        environment.interactiveShellInit = ''
            . ${./.}/source-all.sh --packaged
        '';

        environment.systemPackages = with pkgs; [ jq ];
    };
}
