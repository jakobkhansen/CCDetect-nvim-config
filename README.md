# CCDetect-LSP nvim config

Pre-built Neovim config which runs CCDetect-LSP

## Usage

This config launches CCDetect-LSP on Java projects by default. Edit the file
`.config/nvim/init.lua` to change CCDetect-LSP options such as language and token threshold

Clone any git project you want to analyze (WorldWindJava is already cloned as an example
in the Docker container), cd into its directory and launch Neovim with `nvim` command.
Once a file with the chosen file-type is opened in Neovim (`.java` file by default),
CCDetect-LSP should start analyzing the project, and a notification spinner should show up
in the bottom right of the screen. Once it says completed, open up the diagnostic view
(`Ctrl+c`), to show all code-clones located.

## Hotkeys

Some Vim knowledge is probably required to efficiently use Neovim with CCDetect-LSP.

Some hotkeys are already setup for specific clone-detection features:

```txt
Ctrl+t = Fuzzy-find files
Ctrl+f = File-tree
Ctrl+c = Code clone view (diagnostics view)
Ctrl+a = Code action (navigate to clone match)
```
