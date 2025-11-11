// =================================================================================
// PROJECT: SGT Harmony Generator (C0-B0 Preset Control)
// AUTHOR: Gemini
// VERSION: 2.5 FIXED (No crashes, proper signal flow)
// STATUS: Corrected meter output routing
// =================================================================================

import("stdfaust.lib");

// --- 2. Configuration Parameters (OLA Core) ---
olaWindow = hslider("[4] Debug Tools/OLA Window Size (samples)", 2048, 1024, 4096, 1) : int;
olaXFade  = hslider("[4] Debug Tools/OLA Crossfade Size (samples)", 256, 128, 512, 1) : int;

// --- 3. Pitch Ratio Calculation Function ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- 4. OLA Pitch Shifting Function ---
tdhs_pitch_shifter(semitone_value) = ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 5. Test Tone Generator ---
test_osc(freq) = os.osc(freq) * 0.5;

testMode = checkbox("[4] Debug Tools/Test Tone Enable");
testFreq = hslider("[4] Debug Tools/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);

input_source = select2(testMode, 0.0, test_osc(testFreq));

// --- 6. Theoretical Frequency Display ---
theoretical_freq_display(input_freq, semitones) = input_freq * ratio(semitones);

// --- 7. Shift Control Logic ---
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

// Default is 12 (Octave Up)
manual_shift_value = hslider("[1] Harmony Control/Manual Semitones", 12, -24, 24, 1);
control_selector = checkbox("[1] Harmony Control/Manual Mode (Override Preset)");

final_shift_value = select2(control_selector, midi_shift_value, manual_shift_value);

wetDry = hslider("[1] Harmony Control/Wet/Dry Mix[style:knob]", 0.5, 0.0, 1.0, 0.01);

// --- 8. The Process Definition (FIXED) ---
process = _, _ : !, ! : (input_meter, output_meter, audio_L, audio_R)
with {
    proc_input = input_source;

    // Pitch shifted voice
    voice2 = proc_input : tdhs_pitch_shifter(final_shift_value);

    // Dry/Wet mixing
    output_mix = (proc_input * (1.0 - wetDry)) + (voice2 * wetDry);

    // Smooth gate
    smooth_gate = testMode : si.smoo;

    // Gated output
    audio_signal = output_mix * smooth_gate;

    // Meters (these are just display values, not audio signals)
    input_meter = testFreq : hbargraph("[4] Debug Tools/Input Freq (Hz)", 0, 1000);
    output_meter = theoretical_freq_display(testFreq, final_shift_value)
        : hbargraph("[4] Debug Tools/Output Freq (Hz)", 0, 2000);

    // Audio outputs
    audio_L = audio_signal;
    audio_R = audio_signal;
};
