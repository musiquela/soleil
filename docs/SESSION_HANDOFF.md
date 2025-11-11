# Soleil - Session Handoff Documentation

**Last Updated:** 2025-11-11 07:30 AM
**Session Status:** ✅ COMPLETE
**Git Branch:** main
**Last Commit:** ac1fcae - feat: Soleil v1.2 - Low latency optimization + enable/disable controls

---

## Current Session Summary

**Session 3 Accomplishments:**
- ✅ Removed Window/Crossfade UI sliders (now hard-coded at 384/96 samples)
- ✅ Optimized for low latency: ~8ms at 48kHz (down from ~42ms)
- ✅ Added Enable checkboxes for all three voices (Root, Harmony 1, Harmony 2)
- ✅ Renamed "Gain" to "Mix" for all controls
- ✅ Reorganized UI hierarchy: Root now appears first with dedicated controls
- ✅ Cleaned builds folder (removed old development versions)
- ✅ Created custom Qt architecture file for window sizing attempts
- ✅ Updated build script to use custom architecture

**Current Version:** v1.2
- **Location:** `Soleil_v1.2.dsp`
- **Built App:** `builds/apps/Soleil_v1.2.app`

---

## Git Status

```
On branch: main
Last commit: ac1fcae
Working tree: clean
```

**Recent Commits:**
```
ac1fcae feat: Soleil v1.2 - Low latency optimization + enable/disable controls
10b3244 docs: Update session handoff (Session 2 complete)
10789d3 docs: Update /handoff command to include push step
```

---

## Active Work

### Current UI Structure (v1.2)
```
[0] Root
  - Enable (checkbox)
  - Mix (slider)

[1] Harmony 1
  - Enable (checkbox)
  - Interval (dropdown: Unison to 2 Octaves, ±24 semitones)
  - Mix (slider)

[2] Harmony 2
  - Enable (checkbox)
  - Interval (dropdown: same range as H1)
  - Mix (slider)
```

### Technical Parameters
- **Pitch Shifter:** `ef.transpose(window_size, xfade_size, shift_semitones)`
- **Window Size:** 384 samples (~8ms at 48kHz) - HARD-CODED
- **Crossfade Size:** 96 samples (~2ms at 48kHz) - HARD-CODED
- **Default Intervals:** H1=Octave (+12), H2=P5 (+7)
- **Default Mix:** All voices at 0.33

---

## Next Session Tasks

### Immediate Priorities

1. **PRESET SYSTEM** (discussed but not implemented)
   - **Preset Level:** Save/recall Root, H1, H2 settings (Enable + Interval + Mix)
   - **Scene Level:** Collections of up to 4 presets per scene
   - **Control:** Both GUI and MIDI
   - **Save Method:** Manual save only (not auto-save)
   - Faust has built-in preset support via `-preset` flag in faust2caqt

2. **Hardware Integration Planning**
   - Daisy Seed-based guitar pedal (50 unit production run)
   - 6 footswitches: 4 for presets (A-D), 2 for scene navigation
   - OLED display + rotary encoder with push button
   - MIDI communication between pedal and Soleil plugin

3. **Plugin Versions** (attempted but blocked)
   - VST3 build failed (missing VST SDK paths)
   - AU build failed (Faust path issues)
   - Consider LV2 or focus on standalone + MIDI for now

### Known Issues

1. **Window Sizing** (de-prioritized)
   - Qt window opens slightly too small, cutting off bottom controls
   - Custom architecture file `ca-qt-custom.cpp` created but hardcoded size (520x850) not effective
   - Qt's `adjustSize()` and scroll area sizing not working as expected
   - **Decision:** Moved on to focus on presets instead

2. **Build Tools**
   - faust2vst/faust2au have path configuration issues
   - May need VST SDK installation or environment variable fixes

---

## Recently Modified Files

```
Soleil_v1.2.dsp              - NEW: Main DSP with v1.2 optimizations
ca-qt-custom.cpp             - NEW: Custom Qt architecture (window sizing attempts)
scripts/build-release.sh     - MODIFIED: Uses custom architecture, defaults to v1.2
builds/apps/Soleil_v1.2.app  - Built application (not in git)
```

**Preserved Files:**
```
Soleil_v1.0.dsp              - Original release
Soleil_v1.1.dsp              - Interval dropdowns version
builds/apps/Soleil_v1.0.app
builds/apps/Soleil_v1.1.app
```

---

## Implementation Notes for Future Sessions

### Preset System Architecture (Discussed)
Based on Faust documentation, use faust2caqt's built-in preset manager:
```bash
faust2caqt -preset "$HOME/Library/Application Support/Soleil/Presets" Soleil_v1.2.dsp
```

This adds automatic GUI controls for:
- Save current state as named preset
- Load preset
- Delete preset
- Browse presets

**For 2-level system (Scenes + Presets):**
- May need custom implementation beyond Faust's built-in presets
- Consider file-based approach: `Scenes/Scene1/PresetA.json`
- MIDI integration for pedal control

### Hardware Pedal Spec Summary
- Platform: Daisy Seed (STM32-based DSP)
- Enclosure: Hammond 1590BB
- Controls: 6 footswitches, 1 encoder w/ push, OLED display
- Audio: 4× 1/4" TS jacks, 2× 3.5mm MIDI TRS
- Power: 9V DC barrel jack (center-negative)
- Estimated cost: $1,153-2,070 for 50 units (components only)

---

## Build Instructions

**Standard Build (v1.2):**
```bash
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
./scripts/build-release.sh --no-sign
```

**With Code Signing:**
```bash
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
./scripts/build-release.sh
```

**With Notarization:**
```bash
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
./scripts/build-release.sh --notarize
```

**Output:** `builds/apps/Soleil_v1.2.app`

---

## Testing Checklist

- [ ] All three voices produce audio when enabled
- [ ] Enable checkboxes properly mute voices when unchecked
- [ ] Interval dropdowns change pitch correctly
- [ ] Mix sliders control individual voice levels
- [ ] No clicks/pops when adjusting controls
- [ ] Low latency feels responsive (target: <10ms)
- [ ] Default settings produce "power chord" (Root + Octave + P5)

---

## Resources

**Faust Documentation:**
- Preset system: `faust2caqt -preset` flag
- Metadata: Widget labels support `[key:value]` syntax
- Libraries: `ef.transpose()` from misceffects.lib

**Project Files:**
- Main DSP: `Soleil_v1.2.dsp`
- Build script: `scripts/build-release.sh`
- Custom architecture: `ca-qt-custom.cpp`

**Hardware Reference:**
- Pedal image: `/Users/keegandewitt/Library/Messages/Attachments/.../soleil_pedal.png`
- Component spec: In SESSION_HANDOFF.md (this file)

---

## Session End Notes

This session focused on UI refinement and performance optimization. The plugin now has clean enable/disable controls for each voice and significantly reduced latency. Window sizing issues were deprioritized in favor of implementing the preset system, which is the critical next feature for live performance use.

The hardware pedal specification is well-defined and ready for implementation once the preset system is in place.
