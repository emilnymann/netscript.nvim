# netscript.nvim

This plugin aims to move as much of the game as
possible into your favorite editor: Neovim.

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
