# System Closure Audit

This is the living record for reducing the `hyprnix` system closure without
removing requested packages or disabling their functionality. Update this file
as each candidate is measured, investigated, accepted, or rejected.

## Scope and rules

- Keep the installed package set and enabled features intact.
- Remove only dependencies that are not required at runtime.
- Keep each nixpkgs package change in one focused commit on
  `reduce-system-closure` in `/home/qweered/Projects/nixpkgs`.
- Prefer an exact `nix why-depends --precise` explanation over package-name
  guesses.
- Distinguish build inputs from runtime references. A build dependency is not a
  closure problem unless the produced output retains it.
- Validate the smallest relevant package and at least one real downstream when
  practical. Avoid large unrelated builds on this machine.
- Record rejected candidates too, so they are not repeatedly rediscovered.
- Package-level closure savings are not additive: dependencies can overlap in
  the complete system closure.

## Baseline

Captured on 2026-07-16 from `/run/current-system`:

| Measurement | Value |
| --- | ---: |
| System path | `nixos-system-hyprnix-26.11.20260714.18b9261-patched` |
| Closure size | 19,539,003,424 bytes (about 18.2 GiB) |
| Development outputs in closure | 94 |
| Local nixpkgs fix branch | `reduce-system-closure` |
| Audit-document branch | `closure-audit` |

The running system uses an older flake input than the local nixpkgs `master`,
so package-level and downstream comparisons are used during the hunt. A final
system-level comparison must account for that revision difference instead of
accidentally measuring a general nixpkgs update.

## Accepted fixes

