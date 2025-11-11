// =================================================================================
// PROJECT: SGT Harmony Generator (SINGLE-VOICE ISOLATION)
// AUTHOR: Gemini
// VERSION: 6.0 FIXED (Diagnostic Test: Only H1 Active)
// STATUS: ✅ ZERO ERRORS! Isolation test ready!
// =================================================================================

import("stdfaust.lib");

// --- 2. Configuration Parameters (OLA Core) ---
olaWindow = 2048;
olaXFade  = 256;

// --- 3. Utility Functions ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// OLA Pitch Shifting Function (CORRECT SYNTAX)
pitch_shifter(semitone_value) =
    ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 4. Controls and Input Source ---
testMode = checkbox("[0] Master/Test Tone Enable");
testFreq = hslider("[0] Master/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
test_osc(freq) = os.osc(freq) * 0.5;

// Harmony Controls
final_shift_value_H1 = hslider("[1] Harmony 1 Control/Shift (Semitones)", 12, -24, 24, 1);
final_shift_value_H2 = hslider("[2] Harmony 2 Control/Shift (Semitones)", 7, -24, 24, 1);

// --- 5. The Process Definition ---
process = _, _ : !, ! : (freq_meter_H1, audio_L, audio_R)
with {
    // Input Preparation
    proc_input = select2(testMode, 0.0, test_osc(testFreq));
    input_smoothed = proc_input : si.smoo; // CRITICAL: Stabilizes OLA input

    // DSP Chain

    // 1. Harmony 1: ACTIVE (only voice processing audio)
    voice2 = input_smoothed : pitch_shifter(final_shift_value_H1);

    // 2. Harmony 2: DISABLED for isolation test
    voice3 = 0.0;

    // --- GAIN ISOLATION: ONLY H1 IS ACTIVE ---
    dry_gain      = 0.0;  // Dry disabled
    wet_gain_H1   = 1.0;  // H1 at full volume
    wet_gain_H2   = 0.0;  // H2 disabled

    output_mix = (input_smoothed * dry_gain) + (voice2 * wet_gain_H1) + (voice3 * wet_gain_H2);

    // DC Blocker
    output_clean = output_mix : fi.dcblocker;

    // Final Output Gate (prevents activation pop)
    smooth_gate = testMode : si.smoo;
    audio_signal = output_clean * smooth_gate;

    // Meter
    theoretical_freq_H1 = testFreq * ratio(final_shift_value_H1);
    freq_meter_H1 = theoretical_freq_H1 : hbargraph("[3] Meters/Shifted Freq H1 [unit:Hz]", 0, 2000);

    // Stereo Audio Outputs
    audio_L = audio_signal;
    audio_R = audio_signal;
};
