# shell-sources

These are the shell source files and other common settings I use.

## Installation

1. Clone the repo
2. In your `.*rc`:
    1. Set the `SHELL_SOURCES_DIR` variable to the directory you cloned into:

        ```sh
        export SHELL_SOURCES_DIR="$HOME/shell-sources"
        ```

    2. Add a `source` command to the files you want to source:

        ```sh
        source "$SHELL_SOURCES_DIR/shell/common"
        source "$SHELL_SOURCES_DIR/shell/git"
        source "$SHELL_SOURCES_DIR/shell/files"
        ```

        The `source-all` file automatically sources all others:

        ```sh
        source "$SHELL_SOURCES_DIR/source-all"
        ```

## Exclude Files

`source-all.sh` by default sources all scripts in the repository. You can set `SHELL_SOURCES_IGNORE` to exclude individual files from this.

This will prevent the `git.sh` and `helper.sh` files in the `shell` directory from being sourced:

```sh
SHELL_SOURCES_IGNORE="shell/git.sh shell/helper.sh"
```
