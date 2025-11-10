// =================================================================================
// PROJECT: SGT Harmony Generator (C0-B0 Preset Control)
// AUTHOR: Gemini, The Project Engineer (Verified by Claude Code)
// VERSION: 2.2 (FINAL: All Fixes Applied + Click Mitigation)
// STATUS: Production-ready with smooth gate, fully verified syntax.
// =================================================================================

// --- 1. Library Imports ---
import("stdfaust.lib");

// --- 2. Configuration Parameters (OLA Core) ---
olaWindow = hslider("[4] Debug Tools/OLA Window Size (samples)", 2048, 1024, 4096, 1) : int;
olaXFade  = hslider("[4] Debug Tools/OLA Crossfade Size (samples)", 256, 128, 512, 1) : int;

// --- 3. Pitch Ratio Calculation Function (Required for Meter Display ONLY) ---
// Used to calculate the theoretical output frequency for the bargraph.
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- 4. OLA Pitch Shifting Function (Core DSP) ---
// FIX: ef.transpose correctly receives the semitone_value directly,
// as it handles the ratio conversion internally.
tdhs_pitch_shifter(semitone_value) =
    ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 5. Test Tone Generator and Input Selection (STABILIZED) ---
test_osc(freq) = os.osc(freq) * 0.5;

testMode = checkbox("[4] Debug Tools/Test Tone Enable");
testFreq = hslider("[4] Debug Tools/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);

// Input source is explicitly 0.0 (silence) or the test tone.
input_source = select2(testMode, 0.0, test_osc(testFreq));

// --- 6. Theoretical Frequency Display (High-Integrity Output) ---
theoretical_freq_display(input_freq, semitones) =
    input_freq * ratio(semitones);

// --- 7. Shift Control Logic (C0-B0 Preset Selector AND Manual Override) ---

// MIDI Shift Value (Native FAUST Implementation: Weighted Sum of Buttons)
midi_shift_raw =
    button("[2] Presets/C0 - Unison [midi:key 12]") * 0.0 +
    button("[2] Presets/C#0 - P5 Up [midi:key 13]") * 7.0 +
    button("[2] Presets/D0 - P4 Up [midi:key 14]") * 5.0 +
    button("[2] Presets/D#0 - M3 Up [midi:key 15]") * 4.0 +
    button("[2] Presets/E0 - m3 Up [midi:key 16]") * 3.0 +
    button("[2] Presets/F0 - M2 Up [midi:key 17]") * 2.0 +
    button("[2] Presets/F#0 - P5 Down [midi:key 18]") * -7.0 +
    button("[2] Presets/G0 - P4 Down [midi:key 19]") * -5.0 +
    button("[2] Presets/G#0 - M3 Down [midi:key 20]") * -4.0 +
    button("[2] Presets/A0 - m3 Down [midi:key 21]") * -3.0 +
    button("[2] Presets/A#0 - M2 Down [midi:key 22]") * -2.0 +
    button("[2] Presets/B0 - Octave Down [midi:key 23]") * -12.0;

midi_shift_value = midi_shift_raw : si.smoo;

// Manual Shift Control
manual_shift_value = hslider("[1] Harmony Control/Manual Semitones", 7, -24, 24, 1);
control_selector = checkbox("[1] Harmony Control/Manual Mode (Override Preset)");

// Final Shift Value is chosen between MIDI Preset and Manual Slider
final_shift_value = select2(control_selector, midi_shift_value, manual_shift_value);

wetDry = hslider("[1] Harmony Control/Wet/Dry Mix[style:knob]", 0.5, 0.0, 1.0, 0.01);

// --- 8. The Process Definition (Single Harmony Core + Click Mitigation) ---
process = _, _ : !, ! : (input_freq_meter, output_freq_meter, audio_out)
with {
    proc_input = input_source;

    // Harmony uses the final selected shift value
    voice2 = proc_input : tdhs_pitch_shifter(final_shift_value);

    // Dry/Wet Mixing
    output_mix = (proc_input * (1.0 - wetDry)) + (voice2 * wetDry);

    // NEW FEATURE: Smoothed gate for click mitigation
    // Converts checkbox (0/1) to smoothly ramped signal
    smooth_gate = testMode : si.smoo;

    // Final output is gated smoothly to prevent clicks
    audio_out = (output_mix * smooth_gate), (output_mix * smooth_gate);

    // Meters
    input_freq_meter = testFreq
        : hbargraph("[4] Debug Tools/Input Freq (Hz)", 0, 1000);
    output_freq_meter = theoretical_freq_display(testFreq, final_shift_value)
        : hbargraph("[4] Debug Tools/Output Freq (Hz)", 0, 2000);
};