| Commit | Package | Retained dependency | Result | Validation |
| --- | --- | --- | ---: | --- |
| `d1801ceb8b6c` | `tlp-pd` | Python runtime outputs instead of development outputs | 66.4 MiB package closure | Full build, import checks, `tlp-pd --help` |
| `6acf174a508d` | `zed-editor` | `livekit-libwebrtc` runtime library instead of `.dev` in RPATH | 705,037,872 bytes modeled | Exact RPATH cause, patched binary `ldd`; full Zed build intentionally skipped |
| `f27498b7b378` | `mpv` wrapper | MPV out/doc/man instead of `.all` | 189,312 bytes package closure | Full build, version check, output/reference comparison |
| `54ebd1623101` | `libappimage` | Shared runtime library; development files split to `.dev` | 232,976,768 bytes package closure | Full build, layout and `ldd`; `kio-extras` configured and compiled AppImage source |
| `28c245455f86` | `papirus-icon-theme` | Breeze and hicolor runtime outputs only | 361,256,000 bytes modeled | Derivation propagation verified; generic large symlink-tree fixup stopped |
| `3dd7f892decb` | `uvwasi` | `libuv` runtime library; pkg-config/CMake metadata split to `.dev` | 154,992 bytes package closure | Full build, pkg-config test, layout and `ldd` |
| `2ffaa9775928` | `python3Packages.pydbus` | `pygobject3.out` | 69,681,080 bytes in real `uwsm` downstream closure | Full `pydbus` and `uwsm` builds, Python `pydbus` and `GLib` imports |
| `059eccf4c57c` | `cpptrace` | Shared library in `.out`; headers and CMake metadata in `.dev` | 5,541,448 bytes package closure | Unit suite plus shared and static CMake integration tests |
| `b36f6c0bea58` | `hyprland` | Unwrapped runtime binutils instead of compiler wrapper | 17,543,120 bytes dependency closure | Exact `nm` and `addr2line` calls against installed Hyprland; evaluated wrapper PATH |
| `178e51840e6b` | `mesa-libgbm` | `libdrm` runtime library without propagating `.dev` | 2,719,528 bytes across 64- and 32-bit package closures | Full builds for both architectures; native and 32-bit pkg-config C consumers |
| `6931a3995278` | `dms-shell` | Only fonts referenced by runtime QML | 50,234,120 bytes package closure | Isolated full build, Go tests, CLI checks, QML asset and translation checks |
| `cd83dddab918` | `khal` | `freezegun` only in the test environment | 217,984 bytes package closure | Isolated full build, 326 tests, dependency check, CLI version and help checks |
| `ef5e9104b515` | `xdg-desktop-portal` | Runtime GI typelibs without test-only `umockdev` | 2,860,824 bytes package closure | Same-revision comparison, 25 test groups, wrapper reference and linkage checks |
| `1b9ed0262ea5` | `xdg-desktop-portal` | Only the `wavparse` plugin from `gst-plugins-good` | 14,575,360 bytes package closure | Same-revision comparison, 25 test groups, all accepted sound formats in normal and sandboxed validators |
| `f5840cdacfde` | NixOS Podman module | Netavark without obsolete CNI executables | 74,715,888 bytes projected system closure | Module evaluation, override checks, Podman info plus bridge network create/inspect/remove |
| `8f396a55b1ad` | NixOS SDDM module | DRM/KMS and kiosk Weston features only | 29,806,960 bytes projected system closure | Clean-master build, module evaluation, ELF linkage, headless kiosk-shell launch |
| `5ca80c6a05a0` | `geoclue2` | Shared library and GI typelib without daemon and demo dependencies | 94,484,376 bytes in `xdg-desktop-portal` closure | Both package variants built; executable and library linkage, CLI, layout, references, and portal location integration tests |
| `eb8e6ef8e063` | `gvfs` | Client GIO modules and libraries without a second daemon/backend output | 3,255,328 bytes in full GNOME GVfs closure | Default and GNOME variants plus Online Accounts built; 128-ELF linkage pass, backend inventory, isolated D-Bus activation, volume monitors, and `trash:///` |
| `674be9b77154` | `flite` | Shared speech libraries without static archives | 31,439,832 bytes package closure | Full build, CLI linkage and synthesis, plus shared and static C consumers |
| `e43db7522212` | `libvpx` | Shared VP8/VP9 codec without its static archive | 5,207,608 bytes package closure | Full build, shared and static C consumers, library linkage, and GStreamer VPX plugin resolution |
| `1980384d46fd` | `libdovi` | Shared Dolby Vision library without headers, pkg-config metadata, or static archive | 10,373,160 bytes package closure | Full build, shared and static C parsing tests, layout, linkage, and libplacebo resolution |
| `2916cb691f00` | `resvg` | Renderer CLIs and shared C API without headers or static archive | 20,271,664 bytes package closure | Full build, both CLI versions, SVG-to-PNG rendering, linkage, and shared/static C API consumers |
| `7993840cd22f` | `simdjson` | Shared JSON parser without its single-header API and build metadata | 7,735,960 bytes package closure | Full build, linkage, C++ parsing consumer, and the running-system Node executable parsing JSON against the rebuilt library |
| `6ea86765db53` | `mbedtls` | Shared TLS libraries without tools, headers, metadata, or static archives | 12,186,000 bytes package closure | 139 upstream tests; tool self-test; shared/static C and CMake consumers; full librist and libajantv2 downstream builds with shared linkage |
| `ad831b0e483f` | `scx.rustscheds` | Release executables without unneeded outer ELF symbol tables | 28,888,616 bytes package closure | Transformed running output; all 20 executables report versions; every embedded BPF object section is byte-identical |
| `db6bc84a9d51` | LLVM 21 native and 32-bit | Shared LLVM runtime without static component archives | 709,366,872 bytes across both runtime outputs | Transformed cached outputs; native and 32-bit CMake targets plus static/shared `llvm-config` modes; full LLVM rebuild intentionally skipped |
| `00be33094331` | `ayugram-desktop` | Runtime executable without local ELF symbols | 160,802,896 bytes package closure | Exact same-revision final-wrapper build; runtime references, linkage, and version-mode launch |
| `7fa352de56e8` | `codex` | Main CLI and code-mode host without local ELF symbols | 91,439,664 bytes package closure | Transformed running output; version, help, completions, and linkage; full Rust/V8 rebuild intentionally skipped |
| `be370e471ce1` | `zed-editor` | Editor and CLI without local ELF symbols | 56,786,608 bytes package closure | Transformed running output; version, help, and linkage; full build intentionally skipped |
| `0dd4066ec40a` | `deno` | Runtime executable and libraries without local ELF symbols | 52,149,576 bytes package closure | Transformed running output; version, TypeScript evaluation, wrapper execution, and linkage; full build intentionally skipped |
| `f27e6ea2ac0e` | Qt Declarative | Runtime libraries and tools without nine private static-only modules | 44,371,000 bytes package closure | Full exact-revision build; final-layout transform; all nine CMake packages, runtime tools, and linkage |

