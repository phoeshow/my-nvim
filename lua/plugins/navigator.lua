local ss = require("smart-splits")
ss.setup({
  mux = { backend = { "smart-splits-backend-tmux" }, warn_if_unusable = false },
})

vim.keymap.set("n", "<C-h>", ss.move_cursor_left, { desc = "Navigate Left" })
vim.keymap.set("n", "<C-j>", ss.move_cursor_down, { desc = "Navigate Down" })
vim.keymap.set("n", "<C-k>", ss.move_cursor_up, { desc = "Navigate Up" })
vim.keymap.set("n", "<C-l>", ss.move_cursor_right, { desc = "Navigate Right" })
