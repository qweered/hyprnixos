{
  config,
  inputs,
  vars,
  ...
}:

{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings.vim = {
      enableLuaLoader = true;
      debugMode.enable = false;

      opts = {
        expandtab = true;
        shada = "!,'100,<50,s10,h";
        foldcolumn = "1";
        foldlevel = 99;
        foldlevelstart = 99;
        foldenable = true;
      };

      autocomplete = {
        enableSharedCmpSources = true;
        blink-cmp = {
          enable = true;
          friendly-snippets.enable = true;
        };
      };

      autopairs.nvim-autopairs.enable = true;

      binds = {
        # hardtime-nvim.enable = true;
        whichKey.enable = true;
      };

      clipboard = {
        enable = true;
        providers.wl-copy.enable = true;
        registers = "unnamed,unnamedplus";
      };

      comments.comment-nvim.enable = true;

      diagnostics = {
        enable = true;
        nvim-lint.enable = true;
        config = {
          virtual_text = true;
          signs = true;
          underline = true;
          severity_sort = true;
        };
      };

      filetree.neo-tree.enable = true;

      formatter.conform-nvim.enable = true;

      git = {
        enable = true;
        gitsigns = {
          enable = true;
          setupOpts = {
            current_line_blame = true;
            current_line_blame_opts = {
              virt_text = true;
              virt_text_pos = "eol";
              delay = 300;
              ignore_whitespace = false;
            };
          };
        };
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        inlayHints.enable = true;
        lightbulb.enable = true;
        mappings = {
          goToDefinition = "gd";
          goToDeclaration = "gD";
          goToType = "gy";
          listImplementations = "gI";
          listReferences = "gr";
          hover = "K";
          signatureHelp = "gK";
          renameSymbol = "<leader>cr";
          codeAction = "<leader>ca";
          format = "<leader>cf";
          openDiagnosticFloat = "<leader>cd";
          nextDiagnostic = "]d";
          previousDiagnostic = "[d";
          listDocumentSymbols = "<leader>ss";
          listWorkspaceSymbols = "<leader>sS";
          toggleFormatOnSave = "<leader>uf";
          documentHighlight = "<leader>cH";
          addWorkspaceFolder = "<leader>cwa";
          removeWorkspaceFolder = "<leader>cwr";
          listWorkspaceFolders = "<leader>cwl";
        };
      };

      treesitter.textobjects.enable = true;

      mini.ai.enable = true;
      ui.nvim-ufo.enable = true;

      git.git-conflict.mappings = {
        ours = "<leader>gxo";
        theirs = "<leader>gxt";
        both = "<leader>gxb";
        none = "<leader>gx0";
      };

      utility = {
        smart-splits = {
          enable = true;
          keymaps = {
            resize_left = "<C-Left>";
            resize_down = "<C-Down>";
            resize_up = "<C-Up>";
            resize_right = "<C-Right>";
          };
        };
        surround.enable = true;
        motion.flash-nvim.enable = true;
        yanky-nvim.enable = true;
      };

      tabline.nvimBufferline = {
        enable = true;
        mappings = {
          cycleNext = "<S-l>";
          cyclePrevious = "<S-h>";
          closeCurrent = null;
          pick = "<leader>bj";
          moveNext = "]B";
          movePrevious = "[B";
        };
      };

      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
        mappings = {
          continue = "<leader>dc";
          terminate = "<leader>dt";
          toggleBreakpoint = "<leader>db";
          toggleRepl = "<leader>dr";
          runLast = "<leader>dl";
          stepInto = "<leader>di";
          stepOut = "<leader>do";
          stepOver = "<leader>dO";
          runToCursor = "<leader>dC";
          hover = "<leader>dh";
          toggleDapUI = "<leader>du";
        };
      };

      notes.todo-comments = {
        enable = true;
        mappings = {
          telescope = null;
          trouble = null;
        };
      };

      lsp.nvim-docs-view = {
        enable = true;
        mappings = {
          viewToggle = "<leader>cv";
          viewUpdate = "<leader>cV";
        };
      };

      statusline.lualine.enable = true;

      ui.noice = {
        enable = true;
        setupOpts = {
          notify.enabled = false;
          routes = [
            {
              filter = {
                event = "msg_show";
                kind = [
                  ""
                  "echo"
                  "echomsg"
                  "emsg"
                  "wmsg"
                ];
              };
              view = "mini";
            }
          ];
        };
      };

      utility.snacks-nvim = {
        enable = true;
        setupOpts = {
          bigfile.enabled = true;
          bufdelete.enabled = true;
          dashboard = {
            enabled = true;
            preset.keys = [
              {
                icon = " ";
                key = "f";
                desc = "Find File";
                action = ":lua Snacks.dashboard.pick('files')";
              }
              {
                icon = " ";
                key = "n";
                desc = "New File";
                action = ":ene | startinsert";
              }
              {
                icon = " ";
                key = "g";
                desc = "Find Text";
                action = ":lua Snacks.dashboard.pick('grep')";
              }
              {
                icon = " ";
                key = "r";
                desc = "Recent Files";
                action = ":lua Snacks.dashboard.pick('recent')";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action = ":lua Snacks.dashboard.pick('files', { cwd = '${vars.flakeDirectory}' })";
              }
              {
                icon = " ";
                key = "q";
                desc = "Quit";
                action = ":qa";
              }
            ];
            sections = [
              { section = "header"; }
              {
                section = "keys";
                gap = 1;
                padding = 1;
              }
              {
                section = "recent_files";
                padding = 1;
              }
              {
                section = "projects";
                padding = 1;
              }
            ];
          };
          indent.enabled = false;
          input.enabled = true;
          lazygit.enabled = true;
          picker.enabled = true;
          notifier = {
            enabled = true;
            timeout = 3000;
          };
          quickfile.enabled = true;
          scope.enabled = false;
          scratch.enabled = true;
          statuscolumn.enabled = true;
          terminal.enabled = true;
          words.enabled = true;
        };
      };

      languages = {
        enableTreesitter = true;
        enableFormat = true;
        enableExtraDiagnostics = true;

        nix = {
          enable = true;
          lsp.servers = [ "nixd" ];
          format.type = [ "nixfmt" ];
        };

        typescript.enable = true;
        markdown = {
          enable = true;
          extraDiagnostics.types = [ "rumdl" ];
          format.enable = false;
        };
      };

      keymaps = [
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "h";
          action = "l";
          desc = "Right (swapped from l)";
        }
        {
          mode = [
            "n"
            "x"
            "o"
          ];
          key = "l";
          action = "h";
          desc = "Left (swapped from h)";
        }

        {
          mode = [
            "i"
            "x"
            "n"
            "s"
          ];
          key = "<C-s>";
          action = "<cmd>w<CR><Esc>";
          desc = "Save File";
        }
        {
          mode = "n";
          key = "<A-j>";
          action = "<cmd>m .+1<CR>==";
          desc = "Move Line Down";
        }
        {
          mode = "n";
          key = "<A-k>";
          action = "<cmd>m .-2<CR>==";
          desc = "Move Line Up";
        }
        {
          mode = "i";
          key = "<A-j>";
          action = "<Esc><cmd>m .+1<CR>==gi";
          desc = "Move Line Down";
        }
        {
          mode = "i";
          key = "<A-k>";
          action = "<Esc><cmd>m .-2<CR>==gi";
          desc = "Move Line Up";
        }
        {
          mode = "v";
          key = "<A-j>";
          action = ":m '>+1<CR>gv=gv";
          desc = "Move Line Down";
        }
        {
          mode = "v";
          key = "<A-k>";
          action = ":m '<-2<CR>gv=gv";
          desc = "Move Line Up";
        }

        {
          mode = "n";
          key = "<leader>-";
          action = "<C-w>s";
          desc = "Split Window Below";
        }
        {
          mode = "n";
          key = "<leader>|";
          action = "<C-w>v";
          desc = "Split Window Right";
        }
        {
          mode = "n";
          key = "<leader>wd";
          action = "<C-w>c";
          desc = "Delete Window";
        }

        {
          mode = "n";
          key = "<leader>qq";
          action = "<cmd>qa<CR>";
          desc = "Quit All";
        }

        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Neotree toggle<CR>";
          desc = "Explorer";
        }
        {
          mode = "n";
          key = "<leader>E";
          action = "<cmd>Neotree toggle reveal_force_cwd<CR>";
          desc = "Explorer (cwd)";
        }

        {
          mode = "n";
          key = "<leader>?";
          action = "<cmd>lua Snacks.picker.keymaps()<CR>";
          desc = "Keymaps";
        }

        {
          mode = "n";
          key = "<leader>xt";
          action = "<cmd>lua Snacks.picker.todo_comments()<CR>";
          desc = "Todo";
        }
        {
          mode = "n";
          key = "<leader>xT";
          action = ''<cmd>lua Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })<CR>'';
          desc = "Todo/Fix/Fixme";
        }

        {
          mode = [
            "n"
            "t"
          ];
          key = "<C-/>";
          action = "<cmd>lua Snacks.terminal.toggle()<CR>";
          desc = "Toggle Terminal";
        }
        {
          mode = [
            "n"
            "t"
          ];
          key = "<C-_>";
          action = "<cmd>lua Snacks.terminal.toggle()<CR>";
          desc = "Toggle Terminal";
        }
        {
          mode = "n";
          key = "<leader>ft";
          action = "<cmd>lua Snacks.terminal.toggle()<CR>";
          desc = "Terminal";
        }

        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>lua Snacks.lazygit()<CR>";
          desc = "Lazygit";
        }

        {
          mode = "n";
          key = "<leader>n";
          action = "<cmd>lua Snacks.picker.notifications()<CR>";
          desc = "Notification History";
        }
        {
          mode = "n";
          key = "<leader>un";
          action = "<cmd>lua Snacks.notifier.hide()<CR>";
          desc = "Dismiss All Notifications";
        }
        {
          mode = "n";
          key = "<leader>.";
          action = "<cmd>lua Snacks.scratch()<CR>";
          desc = "Toggle Scratch Buffer";
        }
        {
          mode = "n";
          key = "<leader>S";
          action = "<cmd>lua Snacks.scratch.select()<CR>";
          desc = "Select Scratch Buffer";
        }

        {
          mode = "n";
          key = "]e";
          action = "<cmd>lua vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })<CR>";
          desc = "Next Error";
        }
        {
          mode = "n";
          key = "[e";
          action = "<cmd>lua vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })<CR>";
          desc = "Prev Error";
        }
        {
          mode = "n";
          key = "]w";
          action = "<cmd>lua vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })<CR>";
          desc = "Next Warning";
        }
        {
          mode = "n";
          key = "[w";
          action = "<cmd>lua vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })<CR>";
          desc = "Prev Warning";
        }

        {
          mode = "n";
          key = "<leader>K";
          action = "<cmd>norm! K<CR>";
          desc = "Keywordprg";
        }

        {
          mode = "n";
          key = "zR";
          action = ''<cmd>lua require("ufo").openAllFolds()<CR>'';
          desc = "Open All Folds";
        }
        {
          mode = "n";
          key = "zM";
          action = ''<cmd>lua require("ufo").closeAllFolds()<CR>'';
          desc = "Close All Folds";
        }

        {
          mode = "n";
          key = "<leader><space>";
          action = "<cmd>lua Snacks.picker.smart()<CR>";
          desc = "Smart Find Files";
        }
        {
          mode = "n";
          key = "<leader>/";
          action = "<cmd>lua Snacks.picker.grep()<CR>";
          desc = "Grep";
        }
        {
          mode = "n";
          key = "<leader>,";
          action = "<cmd>lua Snacks.picker.buffers()<CR>";
          desc = "Buffers";
        }
        {
          mode = "n";
          key = "<leader>:";
          action = "<cmd>lua Snacks.picker.command_history()<CR>";
          desc = "Command History";
        }

        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>lua Snacks.picker.files()<CR>";
          desc = "Find Files";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>lua Snacks.picker.buffers()<CR>";
          desc = "Buffers";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>lua Snacks.picker.git_files()<CR>";
          desc = "Find Git Files";
        }
        {
          mode = "n";
          key = "<leader>fr";
          action = "<cmd>lua Snacks.picker.recent()<CR>";
          desc = "Recent Files";
        }
        {
          mode = "n";
          key = "<leader>fp";
          action = "<cmd>lua Snacks.picker.projects()<CR>";
          desc = "Projects";
        }
        {
          mode = "n";
          key = "<leader>fc";
          action = ''<cmd>lua Snacks.picker.files({ cwd = "${vars.flakeDirectory}" })<CR>'';
          desc = "Find Config File";
        }

        {
          mode = "n";
          key = "<leader>sg";
          action = "<cmd>lua Snacks.picker.grep()<CR>";
          desc = "Grep";
        }
        {
          mode = "n";
          key = "<leader>sh";
          action = "<cmd>lua Snacks.picker.help()<CR>";
          desc = "Help Pages";
        }
        {
          mode = "n";
          key = "<leader>sk";
          action = "<cmd>lua Snacks.picker.keymaps()<CR>";
          desc = "Keymaps";
        }
        {
          mode = "n";
          key = "<leader>sw";
          action = "<cmd>lua Snacks.picker.grep_word()<CR>";
          desc = "Word Under Cursor";
        }
        {
          mode = [
            "n"
            "x"
          ];
          key = "<leader>sb";
          action = "<cmd>lua Snacks.picker.lines()<CR>";
          desc = "Buffer Lines";
        }
        {
          mode = "n";
          key = "<leader>sm";
          action = "<cmd>lua Snacks.picker.marks()<CR>";
          desc = "Marks";
        }
        {
          mode = "n";
          key = "<leader>sd";
          action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
          desc = "Diagnostics";
        }
        {
          mode = "n";
          key = "<leader>sD";
          action = ''<cmd>lua vim.ui.input({ prompt = "Extension (e.g. ts, nix): " }, function(ext) if not ext or ext == "" then return end ext = ext:gsub("^%.", ""); Snacks.picker.diagnostics({ filter = { filter = function(item) return item.file and item.file:match("%." .. ext .. "$") ~= nil end } }) end)<CR>'';
          desc = "Diagnostics by Extension";
        }
        {
          mode = "n";
          key = "<leader>sR";
          action = "<cmd>lua Snacks.picker.resume()<CR>";
          desc = "Resume Picker";
        }
        {
          mode = "n";
          key = "<leader>st";
          action = "<cmd>lua Snacks.picker.todo_comments()<CR>";
          desc = "Todo";
        }
        {
          mode = "n";
          key = "<leader>ss";
          action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
          desc = "LSP Symbols";
        }
        {
          mode = "n";
          key = "<leader>sS";
          action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
          desc = "LSP Workspace Symbols";
        }

        {
          mode = "n";
          key = "<leader>gs";
          action = "<cmd>lua Snacks.picker.git_status()<CR>";
          desc = "Git Status";
        }
        {
          mode = "n";
          key = "<leader>gl";
          action = "<cmd>lua Snacks.picker.git_log()<CR>";
          desc = "Git Log";
        }
        {
          mode = "n";
          key = "<leader>gf";
          action = "<cmd>lua Snacks.picker.git_log_file()<CR>";
          desc = "Git Log (Buffer)";
        }
        {
          mode = "n";
          key = "<leader>gB";
          action = "<cmd>lua Snacks.picker.git_branches()<CR>";
          desc = "Git Branches";
        }
        {
          mode = "n";
          key = "<leader>gS";
          action = "<cmd>lua Snacks.picker.git_stash()<CR>";
          desc = "Git Stash";
        }

        {
          mode = "n";
          key = "<leader>xx";
          action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
          desc = "Workspace Diagnostics";
        }
        {
          mode = "n";
          key = "<leader>xX";
          action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
          desc = "Buffer Diagnostics";
        }
        {
          mode = "n";
          key = "<leader>xQ";
          action = "<cmd>lua Snacks.picker.qflist()<CR>";
          desc = "Quickfix List";
        }
        {
          mode = "n";
          key = "<leader>xL";
          action = "<cmd>lua Snacks.picker.loclist()<CR>";
          desc = "Location List";
        }
        {
          mode = "n";
          key = "<leader>cs";
          action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
          desc = "Symbols";
        }

        {
          mode = "n";
          key = "<leader>bd";
          action = "<cmd>lua Snacks.bufdelete()<CR>";
          desc = "Delete Buffer";
        }
        {
          mode = "n";
          key = "<leader>bo";
          action = "<cmd>lua Snacks.bufdelete.other()<CR>";
          desc = "Delete Other Buffers";
        }
        {
          mode = "n";
          key = "<leader>bb";
          action = "<cmd>e #<CR>";
          desc = "Switch to Other Buffer";
        }

        {
          mode = "n";
          key = "<leader>ul";
          action = "<cmd>set number!<CR>";
          desc = "Toggle Line Numbers";
        }
        {
          mode = "n";
          key = "<leader>uL";
          action = "<cmd>set relativenumber!<CR>";
          desc = "Toggle Relative Number";
        }
        {
          mode = "n";
          key = "<leader>uw";
          action = "<cmd>set wrap!<CR>";
          desc = "Toggle Wrap";
        }
        {
          mode = "n";
          key = "<leader>us";
          action = "<cmd>set spell!<CR>";
          desc = "Toggle Spelling";
        }
        {
          mode = "n";
          key = "<leader>uh";
          action = "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>";
          desc = "Toggle Inlay Hints";
        }
        {
          mode = "n";
          key = "<leader>uv";
          action = "<cmd>lua local c = vim.diagnostic.config(); vim.diagnostic.config({ virtual_lines = not c.virtual_lines, virtual_text = c.virtual_lines })<CR>";
          desc = "Toggle Diagnostic Virtual Lines";
        }
        {
          mode = "n";
          key = "<leader>ub";
          action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
          desc = "Toggle Git Blame Line";
        }

        {
          mode = [
            "i"
            "n"
            "s"
          ];
          key = "<Esc>";
          action = "<cmd>noh<CR><Esc>";
          desc = "Escape and Clear hlsearch";
        }
      ];
    };
  };

  programs.neovide = {
    enable = true;
    settings = {
      neovim-bin = "${config.programs.nvf.finalPackage}/bin/nvim";
      font = {
        normal = [ "JetBrainsMono Nerd Font" ];
        size = 12.0;
      };
    };
  };
}
