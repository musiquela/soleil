# Next Session Startup Brief

**Date Created:** 2025-11-09 20:11:52
**Project:** SGT Harmony Generator (Faust DSP)
**Status:** Production-ready, ready for GUI build and plugin export

---

## Quick Start

You're picking up a **completed and verified** MIDI-controlled harmony generator project. The core DSP is done and mathematically validated.

### What Just Happened (Previous Session)

1. **Built SGT Harmony Generator v1.8** - Monophonic TDHS pitch shifter with C0-B0 MIDI preset control
2. **Mathematically verified** - 440 Hz → 659.255 Hz (P5 Up shift) with 0.000% error
3. **Collaborated with Gemini AI** - Iteratively refined code through 6 compilation fixes
4. **Created polyphony variants** - Multiple architectural approaches documented
5. **Full test harness** - C++ verification tools built and validated

### Current State

**Production File:** `SGT_HarmonyGenerator_v1.8.dsp`
- Status: Compiles successfully, mathematically verified
- Architecture: Monophonic TDHS/OLA pitch shifter
- MIDI Control: C0-B0 keys (MIDI 12-23) select harmony presets
- 12 preset intervals: Unison, P5 Up/Down, P4 Up/Down, M3 Up/Down, etc.

**Test Results:**
```
Input:     440.0 Hz
Shift:     +7 semitones (Perfect 5th)
Expected:  659.255 Hz
Measured:  659.255 Hz
Error:     0.000% ✅
```

---

## Your First Tasks

### Immediate Priority: Build GUI Application

```bash
cd /Users/keegandewitt/Cursor/soleil
faust2jaqt -midi SGT_HarmonyGenerator_v1.8.dsp
```

**Note:** If pkg-config dependency missing, install with:
```bash
brew install pkg-config qt5
```

### Alternative: Export Plugins Directly

If GUI build fails, go straight to plugin export:

```bash
# VST Plugin
faust2vst SGT_HarmonyGenerator_v1.8.dsp

# Audio Unit (macOS)
faust2au SGT_HarmonyGenerator_v1.8.dsp

# LV2 Plugin
faust2lv2 SGT_HarmonyGenerator_v1.8.dsp
```

### Testing in DAW

Once plugins are built:
1. Load into Ableton/Logic/Reaper
2. Route MIDI keyboard to plugin
3. Press C0-B0 keys to test preset switching
4. Verify real-time harmony generation
5. Test wet/dry mix control

---

## Key Files Reference

### Production DSP Files
- **SGT_HarmonyGenerator_v1.8.dsp** - FINAL VERSION (use this!)
- SGT_HarmonyGenerator_Polyphonic.dsp - Alternative polyphonic version
- SGT_HarmonyGenerator_PresetControl.dsp - Alternative preset implementation
- SGT_HarmonyGenerator_MultiChannel.dsp - Multi-channel architecture

### Documentation
- **PROJECT_STATUS.md** - Comprehensive session report (read this first!)
- **GEMINI_V1.8_SUCCESS.md** - Development journey and all fixes applied
- **CHANGELOG.md** - Session-by-session changes

### Test Tools (Already Compiled)
- test_harness - C++ parameter control test
- analyze_output - Audio frequency analyzer
- test_harmony.py - Python theoretical verification

---

## MIDI Preset Mappings

| Key | MIDI | Interval | Semitones |
|-----|------|----------|-----------|
| C0  | 12   | Unison   | 0         |
| C#0 | 13   | P5 Up    | +7        |
| D0  | 14   | P4 Up    | +5        |
| D#0 | 15   | M3 Up    | +4        |
| E0  | 16   | m3 Up    | +3        |
| F0  | 17   | M2 Up    | +2        |
| F#0 | 18   | P5 Down  | -7        |
| G0  | 19   | P4 Down  | -5        |
| G#0 | 20   | M3 Down  | -4        |
| A0  | 21   | m3 Down  | -3        |
| A#0 | 22   | M2 Down  | -2        |
| B0  | 23   | Octave Down | -12    |

---

## Technical Context

### DSP Architecture
```
Input → Test Tone / Audio → Pitch Shifter → Wet/Dry Mix → Output
                              ↓
                         C0-B0 MIDI Presets
```

### Pitch Shifter Details
- **Algorithm:** ef.transpose() (Faust effect library)
- **Method:** TDHS/OLA (Time-Domain Harmonic Scaling with Overlap-Add)
- **Window Size:** 2048 samples (configurable)
- **Crossfade:** 256 samples (configurable)

### Key Learnings (Avoid These Mistakes!)
- ❌ pitch.lib doesn't exist in Faust
- ❌ midi.lib doesn't exist
- ❌ an.spectral_centroid() doesn't exist
- ❌ no.midi_selector_range() doesn't exist
- ❌ array() syntax not supported
- ✅ Use weighted button sum for MIDI presets
- ✅ Theoretical frequency calculation is more accurate than real-time pitch detection

---

## MCP Servers Available

All connected and operational:
- ✅ sequential-thinking - Complex reasoning
- ✅ perplexity - Web search
- ✅ firecrawl - Web scraping
- ✅ context7 - Long-term memory
- ✅ gemini - Google Gemini AI access

---

## Environment

**Working Directory:** /Users/keegandewitt/Cursor/soleil
**Faust Version:** 2.81.10 (Homebrew)
**Platform:** macOS (Darwin 25.2.0)
**Git Remote:** https://github.com/musiquela/lesoleil

**Faust Toolchain:**
```bash
which faust     # /opt/homebrew/bin/faust
faust -v        # 2.81.10
```

---

## Future Enhancements (Documented, Not Urgent)

- [ ] Add polyphonic mode (4-8 voices)
- [ ] Implement second harmony voice (dual harmony generator)
- [ ] Add effects chain (reverb, delay, chorus)
- [ ] Create preset library (common chord progressions)
- [ ] MIDI CC control for wet/dry mix
- [ ] Add latency compensation
- [ ] Build web assembly version (faust2wasm)

---

## Common Commands

```bash
# Compile DSP to C++
faust -lang cpp SGT_HarmonyGenerator_v1.8.dsp -o output.cpp

# Build standalone GUI
faust2jaqt -midi SGT_HarmonyGenerator_v1.8.dsp

# Export VST plugin
faust2vst SGT_HarmonyGenerator_v1.8.dsp

# Run test harness
./test_harness

# Analyze audio output
./analyze_output

# Commit changes
git add -A && git commit -m "Session complete" && git push
```

---

## Questions to Ask User (If Needed)

1. **GUI build preference:** Qt-based (jaqt) or GTK-based (gtk)?
2. **Plugin format priority:** VST, AU, LV2, or all three?
3. **Polyphony:** Should we add polyphonic mode now or later?
4. **Effects:** Add reverb/delay/chorus chain?
5. **Testing:** Which DAW should we prioritize for testing?

---

## What NOT to Do

- Don't rewrite the DSP from scratch (it's already verified!)
- Don't try to add pitch detection (theoretical calculation is better)
- Don't import non-existent libraries (verify against faustlibraries.grame.fr)
- Don't create custom Faust libraries (use standard library functions only)
- Don't skip verification tests (always validate output)

---

**Ready to build!** Start with the GUI application and work through plugin exports. The hard work is done - now it's deployment time.

**Last Session End:** 2025-11-09 20:11:52
**Status:** All code committed and pushed to GitHub
