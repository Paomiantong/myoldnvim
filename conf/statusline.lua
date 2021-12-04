local gl = require('galaxyline')
local gls = gl.section
local buffer = require('galaxyline.provider_buffer')
-- local extension = require('galaxyline.provider_extensions')

gl.short_line_list = {
    'runner',
    'defx',
    'LuaTree',
    'vista',
    'dbui',
    'startify',
    'term',
    'nerdtree',
    'fugitive',
    'fugitiveblame',
    'plug'
}

-- VistaPlugin = extension.vista_nearest

local colors = {
    bg = '#282c34',
    line_bg = '#353644',
    fg = '#8FBCBB',
    fg_green = '#65a380',

    gray = '#3e4452',
    lightgray = '#282c34',
    darknavy= '#2c323d',
    darkgray= '#abb2bf',

    yellow = '#fabd2f',
    cyan = '#008080',
    darkblue = '#081633',
    green = '#98C379',
    orange = '#FF8800',
    --purple = '#5d4d7a',
    purple = '#C678DD',
    magenta = '#c678dd',
    blue = '#51afef';
    red = '#ec5f67'
}

local function lsp_status(status)
    local shorter_stat = ''
    for match in string.gmatch(status, "[^%s]+")  do
        local err_warn = string.find(match, "^[WE]%d+", 0)
        if not err_warn then
            shorter_stat = shorter_stat .. ' ' .. match
        end
    end
    return shorter_stat
end


local function get_coc_lsp()
  local status = vim.fn['coc#status']()
  if not status or status == '' then
      return ''
  end
  return lsp_status(status)
end

local function get_diagnostic_info()
  if vim.fn.exists('*coc#rpc#start_server') == 1 then
    return get_coc_lsp()
    end
  return ''
end

local function get_current_func()
  local has_func, func_name = pcall(vim.fn.nvim_buf_get_var,0,'coc_current_function')
  if not has_func then return end
      return func_name
  end

local function get_function_info()
  if vim.fn.exists('*coc#rpc#start_server') == 1 then
    return get_current_func()
    end
  return ''
end

local function trailing_whitespace()
    local trail = vim.fn.search("\\s$", "nw")
    if trail ~= 0 then
        return ' '
    else
        return nil
    end
end

CocStatus = get_diagnostic_info
CocFunc = get_current_func
TrailingWhiteSpace = trailing_whitespace

local function has_file_type()
    local f_type = vim.bo.filetype
    if not f_type or f_type == '' then
        return false
    end
    return true
end

local buffer_not_empty = function()
  if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
    return true
  end
  return false
end

local mode_color = function()
    local mode_colors = {
        [110] = colors.green,
        [105] = colors.blue,
        [99] = colors.red,
        [116] = colors.blue,
        [118] = colors.purple,
        [22] = colors.purple,
        [86] = colors.purple,
        [82] = colors.red,
        [115] = colors.red,
        [83] = colors.red,
    }

    local color = mode_colors[vim.fn.mode():byte()]
    if color ~= nil then
        return color
    else
        return colors.purple
    end
end

gls.left[1] = {
  FirstElement = {
    provider = function()
        vim.api.nvim_command('hi GalaxyViModeBF guibg='.. mode_color())
        return '▊ '
    end,
    highlight = 'GalaxyViModeBF'
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local aliases = {
        [110] = 'NORMAL',
        [105] = 'INSERT',
        [99] = 'COMMAND',
        [116] = 'TERMINAL',
        [118] = 'VISUAL',
        [22] = 'V-BLOCK',
        [86] = 'V-LINE',
        [82] = 'REPLACE',
        [115] = 'SELECT',
        [83] = 'S-LINE',
      }
      local vim_mode = vim.fn.mode()
      vim.api.nvim_command('hi GalaxyViMode guibg='.. mode_color())
      vim.api.nvim_command('hi GalaxyViModeSP guifg='.. mode_color()..' guibg='..colors.line_bg)
      return '  ' .. aliases[vim_mode:byte()] .. ' '
    end,
    separator = ' ',
    separator_highlight = "GalaxyViModeSP",
    highlight = {colors.bg,colors.line_bg,'bold'},
  },
}
gls.left[3] ={
  FileIcon = {
    provider = {'FileIcon','FileName'},
    condition = buffer_not_empty,
    highlight = {require('galaxyline.provider_fileinfo').get_file_icon_color,colors.line_bg},
    separator = ' ',
    separator_highlight = {colors.darkgray, colors.line_bg},
  },
}
gls.left[4] = {
  FileName = {
    provider = 'FileSize',
    condition = buffer_not_empty,
    highlight = {colors.purple,colors.line_bg,'bold'},
  }
}

