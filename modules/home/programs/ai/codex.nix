{
  pkgs,
  config,
  lib,
  user,
  ...
}:
let
  inherit (user) flakeDirectory homeDirectory;
  projectsDirectory = "${homeDirectory}/Projects";
  trustedProjects = [
    flakeDirectory
    projectsDirectory
  ]
  ++ map (path: "${projectsDirectory}/${path}") [
    "home-manager"
    "infra"
    "nixpkgs"
    "repology-rules"
  ];
  codexCfg = config.programs.codex.settings;
  assistedByTrailerHook = pkgs.writers.writePython3Bin "codex-assisted-by-trailer" { } ''
    import json
    import re
    import shlex
    import sys

    data = json.load(sys.stdin)
    tool_input = data.get("tool_input", {})
    command = tool_input.get("command")
    trailer = ${builtins.toJSON "Assisted-by: codex with ${codexCfg.model}-${codexCfg.model_reasoning_effort}"}
    if not isinstance(command, str) or trailer in command:
        sys.exit(0)
    updated = re.sub(
        r"(^|[\s;|&])git\s+commit(?=\s|$)",
        lambda match: f"{match[1]}git commit --trailer {shlex.quote(trailer)}",
        command,
        count=1,
    )
    if updated != command:
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "updatedInput": tool_input | {"command": updated},
            }
        }))
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
      service_tier = "fast";

      approvals_reviewer = "auto_review";
      sandbox_mode = "danger-full-access";
      check_for_update_on_startup = false;
      suppress_unstable_features_warning = true;
      features = {
        memories = true;
        multi_agent_v2 = {
          enabled = true;
          max_concurrent_threads_per_session = 6;
        };
      };
      agents = {
        max_depth = 2;
      };
      projects = lib.genAttrs trustedProjects (_: {
        trust_level = "trusted";
      });
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
