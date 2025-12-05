-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Spaces not tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Faster key repeat
vim.opt.timeoutlen = 500

-- Better clipboard (Linux requires xclip/xsel)
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<F5>", ":w<CR>:!./.venv/bin/python %<CR>", { silent = true })