### Important overlap notes

- The current Node executable independently embeds many dependency include
  paths, including `libuv.dev`; therefore the `uvwasi` saving is masked in the
  current whole-system closure until the Node case is resolved.
- Many large development closures shown by `nix path-info -S` share the same
  GTK, Qt, systemd, and compiler dependencies. Do not sum table rows to predict
  the system result.

## Direct runtime-to-development edge inventory

This inventory comes from the running closure by finding every immediate
reference from a non-`-dev` output to a `-dev` output. It is the first audit
pass, not the definition of all possible closure waste.

### Fixed on the nixpkgs branch

- [x] `tlp-pd` -> `pygobject`, `dbus-python`, GLib/introspection development outputs
- [x] `zed-editor` -> `livekit-libwebrtc.dev`
- [x] `mpv-with-scripts` -> `mpv.dev`
- [x] `libappimage` -> cairo, GLib, librsvg, and zlib development outputs
- [x] `papirus-icon-theme` -> Breeze and hicolor development outputs
- [x] `uvwasi` -> `libuv.dev`
- [x] `pydbus` -> `pygobject.dev`
- [x] `cpptrace` -> `zstd.dev`
  - Directly selecting `zstd.out` would have broken downstream CMake package
    discovery. Splitting cpptrace preserves development propagation in
    `cpptrace.dev` while leaving its shared runtime output clean.
- [x] `glibc-iconv` -> `glibc.dev`
  - `glibc-iconv` is only an `iconv.h` compatibility symlink. The system reaches
    it through the old TLP/PyGObject development chain, which the TLP fix
    removes. No independent package change is needed.
- [x] `binutils-wrapper` -> `glibc.dev`
  - Hyprland needs `nm` for plugin symbol lookup and `addr2line` for crash
    reports, not the compiler/linker wrapper. Both exact invocations work from
    `binutils-unwrapped`, whose closure has no development outputs.
- [x] Both `mesa-libgbm` variants -> `libdrm.dev`
  - `gbm.pc` has no `Requires` entry, and the public headers do not include
    libdrm headers. Keeping libdrm as a non-propagated build input preserves
    the ELF dependency and RUNPATH while removing development outputs.
- [x] Steam and `steam-run` FHS root filesystems -> `libdrm.dev`
  - Both root filesystems include 64- and 32-bit `mesa-libgbm`; their symlink
    trees followed its propagated libdrm input. The `mesa-libgbm` fix removes
    this edge without changing Steam's package set.
- [x] Python `withPackages` environment -> `pygobject.dev`
  - A rebuilt real `uwsm` environment after the `pydbus` fix contains no
    development outputs, so no separate environment change is needed.

### Investigation queue

- [ ] `nodejs-slim` -> development outputs for zstd, brotli, llhttp, nghttp2,
  nghttp3, ngtcp2, c-ares, ICU, zlib, SQLite, OpenSSL, libuv, and gtest.
  - Current cause: absolute include paths embedded in `bin/node` via
    `process.config`.
  - Native addon and `node-gyp` behavior must remain functional. Do not erase
    these strings without a replacement and addon tests.
