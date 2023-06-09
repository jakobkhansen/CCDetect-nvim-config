local vimscript = vim.api.nvim_exec

-- Bootstrap plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    {
        "akinsho/bufferline.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            require("bufferline").setup()
        end,
    },

    -- Visuals,
    "folke/tokyonight.nvim",
    "nvim-telescope/telescope.nvim",
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            {
                "s1n7ax/nvim-window-picker",
                config = function()
                    require("window-picker").setup()
                end,
            },
        },
    },

    -- "LSP, languages and tools",
    "neovim/nvim-lspconfig",
    {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup()
        end,
    },
    -- "Treesitter & Syntax highlighting",
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
})

-- Options
vim.opt.number = true

-- Load some plugins

require("tokyonight").setup()
vimscript("colorscheme tokyonight", false)

require("telescope").setup()

local lspconfig = require("lspconfig")
local util = lspconfig.util
local sysname = vim.loop.os_uname().sysname
local autocmd = vim.api.nvim_create_autocmd

local command = vim.api.nvim_command

-- CCDetect-LSP setup
local JAVA_HOME = os.getenv("JAVA_HOME")

local function get_java_executable()
    local executable = JAVA_HOME and util.path.join(JAVA_HOME, "bin", "java") or "java"

    return sysname:match("Windows") and executable .. ".exe" or executable
end

local jar = vim.env.HOME .. "/CCDetect-lsp/app/build/libs/app-all.jar"

local cmd = { get_java_executable(), "-Xmx8G", "-jar", jar }

local function on_show_document(err, result, ctx, config, params)
    local uri = result.uri
    command("e +" .. result.selection.start.line + 1 .. " " .. uri)

    return result
end

local cap = vim.lsp.protocol.make_client_capabilities()
cap.workspace.didChangeWatchedFiles.dynamicRegistration = true

-- CCDetect-LSP config - EDIT THIS TO CHANGE CCDetect-LSP options
local function start_ccdetect()
    vim.lsp.start({
        cmd = cmd,
        name = "CCDetect",
        root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
        handlers = {
            ["window/showDocument"] = on_show_document,
        },
        capabilities = cap,
        -- EDIT THESE OPTIONS
        init_options = {
            -- Set to file-extension of language, installed languages: java, py, go, js, rs, c
            language = "java",
            -- Set fragment query, here, see CCDetect-LSP README for examples for other languages
            fragment_query = "(method_declaration) @method (constructor_declaration) @constructor",
            -- Token threshold for how a long clone needs to be
            clone_token_threshold = 100,
            -- Use incremental algorithm for subsequent analysis after initial.
            -- If false, runs SACA algorithm each time
            dynamic_detection = true,
            -- Update on save only, recommended as saving on each keystroke is buggy
            update_on_save = true,
            -- Evaluation mode: Runs both SACA and incremental algorithms and logs time
            evaluate = false,
        },
    })
end

-- SET FILETYPE HERE AS WELL TO LAUNCH CCDETECT-LSP on a given filetype
-- Examples: java, python, go, javascript, rust, c
-- Try `:set ft?` to see if file-type != file-extension which is possible
autocmd("FileType", { pattern = "java", callback = start_ccdetect })

-- Hotkeys
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<C-t>", "<CMD>Telescope find_files<CR>", opts)
keymap("n", "<C-f>", "<CMD>Neotree toggle<CR>", opts)
keymap("n", "<C-c>", "<CMD>Telescope diagnostics<CR>", opts)
keymap("n", "<C-a>", "<CMD>lua vim.lsp.buf.code_action()<CR>", opts)