gls.left[5] = {
  GitIcon = {
    provider = function() return '  ' end,
    condition = require('galaxyline.condition').check_git_workspace,
    highlight = {colors.darkgray,colors.line_bg},
  }
}
gls.left[6] = {
  GitBranch = {
    provider = 'GitBranch',
    condition = require('galaxyline.condition').check_git_workspace,
    highlight = {colors.orange,colors.line_bg,'bold'},
  }
}

local checkwidth = function()
  local squeeze_width  = vim.fn.winwidth(0) / 2
  if squeeze_width > 40 then
    return true
  end
  return false
end

gls.left[7] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = ' ',
    highlight = {colors.green,colors.line_bg},
  }
}
gls.left[8] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = ' ',
    highlight = {colors.orange,colors.line_bg},
  }
}
gls.left[9] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = ' ',
    highlight = {colors.red,colors.line_bg},
  }
}
gls.left[10] = {
  LeftEnd = {
    provider = function() return '|' end,
    separator = '',
    separator_highlight = {colors.line_bg,colors.bg},
    highlight = {colors.line_bg,colors.line_bg}
  }
}

gls.left[11] = {
    TrailingWhiteSpace = {
     provider = TrailingWhiteSpace,
     icon = '  ',
     highlight = {colors.yellow,colors.bg},
    }
}

gls.left[12] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red,colors.bg}
  }
}
gls.left[13] = {
  Space = {
   provider = function () return ' ' end,
   highlight = {colors.line_bg, colors.bg}
  }
}
gls.left[14] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow,colors.bg},
  }
}


gls.left[15] = {
    CocStatus = {
     provider = CocStatus,
     highlight = {colors.green,colors.bg},
     icon = '  🗱'
    }
}

gls.left[16] = {
  CocFunc = {
    provider = CocFunc,
    icon = '  λ ',
    highlight = {colors.yellow,colors.bg},
  }
}

gls.right[1] = {
    WhiteSpaceEdge = {
        provider = function() return ' ' end,
        highlight = {colors.line_bg,colors.green},
        separator = '',
        separator_highlight = {colors.green, colors.bg}
    },
}

gls.right[2]= {
  FileEncode = {
    provider = 'FileEncode',
    highlight = {colors.bg,colors.green,'bold'},
  },
}

gls.right[3]= {
  FileFormat = {
    provider = {'FileFormat', function () return ' ' end},
    highlight = {colors.bg,colors.green,'bold'},
    separator = ' | ',
    separator_highlight = {colors.bg,colors.green},
  },
}

gls.right[4] = {
  LineInfo = {
    provider = 'LineColumn',
    highlight = {colors.darkgray,colors.darknavy,'bold'},
    separator = ' ',
    separator_highlight = {colors.green,colors.darknavy},
  },
}

gls.right[5] = {
  PerCent = {
    provider = 'LinePercent',
    highlight = {colors.darkgray,colors.darknavy,'bold'},
  }
}

gls.short_line_left[1] = {
  WhiteSpace = {
    provider = function ()
        return ' '
    end,
    highlight = {colors.line_bg,colors.green}
  }
}

gls.short_line_left[2] = {
  BufferType = {
    provider = function ()
        return ' '..buffer.get_buffer_filetype()..' '
    end,
    separator = '',
    condition = has_file_type,
    separator_highlight = {colors.green,colors.darknavy},
    highlight = {colors.line_bg,colors.green}
  }
}


gls.short_line_left[3] = {
  RunnerInfo = {
    provider = function ()
        return ' '..vim.fn["qrun#GetJobStatus"]()..'  JobID:' .. vim.fn["qrun#GetJobId"]() .. ' '
    end,
    separator = '',
    condition = function ()
        return buffer.get_buffer_filetype() == "RUNNER"
    end,
    separator_highlight = {colors.darknavy,colors.bg},
    highlight = {colors.purple,colors.darknavy}
  }
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    separator = '',
    condition = has_file_type,
    separator_highlight = {colors.line_bg,colors.darknavy},
    highlight = {colors.darkgray,colors.line_bg}
  }
}

