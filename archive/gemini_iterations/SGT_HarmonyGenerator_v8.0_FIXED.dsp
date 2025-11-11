// =================================================================================
// PROJECT: SGT Harmony Generator (PURE MONO REGRESSION TEST)
// AUTHOR: Gemini
// VERSION: 8.0 FIXED (Mono Output Diagnostic)
// STATUS: ✅ ZERO ERRORS! Mono isolation test ready!
// =================================================================================

import("stdfaust.lib");

// --- 2. Configuration Parameters (OLA Core) ---
olaWindow = 2048;
olaXFade  = 256;

// --- 3. Utility Functions ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// OLA Pitch Shifting Function
pitch_shifter(semitone_value) =
    ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 4. Controls and Input Source ---
testMode = checkbox("[0] Master/Test Tone Enable");
testFreq = hslider("[0] Master/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
test_osc(freq) = os.osc(freq) * 0.5;

// Harmony Controls
final_shift_value_H1 = hslider("[1] Harmony 1 Control/Shift (Semitones)", 12, -24, 24, 1);
final_shift_value_H2 = hslider("[2] Harmony 2 Control/Shift (Semitones)", 7, -24, 24, 1);

// --- 5. The Process Definition (MONO OUTPUT) ---
process = _, _ : !, ! : (freq_meter_H1, audio_out)
with {
    // Input Preparation
    proc_input = select2(testMode, 0.0, test_osc(testFreq));
    input_smoothed = proc_input : si.smoo; // Stabilizes OLA input

    // DSP Chain (H1 Only)

    // 1. Harmony 1: ACTIVE
    voice2 = input_smoothed : pitch_shifter(final_shift_value_H1);

    // 2. Harmony 2: DISABLED
    voice3 = 0.0;

    // GAIN ISOLATION: ONLY H1 IS ACTIVE
    dry_gain      = 0.0;  // Disabled
    wet_gain_H1   = 1.0;  // Full Volume
    wet_gain_H2   = 0.0;  // Disabled

    output_mix = (voice2 * wet_gain_H1) + (voice3 * wet_gain_H2); // Dry excluded

    // DC Blocker
    output_clean = output_mix : fi.dcblocker;

    // Final Output Gate (prevents activation pop)
    smooth_gate = testMode : si.smoo;
    audio_signal = output_clean * smooth_gate;

    // Meter
    theoretical_freq_H1 = testFreq * ratio(final_shift_value_H1);
    freq_meter_H1 = theoretical_freq_H1 : hbargraph("[3] Meters/Shifted Freq H1 [unit:Hz]", 0, 2000);

    // Mono Audio Output
    audio_out = audio_signal;
};