- [ ] `protobuf` -> `abseil-cpp.dev`.
  - Confirmed cause: protobuf is a single output containing `protoc`, shared
    libraries, headers, pkg-config/CMake metadata, and
    `propagatedBuildInputs = [ abseil-cpp ]`.
  - Commit `896367a13908` adds a `dev` output so public development files and
    Abseil propagation move away from runtime binaries and libraries.
  - Status: committed explicitly as untested. The full package build was
    stopped on request at 35%, before producing installable outputs; it still
    needs package and downstream C++ validation before acceptance.

### Explicitly retained for now

- Node development include paths: retained until native-addon behavior can be
  preserved and tested. Removing raw store references would be a functional
  regression, not a valid closure reduction.
- Qt/DBus development metadata: retained because the sole reference is
  `mkspecs/qmodule.pri`'s `QMAKE_INCDIR_DBUS`. qmake dynamically consumes this
  value for projects using `QMAKE_USE += dbus`; deleting it would break that
  supported development contract. After the Papirus fix removes the separate
  `breeze-icons.dev -> qtsvg.dev -> qtbase.dev` chain, the maximum remaining
  saving would be only the 129,191-byte `dbus.dev` output because D-Bus runtime
  outputs are already required elsewhere.

## Broader audit passes

The direct `-dev` edge pass is only the start. Complete all of these before
calling the hunt exhaustive:

- [ ] Recompute direct runtime-to-development edges with all accepted fixes
  overlaid together.
- [x] Rank unique closure contribution of user and system package roots, not
  just their inclusive closure sizes.
  - Ranked all 174 `/run/current-system/sw` roots and all direct system roots.
    The latter exposed the obsolete Podman CNI bundle. The other large unique
    roots are firmware, kernel assets, enabled services, or the local nixpkgs
    source used by the offline-capable flake registry.
  - Ranked all 152 system-unit roots as well. This exposed SDDM's full Weston
    feature closure; the remaining leading service payloads are the Home
    Manager generation, functional daemons, or boot/runtime tooling.
- [ ] Scan runtime outputs for embedded store references to compilers, source
  trees, SDKs, static libraries, and build tools whose names do not end in
  `-dev`.
- [ ] Inspect single-output libraries that mix shared runtime libraries with
  headers, CMake/pkg-config files, and static archives.
  - Split GeoClue's shared library and GI typelib from its daemon and demos.
    Library-only consumers such as xdg-desktop-portal no longer retain
    ModemManager and its mobile-broadband libraries. GeoClue itself and the
    configured demo agent retain their full daemon functionality.
  - Split GVfs client modules and libraries from its daemon and backend output.
    GNOME Online Accounts still receives the GIO integration needed for
    OwnCloud and Google Drive, but full GNOME GVfs no longer closes a package
    cycle by retaining a second complete non-GNOME GVfs build.
  - Moved Flite's 13 static archives from its existing `lib` output to `dev`.
    WebKitGTK and therefore Tumbler's EPUB thumbnailer retain every shared
    speech library, while static consumers continue to work through the
    development output.
  - Moved libvpx's static archive to its existing `dev` output. The portal's
    GStreamer VPX plugin retains the shared codec library, and both public
    shared and static development interfaces remain usable.
  - Added a `dev` output to libdovi for its header, pkg-config file, and static
    archive. MPV's libplacebo dependency retains only the shared Dolby Vision
    parser at runtime, while both C linking modes remain supported.
  - Added a `dev` output to resvg for its C/C++ headers and static library. Yazi
    retains both renderer CLIs and the shared C API, while development users
    retain shared and static linking support.
  - Added a `dev` output to simdjson for its 7.7 MB single-header API, CMake
    package, and pkg-config metadata. Node retains only the shared parser at
    runtime, while a C++ consumer continues to compile and parse JSON through
    the development output.
  - Split Mbed TLS into shared runtime, tools, development, and static outputs.
    Its pkg-config and CMake interfaces retain explicit shared and static
    linking, while Steam's transitive librist and libajantv2 consumers retain
    only the shared libraries.
