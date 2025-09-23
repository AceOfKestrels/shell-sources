# shell-sources

These are the shell source files and other common settings I use.

## Installation

1. Clone the repo
2. In your `.*rc` add a `source` command to the files you want to source:

    ```sh
    source "hell/common.sh"
    source "shell/git.sh"
    ```

    The `source-all` file automatically sources all others:

    ```sh
    source "source-all.sh"
    ```

### When not using bash or zsh

The `source-all.sh` needs to know the directory it is in to source the rest of the files automatically. In bash and zsh this is detected automatically, but if you use a different shell, you must set `SHELL_SOURCES_DIR` manually:

```sh
export SHELL_SOURCES_DIR="$HOME/shell-sources"
```

## Environment

### Exclude files

`source-all.sh` by default sources all scripts in the repository. You can set `SHELL_SOURCES_IGNORE` to exclude individual files from this.

This will prevent the `git.sh` and `helper.sh` files in the `shell` directory from being sourced:

```sh
SHELL_SOURCES_IGNORE="shell/git.sh shell/helper.sh"
```

### Other settings

- `GIT_BROWSER` - The command run by the `gb` alias to open the current git repo in a browser
- `GIT_BROWSER_ARGS` - The arguments used by `gb` to open the browser
- `GIT_COMMIT_MESSAGE_MAX_LENGTH` - When the length of a commit message exceed this value, `gc` and `gac` will throw a warning
