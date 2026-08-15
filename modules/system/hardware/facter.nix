{ config, lib, ... }:
let
  inherit (config.hardware.facter) report;

  cpus = report.hardware.cpu;
  features = lib.concatMap (c: c.features) cpus;
  isX86_64 = lib.any (c: c.architecture == "x86_64") cpus;
  hasAll = lib.all (f: lib.elem f features);

  # hwinfo records each display's preferred mode as a `monitor` resource,
  # alongside a `size` one in millimetres.
  monitorModes = lib.concatMap (m: lib.filter (r: r.type == "monitor") m.resources) (report.hardware.monitor or [ ]);

  # SMBIOS 7.4.1 chassis types that mean "portable".
  portableChassis = [
    8 # Portable
    9 # Laptop
    10 # Notebook
    11 # Hand Held
    14 # Sub Notebook
    30 # Tablet
    31 # Convertible
    32 # Detachable
  ];

  # https://en.wikipedia.org/wiki/X86-64#Microarchitecture_levels
  v2 = [
    "cx16"
    "lahf_lm"
    "popcnt"
    "pni"
    "sse4_1"
    "sse4_2"
    "ssse3"
  ];
  v3 = [
    "avx"
    "avx2"
    "bmi1"
    "bmi2"
    "f16c"
    "fma"
    "abm"
    "movbe"
    "xsave"
  ];
  v4 = [
    "avx512f"
    "avx512bw"
    "avx512cd"
    "avx512dq"
    "avx512vl"
  ];
in
{
  # Local additions to facter's `detected` namespace, shaped so they can be
  # upstreamed as-is. Delete whichever nixpkgs declares first, or the module
  # system will error on a duplicate option.
  options.hardware.facter.detected = {
    chassis.laptop = lib.mkOption {
      type = lib.types.bool;
      # NB: the chassis entry is a list, unlike most other SMBIOS tables.
      default = lib.any (ch: lib.elem ch.chassis_type.value portableChassis) report.smbios.chassis;
      defaultText = "hardware dependent";
      description = "Whether SMBIOS reports a portable chassis: battery, backlight and power management are worth enabling.";
    };

    monitor.mode = lib.mkOption {
      type = lib.types.strMatching "[0-9]+x[0-9]+@[0-9.]+";
      default =
        if monitorModes == [ ] then
          "1920x1080@60"
        else
          let
            m = lib.head monitorModes;
          in
          # EDID always carries a refresh rate for the preferred mode, but hwinfo
          # leaves the field out when the block is malformed.
          "${toString m.width}x${toString m.height}@${toString (m.vertical_frequency or 60)}";
      defaultText = "hardware dependent";
      description = ''
        Preferred mode of the first monitor in the report, as WIDTHxHEIGHT@Hz.
        Falls back to 1920x1080@60 when the report has no monitor: a headless
        host, or a VM whose virtual display carries no EDID.
      '';
    };

    cpu.microarchLevel = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "v1"
          "v2"
          "v3"
          "v4"
        ]
      );
      # The levels are cumulative supersets, so test from the top down.
      default =
        if !isX86_64 then
          null
        else if hasAll (v2 ++ v3 ++ v4) then
          "v4"
        else if hasAll (v2 ++ v3) then
          "v3"
        else if hasAll v2 then
          "v2"
        else
          "v1";
      defaultText = "hardware dependent";
      description = "Highest x86-64 psABI microarchitecture level this CPU satisfies, or null when not x86_64.";
    };
  };
}