- [ ] Inspect propagated inputs of Python, Perl, and other language packages for
  build-only outputs retained by application environments.
- [ ] Inspect wrapper-generated `PATH`, `GI_TYPELIB_PATH`, `QT_PLUGIN_PATH`,
  `XDG_DATA_DIRS`, and RPATH values for overly broad `.all` or `.dev` outputs.
  - Removed test-only `umockdev` from xdg-desktop-portal's generated
    `GI_TYPELIB_PATH`; its full build-time test suite still uses the dependency.
  - Replaced xdg-desktop-portal's full `gst-plugins-good` wrapper path with a
    minimal output containing `libgstwavparse.so`. WAV/PCM, Ogg/Vorbis, and
    Ogg/Opus remain accepted both normally and by the sandboxed validator.
  - Confirmed that xdg-desktop-portal's GeoClue dependency is functional, not
    an over-broad wrapper input: location support is enabled and its integration
    test passes. Splitting GeoClue instead lets the portal retain only the
    shared client library and typelib.
- [ ] Check optional runtime features that pull duplicate implementations or
  interpreters while preserving all enabled functionality.
- [ ] Build a final system using the fixes without changing the nixpkgs baseline
  revision, then compare exact closure sets and byte counts.

### Initial unique profile-root ranking

These are bytes retained by exactly one of the 174 direct roots in
`/run/current-system/sw`. They identify high-impact roots without double
counting shared libraries.

| Root | Unique bytes | Initial classification |
| --- | ---: | --- |
| `scx_rustscheds` | 223,029,832 | Scheduler executables; inspect binary composition |
| `tumbler` | 209,472,624 | Mostly WebKitGTK for EPUB cover thumbnails; inspect plugin linkage |
| `dms-shell` | 179,913,080 | 50,234,120-byte unused-font fix committed |
| `gvfs` | 128,283,248 | Enabled backends retained; 3,255,328-byte duplicate-variant fix committed |
| `throne` | 73,120,568 | Inspect application payload |
| `sops` | 52,250,896 | Single Go executable |
| `tailscale` | 50,602,056 | Single application payload |
| `fish` | 44,365,472 | Runtime plus completion/function data |
| `khal` | 43,549,832 | 217,984-byte test-only `freezegun` fix committed; remaining dependencies support runtime or `khal configure` functionality |
| `docker-compose` | 29,282,128 | Single application payload |

## Working log

### 2026-07-16

#### Ten-iteration large-win sprint

| Iteration | Candidate | Status | Result |
| ---: | --- | --- | ---: |
| 1 | `mbedtls` mixed runtime output | Accepted | 12,186,000 bytes |
| 2 | Python mixed runtime/development output | Deferred | 68,380,759 native bytes plus 10,542,095 32-bit bytes; changing the core recipe triggers a 122-derivation bootstrap rebuild |
| 3 | Qt Declarative private static modules | Accepted | 44,371,000 bytes |
| 4 | LLVM static component libraries | Accepted | 709,366,872 bytes across native and 32-bit outputs |
| 5 | `scx_rustscheds` ELF symbol tables | Accepted | 28,888,616 bytes |
| 6 | Protobuf mixed runtime/development output | Committed, untested | 5,668,328 prototype package bytes plus the uniquely retained 4,242,464-byte Abseil development output |
| 7 | AyuGram executable symbol tables | Accepted | 160,802,896 bytes |
| 8 | Codex executable symbol tables | Accepted | 91,439,664 bytes |
| 9 | Zed executable symbol tables | Accepted | 56,786,608 bytes |
| 10 | Deno runtime symbol tables | Accepted | 52,149,576 bytes |

