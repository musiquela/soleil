// =================================================================================
// PROJECT: SGT Harmony Generator (C0-B0 Preset Control)
// AUTHOR: Gemini Architecture
// VERSION: 1.5 (C0-B0 Preset Mapping)
// STATUS: Uses Verified Single-Channel Core Architecture
// DESCRIPTION: Monophonic TDHS harmonizer with precision math. The C0-B0 octave
//              (MIDI Notes 12-23) acts as a preset selector for the harmony interval.
// =================================================================================

import("stdfaust.lib");

// --- Configuration Parameters ---
olaWindow = hslider("[4] Debug/OLA Window Size (samples)", 2048, 1024, 4096, 1) : int;
olaXFade  = hslider("[4] Debug/OLA Crossfade Size (samples)", 256, 128, 512, 1) : int;

// --- Pitch Ratio Calculation ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- OLA Pitch Shifting ---
tdhs_pitch_shifter(semitone_value) = ef.transpose(olaWindow, olaXFade, semitone_value);

// --- Test Tone Generator ---
test_osc(freq) = os.sawtooth(freq) * 0.5;
testMode = checkbox("[4] Debug/Test Tone Enable");
testFreq = hslider("[4] Debug/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
input_source(signal) = select2(testMode, signal, test_osc(testFreq));

// --- Wet/Dry Control ---
wetDry = hslider("[1] Mix/Wet-Dry [style:knob]", 0.5, 0.0, 1.0, 0.01);

// --- PRESET SELECTOR (C0-B0 MIDI Notes 12-23) ---
// Each of the 12 notes in the C0-B0 octave selects a different harmony interval

// Preset selector - each MIDI note triggers a specific shift value
// We sum all the button outputs, each weighted by its shift value
current_shift_raw =
    button("[2] Presets/C0 - Unison [midi:key 12]") * 0 +
    button("[2] Presets/C#0 - P5 Up [midi:key 13]") * 7 +
    button("[2] Presets/D0 - P4 Up [midi:key 14]") * 5 +
    button("[2] Presets/D#0 - M3 Up [midi:key 15]") * 4 +
    button("[2] Presets/E0 - m3 Up [midi:key 16]") * 3 +
    button("[2] Presets/F0 - M2 Up [midi:key 17]") * 2 +
    button("[2] Presets/F#0 - P5 Down [midi:key 18]") * (-7) +
    button("[2] Presets/G0 - P4 Down [midi:key 19]") * (-5) +
    button("[2] Presets/G#0 - M3 Down [midi:key 20]") * (-4) +
    button("[2] Presets/A0 - m3 Down [midi:key 21]") * (-3) +
    button("[2] Presets/A#0 - M2 Down [midi:key 22]") * (-2) +
    button("[2] Presets/B0 - Octave Down [midi:key 23]") * (-12);

// Smooth the shift changes
current_shift = current_shift_raw : si.smoo;

// Manual override slider (for when MIDI isn't available)
manual_shift = hslider("[3] Manual/Shift Override [unit:semitones]", 7, -24, 24, 1);

// Choose between preset and manual control
use_manual = checkbox("[3] Manual/Use Manual Control");
final_shift = select2(use_manual, current_shift, manual_shift);

// --- Main Process ---
process = _, _ : proc_input <: (audio_L, audio_R)
with {
    // Input processing
    proc_input = _, ! : input_source;

    // Voice generation
    voice_dry = proc_input;
    voice_harmony = proc_input : tdhs_pitch_shifter(final_shift);

    // Wet/Dry mix
    output_mix = voice_dry * (1.0 - wetDry) + voice_harmony * wetDry;

    // Stereo output
    audio_L = output_mix;
    audio_R = output_mix;
};

// --- Effect (Shared) ---
effect = dm.zita_light;

// =================================================================================
// USAGE NOTES:
//
// MIDI PRESET CONTROL:
// - Press any key from C0 to B0 (MIDI notes 12-23) to select a preset
// - Each key instantly switches to a different harmony interval
// - The selected preset is "latched" until you press another preset key
//
// COMPILATION:
// faust2jaqt -midi SGT_HarmonyGenerator_PresetControl.dsp
//
// ALTERNATIVE (Manual Control):
// - Enable "Use Manual Control" checkbox
// - Use the "Shift Override" slider to set the interval manually
//
// PRESET MAPPINGS:
// C0  (12) → Unison (0 semitones)
// C#0 (13) → Perfect 5th Up (+7)
// D0  (14) → Perfect 4th Up (+5)
// D#0 (15) → Major 3rd Up (+4)
// E0  (16) → Minor 3rd Up (+3)
// F0  (17) → Major 2nd Up (+2)
// F#0 (18) → Perfect 5th Down (-7)
// G0  (19) → Perfect 4th Down (-5)
// G#0 (20) → Major 3rd Down (-4)
// A0  (21) → Minor 3rd Down (-3)
// A#0 (22) → Major 2nd Down (-2)
// B0  (23) → Octave Down (-12)
// =================================================================================
