-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'AckslD/nvim-neoclip.lua',
  dependencies = {
    { 'kkharji/sqlite.lua', module = 'sqlite' },
    { 'nvim-telescope/telescope.nvim' },
  },
  config = function()
    require('neoclip').setup {
      -- Optional: keep unnamed + system clipboard in sync via neoclip
      default_register = { '"', '+' },

      on_select = {
        move_to_front = true,
        close_telescope = true,
      },
      on_paste = {
        set_reg = true, -- <== update registers when using paste keys
        move_to_front = true,
        close_telescope = true,
      },
    }
  end,
}