- Qt 6 deliberately keeps most development files in its runtime output because
  generated CMake packages assume that their headers and libraries share one
  prefix. The Qt Declarative fix therefore moves only nine private, static-only
  modules, each together with its archive, headers, metatypes, resource objects,
  and CMake package. The exact running-revision build completed all 3,859 build
  steps in 56 minutes 20 seconds; `qml` and `qmllint` report version 6.11.1 and
  have complete linkage. A final-layout transform caught and fixed QmlLS's
  runtime plugin prefix, then all nine private CMake packages resolved their
  archives, headers, metatypes, resource objects, and plugin from the correct
  output. The runtime NAR falls from 184,457,856 to 140,086,856 bytes, an exact
  44,371,000-byte reduction. Commit `f27e6ea2ac0e` applies the split.
- Eight accepted wins in this sprint now total 1,155,991,232 exact package-output
  bytes. This is not yet a whole-system measurement and does not include the
  deferred Python candidate or the Protobuf candidate still under validation.
- The native and 32-bit LLVM `lib` outputs contain 371,624,182 and 337,658,370
  bytes of static archives respectively. Prototype `static` outputs reduce the
  two runtime NARs by 371,666,344 and 337,700,528 bytes. LLVM's exported CMake
  targets resolve from the new output, and a prototype `llvm-config` wrapper
  preserves both `--link-static` and `--link-shared`. Commit `db6bc84a9d51`
  applies that design for shared-library builds while excluding Windows import
  archives. LLVM itself has `requiredSystemFeatures = [ "big-parallel" ]`; its
  full rebuild is intentionally skipped on this machine, as with the recorded
  Zed binary fix.
- `scx_rustscheds` is a 223,029,832-byte unique profile root. Its release
  executables contain no debug sections but retain full outer ELF symbol tables.
  Applying `strip --strip-all` to `bin` reduces its NAR by 28,888,616 bytes;
  all 20 executables still report their versions, and every `.bpf.objs` section
  is byte-for-byte identical. Commit `ad831b0e483f` applies the standard stdenv
  `stripAllList` mechanism to the package's executable directory.
- The running Protobuf output mixes its shared libraries and `protoc` with
  headers, its static upb archive, CMake and pkg-config metadata, and propagated
  Abseil development files. Android Tools is the only live system path to this
  Protobuf build, and Protobuf is the only live path to that Abseil development
  output. A transformed same-revision prototype reduces Protobuf's runtime NAR
  from 19,857,296 to 14,188,968 bytes and removes the uniquely retained
  4,242,464-byte Abseil development output, for a projected 9,910,792-byte
  system win. Shared Protobuf and static upb prototype consumers passed, and
  both the default and static package variants evaluate. The real package build
  was stopped on request at 35%; no final outputs, package consumer, or Android
  Tools downstream were validated. Commit `896367a13908` is therefore recorded
  explicitly as untested and is not counted among the eight accepted wins.
- The SOPS installation helper is also unstripped, but stripping its conventional
  ELF symbol tables saves only 7,488,160 bytes. Its recipe belongs to the
  external `sops-nix` input rather than nixpkgs, so it remains a later candidate
  after the larger in-tree mixed-output fixes.
- AyuGram's final wrapper output copied a 337,579,312-byte executable with full
  ELF symbol and string tables. Stripping that final output preserves the exact
  runtime-reference set while reducing its NAR from 337,761,936 to 176,959,040
  bytes. The exact same-revision wrapper build, linkage check, and version-mode
  launch passed. Commit `00be33094331` applies the final-output strip without
  rebuilding or changing Telegram Desktop itself.
- Codex's main executable and code-mode host retain 75,605,336 and 15,834,328
  bytes of conventional ELF symbols. A transformed running output is exactly
  91,439,664 NAR bytes smaller and passes version, help, shell-completion, and
  linkage checks. Commit `7fa352de56e8` strips both via the standard fixup hook;
  the full Rust and V8 rebuild is intentionally skipped on this machine.
- Zed's wrapped editor and CLI retain 56,223,720 and 562,888 bytes of
  conventional ELF symbols. The transformed running output passes version,
  help, and linkage checks and has an exact 56,786,608-byte NAR reduction.
  Commit `be370e471ce1` strips the
  package's editor, CLI, and remote-server executable directories; the full Zed
  build remains intentionally skipped as requested.
