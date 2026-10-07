-- buffer navigator
vim.keymap.set("n", "<S-h>", "<CMD>bprevious<CR>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<CMD>bnext<CR>", { desc = "Next Buffer" })

-- do not copy when type 'x'
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })
-- do not copy when visual paste
vim.keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

-- Split window
vim.keymap.set("n", "<leader>wh", "<CMD>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>w-", "<CMD>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wv", "<CMD>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>w\\", "<CMD>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wd", "<c-w>c", { desc = "Delete window" })
-- Navigate window
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- Resize window
vim.keymap.set("n", "<C-UP>", "<CMD>resize +2<CR>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<CMD>resize -2<CR>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<CMD>vertical resize -2<CR>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<CMD>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", noremap = true, silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", noremap = true, silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down", noremap = true, silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up", noremap = true, silent = true })

-- Clear search highlight
vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR><ESC>")

-- Better up/down
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { silent = true, expr = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { silent = true, expr = true })

-- Better indent
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
