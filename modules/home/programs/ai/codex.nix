{ pkgs, config, ... }:
let
  codexCfg = config.programs.codex.settings;
  assistedByTrailer = "Assisted-by: codex with ${codexCfg.model}-${codexCfg.model_reasoning_effort}";
  assistedByTrailerHook = pkgs.writers.writePython3Bin "codex-assisted-by-trailer" { } ''
    import json
    import re
    import shlex
    import sys

    TRAILER = ${builtins.toJSON assistedByTrailer}

    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command")
    if not isinstance(command, str) or TRAILER in command:
        sys.exit(0)


    def add_trailer(match):
        trailer_arg = shlex.quote(TRAILER)
        return f"{match.group(1)}git commit --trailer {trailer_arg}"


    updated = re.sub(
        r"(^|[\s;|&])git\s+commit(?=\s|$)",
        add_trailer,
        command,
        count=1,
    )
    if updated == command:
        sys.exit(0)

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "updatedInput": {"command": updated},
            }
        },
        sys.stdout,
    )
    print()
  '';
in
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model = "gpt-5.6-sol";
      model_reasoning_effort = "high";
      plan_mode_reasoning_effort = "xhigh";

      approvals_reviewer = "auto_review";
      sandbox_mode = "danger-full-access";
      check_for_update_on_startup = false;
      suppress_unstable_features_warning = true;
      features = {
        fast_mode = true;
        memories = true;
        mentions_v2 = true;
        goals = true;
      };
      tui.status_line = [
        "model-with-reasoning"
        "project-name"
        "git-branch"
        "context-used"
        "context-remaining"
        "total-input-tokens"
        "total-output-tokens"
      ];
      hooks = {
        PreToolUse = [
          {
            matcher = "^Bash$";
            hooks = [
              {
                type = "command";
                command = "${assistedByTrailerHook}/bin/codex-assisted-by-trailer";
                statusMessage = "Adding Assisted-by trailer";
              }
            ];
          }
        ];
      };
    };
  };
}