- Deno's executable and `libdenort.so` retain 28,426,072 and 23,616,264 bytes
  of conventional ELF symbols; its `dx` wrapper and leftover test FFI library
  add 107,240 bytes. The transformed running output is exactly 52,149,576 NAR
  bytes smaller; version reporting, TypeScript evaluation, wrapper execution,
  and linkage checks pass. Commit `0dd4066ec40a` strips both runtime directories;
  the package's source build can take four hours and is intentionally skipped.

- Established a 19,539,003,424-byte running-system baseline.
- Traced the initial high-impact paths with `nix why-depends --precise`.
- Created seven focused nixpkgs commits listed above.
- Enumerated immediate non-development to development-output edges in the
  running closure.
- Split cpptrace runtime and development files after validating both shared and
  static CMake consumers; this added an eighth focused nixpkgs commit.
- Replaced Hyprland's runtime compiler wrapper with unwrapped binutils after
  validating its plugin-symbol and crash-symbolizer commands; this added a
  ninth focused nixpkgs commit.
- Stopped `mesa-libgbm` from propagating libdrm development files after full
  64- and 32-bit builds and pkg-config consumer tests; this also resolves the
  Steam FHS rootfs edges and adds a tenth focused nixpkgs commit.
- Confirmed the rebuilt `uwsm` Python environment is clean after the `pydbus`
  fix, so it needs no separate package change.
- Rejected stripping D-Bus include paths from Qt's installed qmake metadata:
  the path is consumed by `QMAKE_USE += dbus`, while the post-Papirus saving is
  limited to the 129,191-byte development output.
- Ranked the 174 direct system-profile roots by unique closure contribution and
  used the result to find 17 unused Nerd Font variants plus a web-only Material
  Symbols font in `dms-shell`. Their removal passed an isolated full build and
  tests and adds an eleventh focused nixpkgs commit.
- Removed test-only `freezegun` from Khal's runtime Python environment while
  retaining it in `nativeCheckInputs`. An isolated build passed 326 tests and
  removed only the 217,984-byte freezegun store path, adding a twelfth focused
  nixpkgs commit.
- Filtered test-only `umockdev` from xdg-desktop-portal's generated runtime
  wrapper while retaining it for compilation and tests. The same-revision
  closure lost `umockdev`, libpcap, and libnl (2,860,824 bytes total), and 25
  test groups passed with 2 FUSE-dependent groups skipped. This adds a
  thirteenth focused nixpkgs commit.
- Reduced xdg-desktop-portal's runtime GStreamer plugin path from all of
  `gst-plugins-good` to the one `wavparse` plugin its sound validator needs.
  The same-revision closure is 14,575,360 bytes smaller; 25 test groups passed,
  and every accepted sound format passed both normal and sandboxed validation.
  This adds a fourteenth focused nixpkgs commit.
- Ranked direct system roots outside the package profile. This exposed a
  74,715,816-byte CNI executable bundle retained by `containers.conf` even
  though Podman 5 has removed its CNI backend and the module selects Netavark.
  Podman now defaults to no CNI plugins while common-container users and user
  overrides retain them. The projected system saving is 74,715,888 bytes after
  accounting for the regenerated config, adding a fifteenth focused commit.
- Retained the nixpkgs source referenced by the system flake registry: replacing
  it with a remote URL would lose the current offline `nixpkgs` registry
  behavior rather than remove an unused dependency.
- Replaced SDDM's full Weston build with an internal kiosk variant retaining
  DRM/KMS, OpenGL, input, and the kiosk shell. It omits unrelated remote,
  nested, desktop, demo, and development surfaces. A clean-master build and a
  live headless kiosk-shell launch passed; substituting it into the running
  closure projects an exact 29,806,960-byte saving. This adds a sixteenth
  focused nixpkgs commit.
- Inspected the next-largest unique system-unit payload,
  `automatic-timezoned`. Its 16,432,184-byte output is the daemon executable
  itself, not a wrapper-retained or test-only dependency, so it remains.
