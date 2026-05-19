{ config, ... }:

{
  programs = {
    gh.enable = true;
    lazygit.enable = true;
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
    difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
      jujutsu.enable = true;
      options = {
        display = "side-by-side-show-both";
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Aliaksandr";
          email = "grubian2@gmail.com";
        };
        signing = {
          sing-all = true;
        };
      };
    };

    git = {
      enable = true;
      signing = {
        format = "openpgp";
        key = config.programs.gpg.settings.default-key;
        signByDefault = true;
      };
      attributes = [
        "* text=auto"
        "bun.lock          merge=ours"
        "package-lock.json merge=ours"
        "pnpm-lock.yaml    merge=ours"
        "yarn.lock         merge=ours"
        "Cargo.lock        merge=ours"
      ];
      settings = {
        user.name = "Aliaksandr";
        user.email = "grubian2@gmail.com";
        github.user = "qweered";
        feature.experimental = true;
        credential.helper = "libsecret";

        blame = {
          coloring = "repeatedLines";
          date = "relative";
          markUnblamables = true;
          markIgnoredLines = true;
        };
        branch = {
          autoSetupRebase = "always";
          sort = "-committerdate";
        };

        # Auto prune # TODO: slow for eg nixpkgs
        fetch.prune = true;
        fetch.pruneTags = true;
        remote.origin.prune = true;

        # Performance
        core.fsmonitor = true; # will benefit when support linux
        feature.manyFiles = true;
        fetch.writeCommitGraph = true;
        fetch.parallel = 0; # use all available cores

        checkout.defaultRemote = "origin";
        color.ui = "auto"; # always breaks some aliases
        column.ui = "auto";
        diff.algorithm = "histogram";
        diff.mnemonicPrefix = true;
        diff.renames = "copies";
        difftool.prompt = false;
        core.pager = "bat"; # use bat as pager
        pager.difftool = true;
        fetch.all = "false"; # fetch manually instead
        init.defaultBranch = "main";
        log.date = "relative";
        log.decorate = "auto";
        log.follow = true;
        merge.autoStash = true;
        merge.tool = "nvimdiff"; # keep nvimdiff for merges (difftastic is diff-only)
        merge.ff = "only"; # try to not crate merge commits

        advice = {
          skippedCherryPicks = "false";
        };

        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
          "https://gitlab.com/" = {
            insteadOf = [
              "gl:"
              "gitlab:"
            ];
          };
        };

        # TODO: check settings up to here https://git-scm.com/docs/git-config#Documentation/git-config.txt-pullff

        push = {
          autoSetupRemote = true;
          default = "simple";
          followTags = true;
          useForceIfIncludes = true;
        };

        # Pull settings
        pull.rebase = true;

        # Rebase settings
        rebase.autoStash = true;
        rebase.autoSquash = true;
        rebase.updateRefs = true;

        # Rerere settings
        rerere.enable = true;
        rerere.autoUpdate = true;

        # Remote settings

        # Status settings
        status.showUntrackedFiles = "all";
        status.submoduleSummary = true;

        # Submodule settings
        submodule.recurse = true;
        submodule.fetchJobs = 4;

        # Tag settings
        tag.sort = "version:refname";
        # Versionsort settings
        versionsort.suffix = [
          "-pre"
          ".pre"
          "-beta"
          ".beta"
          "-rc"
          ".rc"
        ];
        alias = {
          aa = "add --all";
          ap = "add --patch";
          rs = "restore";
          rss = "restore --staged";
          unstage = "reset HEAD --";
          unwip = "reset HEAD~1";
          rhard = "reset --hard";
          rsoft = "reset --soft";
          r2 = "reset HEAD~2";
          r3 = "reset HEAD~3";
          r4 = "reset HEAD~4";

          sl = "stash list";
          sp = "stash pop";
          ss = "stash push"; # modern alternative to stash save
          ssm = "stash push -m"; # stash with message
          ssu = "stash push --include-untracked";

          c = "commit";
          cm = "commit --message";
          ca = "commit --amend";
          caan = "commit --all --amend --no-edit";
          can = "commit --amend --no-edit";
          wip = "commit --amend --message 'WIP: work in progress'";
          caf = "commit --all --fixup HEAD";

          f = "fetch";
          fum = "fetch upstream main";
          fuma = "fetch upstream master";
          fom = "fetch origin main";
          foma = "fetch origin master";
          sync-upstream = "!git fuma && git rb upstream/master && git pf";
          sync-origin = "!git foma && git rb origin/master && git pf";

          p = "push";
          po = "push origin";
          pf = "push --force-with-lease"; # safer than --force
          pff = "push --force";
          pu = "push --set-upstream origin HEAD"; # push to remote branch and set upstream
          pl = "pull";
          plo = "pull origin";
          plu = "pull upstream";
          sw = "switch";
          swc = "switch --create";

          rb = "rebase";
          rbi = "rebase --interactive";
          rbc = "rebase --continue";
          rba = "rebase --abort";
          rbs = "rebase --skip";

          b = "branch -vv";
          bd = "branch --delete";
          bD = "branch --delete --force";
          br = "branch --remote";
          ba = "branch --all";
          bm = "branch --merged";
          bnm = "branch --no-merged";

          wl = "worktree list";
          wr = "worktree remove";
          wp = "worktree prune";

          # delete local merged branches, excluding protected/current branch
          cleanup-merged = "!f() { cur=$(git branch --show-current); git branch --format='%(refname:short)' --merged | while read -r b; do case \"$b\" in ''|main|master|develop|stable|\"$cur\") continue ;; esac; git branch -D \"$b\"; done; }; f";
          # delete local branches that have no upstream (never pushed/tracked)
          cleanup-unpushed = "!f() { cur=$(git branch --show-current); git for-each-ref refs/heads --format='%(refname:short)%09%(upstream:short)' | while IFS=$'\\t' read -r b up; do case \"$b\" in ''|main|master|develop|stable|\"$cur\") continue ;; esac; [ -n \"$up\" ] && continue; git branch -D \"$b\"; done; }; f";
          # delete local branches whose upstream branch no longer exists
          cleanup-gone = "!f() { cur=$(git branch --show-current); git for-each-ref refs/heads --format='%(refname:short)%09%(upstream:track)' | while IFS=$'\\t' read -r b track; do case \"$b\" in ''|main|master|develop|stable|\"$cur\") continue ;; esac; [ \"$track\" = '[gone]' ] || continue; git branch -D \"$b\"; done; }; f";
          # delete remote merged branches, VERY DANGEROUS
          cleanup-remote = "!git branch -r --merged | grep -v -E '\\*\\s|main|master|develop|stable' | sed -e 's/origin\\///' | xargs -r -n 1 git push origin --delete";
          full-cleanup = "!git cleanup-merged && git cleanup-unpushed && git cleanup-gone && git cleanup-remote";

          # TODO: checked aliases up to here
          # TODO: reverse order of logs
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          ll = "log --oneline --graph --decorate --all -20";
          ls = "log --stat";
          lol = "log --graph --decorate --pretty=oneline --abbrev-commit";

          s = "status --short --branch";
          st = "status";
          dc = "diff HEAD"; # staged diff
          dp = "diff HEAD~1 HEAD"; # previous commit diff
          dcv = "difftool HEAD --tool=nvimdiff --no-prompt";
          dpv = "difftool HEAD~1 HEAD --tool=nvimdiff --no-prompt";

          # Utility aliases
          ds = "describe --long --tags --dirty --always";
          who = "shortlog --summary";
          last = "log --oneline --stat HEAD";
          visual = "!gitk";
          today = "log --since='1 day ago' --oneline --author=$(git config user.email)";
          yesterday = "log --since='2 days ago' --until='1 day ago' --oneline --author=$(git config user.email)";

          # Workflow aliases
          assume = "update-index --assume-unchanged";
          unassume = "update-index --no-assume-unchanged";
          assumed = "!git ls-files -v | grep ^h | cut -c 3-";
        };
      };
    };
  };
}
