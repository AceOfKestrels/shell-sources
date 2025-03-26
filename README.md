These are the shell source files and other common settings I use. 

Clone the repo somewhere and add a `source` command to your `.shrc`/`.bashrc`/`.zshrc`/etc pointing to the file you want to add:
```
source ~/shell-sources/bash/common
source ~/shell-sources/bash/git
source ~/shell-sources/bash/files
```
The `source-all` file automatically sources all others:
```
source ~/shell-sources/source-all
```