- Confirmed protobuf as a single-output development/runtime mixing candidate;
  deferred its expensive rebuild while cheaper candidates remain.
- Split GeoClue's shared client library and typelib from the daemon and demos.
  Both the default and demo-agent variants build and run their CLI entry points,
  while xdg-desktop-portal's complete test suite, including location, passes.
  Its same-revision closure is 94,484,376 bytes smaller because library-only
  consumers no longer retain ModemManager. This adds a seventeenth focused
  nixpkgs commit.
- Rejected removing GeoClue from xdg-desktop-portal: location support is enabled
  and tested on this system, so removal would disable functionality.
- Found two GVfs variants in the running closure. Full GNOME GVfs depends on
  GNOME Online Accounts, whose GIO wrapper in turn retained a second complete
  GVfs for its client modules. Splitting those client modules and libraries
  preserves every backend and Online Accounts integration while reducing the
  same-master full-GVfs closure by exactly 3,255,328 bytes. Both variants and
  Online Accounts built; 128 ELF files resolved, and an isolated D-Bus session
  activated the daemon and all configured volume monitors. This adds an
  eighteenth focused nixpkgs commit.
- Ranked development artifacts still mixed into non-development outputs across
  the whole closure. Flite's runtime `lib` output contained 31,437,188 bytes of
  static archives and is reached through WebKitGTK and Tumbler. Moving them to
  the existing `dev` output reduces the package closure by exactly 31,439,832
  bytes; the CLI synthesized text and both shared and static C consumers passed.
  This adds a nineteenth focused nixpkgs commit.
- Continued that ranked pass with libvpx, whose runtime output mixed its shared
  codec with a 5,207,422-byte static archive. Moving the archive to `dev`
  reduces the package closure by exactly 5,207,608 bytes. Shared and static C
  consumers report v1.16.0, and the existing GStreamer VPX plugin resolves
  against the rebuilt shared library. This adds a twentieth focused commit.
- Split libdovi's header, pkg-config metadata, and 10,353,182-byte static
  archive into a new `dev` output. The package closure falls by exactly
  10,373,160 bytes; shared and static C consumers returned the expected parser
  error, and libplacebo resolves against the reduced shared output. This adds a
  twenty-first focused commit.
- Split resvg's C/C++ headers and 20,243,188-byte static library into a new
  `dev` output. Yazi's runtime renderer remains in `out`; both CLIs report
  0.47.0, an SVG stream renders to a valid PNG, and shared and static C API
  consumers pass. The exact package closure reduction is 20,271,664 bytes,
  adding a twenty-second focused commit.
- Split simdjson's 7.7 MB single-header API and build metadata into a new `dev`
  output. A C++ consumer parsed JSON with the rebuilt shared library, and the
  running-system Node executable resolved that library and parsed JSON. The
  exact package closure reduction is 7,735,960 bytes, adding a twenty-third
  focused commit.
- Split Mbed TLS into shared runtime, tool, development, and static outputs.
  All 139 upstream tests passed; direct shared/static C and CMake consumers
  worked; and rebuilt librist and libajantv2 consumers retained only shared
  libraries. The exact package closure reduction is 12,186,000 bytes, adding a
  twenty-fourth focused commit and completing iteration 1 of the large-win
  sprint.
- Investigated Python's 66,378,314-byte native static archive and 8,539,644-byte
  32-bit archive. A shared-build-only `--without-static-libpython` change keeps
  nixpkgs' explicit static Python variant available, but rebuilding the core
  recipe invalidates 122 bootstrap derivations including GCC and glibc. The
  build was stopped and the uncommitted patch removed; this high-value candidate
  is deferred for stronger hardware or binary-cache coverage.
- Classified `glibc-iconv` as a development-only compatibility header reached
  through the already-fixed TLP chain, requiring no separate change.
- Continued the second pass with Node, Steam/Mesa, Qt, glibc wrappers, protobuf,
  and rebuilt Python environments still to classify.
