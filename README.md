These are the bash source files and other common settings I use. 

Depending on the machine I'm on, some or all of these will be included in by `.bashrc`.
Clone the repo somewhere and add a `source` command to your `.bashrc` pointing to the file you want to add:
```
source ~/bashrc-sources/bash/common
source ~/bashrc-sources/bash/git
source ~/bashrc-sources/bash/files
```
The `source-all` file automatically sources all others:
```
source ~/bashrc-sources/source-all
```
<br>

The `settings` folder contains exported settings for other programs I use across devices.