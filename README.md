# netscript.nvim

Write [Bitburner](https://store.steampowered.com/app/1812820/Bitburner/) scripts from Neovim.

- 🔄 Automatically pushes scripts to the game on save
- 📄 Pull the Netscript type definitions for full LSP support without a JS environment

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

## Commands

| Command        | Description                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------- |
| `NSUpdateDefs` | Pull the Netscript TypeScript definitions to the working directory.                               |
| `NSPullFile`   | Pull the file in the current buffer from the game and overwrite the local file with its contents. |
