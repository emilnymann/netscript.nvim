# netscript.nvim

[![Release](https://img.shields.io/github/v/release/emilnymann/netscript.nvim?style=for-the-badge)](https://github.com/emilnymann/netscript.nvim/releases)
[![License](https://img.shields.io/github/license/emilnymann/netscript.nvim?style=for-the-badge)](https://github.com/emilnymann/netscript.nvim/releases)

Write [Bitburner](https://store.steampowered.com/app/1812820/Bitburner/) scripts from Neovim.

- ⬇️ Pull all files from the game into a configurable working directory
- 💾 Automatically pushes scripts to the game on save
- 📄 Pull the Netscript type definitions for full LSP support without a JS environment
- 🔋 Display the RAM usage of the current script and the Bitburner connection status on your statusline

<!--toc:start-->

- [Dependencies](#dependencies)
- [Configuration](#configuration)
  - [lazy.nvim](#lazynvim)
  - [Setup](#setup)
- [Statusline](#statusline)
- [Commands](#commands)
<!--toc:end-->

## Dependencies

- `websocat`

## Configuration

### lazy.nvim

```lua
{
  "emilnymann/netscript.nvim",
  opts = {
    port = 12525,
    root_dir = "~/bitburner-files",
    file_sync_exts = { "js", "ts", "jsx", "tsx" },
  },
}
```

### Setup

```lua
require("netscript").setup({
  port = 12525,
  root_dir = "~/bitburner-files",
  file_sync_exts = { "js", "ts", "jsx", "tsx" },
})
```

| Option           | Type       | Default                        | Description                                                          |
| ---------------- | ---------- | ------------------------------ | -------------------------------------------------------------------- |
| `port`           | `number`   | `12525`                        | Port the WebSocket server binds to                                   |
| `root_dir`       | `string`   | `~/bitburner-files`            | Plugin only activates when the working directory is inside this path |
| `file_sync_exts` | `string[]` | `{ "js", "ts", "jsx", "tsx" }` | File extensions included in sync operations; others are ignored      |

## Statusline

Two functions are available for use in your statusline.
They will always return an empty string when they are not applicable, which hides them.

| Function                                       | Returns                                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `require("netscript.statusline").ns_status()`  | `"NS ✔️"` when a client is connected, `"NS ❌"` when the server is running but no client is connected. |
| `require("netscript.statusline").buffer_ram()` | `"RAM: X.X GB"` for the current buffer's script RAM cost.                                              |

Example with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim):

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      { require("netscript.statusline").buffer_ram },
      { require("netscript.statusline").ns_status },
    },
  },
})
```

## Commands

| Command        | Description                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------- |
| `NSSync`       | Sync files from bitburner to the working directory. Also executes `NSUpdateDefs`                  |
| `NSUpdateDefs` | Pull the Netscript TypeScript definitions to the working directory.                               |
| `NSPullFile`   | Pull the file in the current buffer from the game and overwrite the local file with its contents. |
