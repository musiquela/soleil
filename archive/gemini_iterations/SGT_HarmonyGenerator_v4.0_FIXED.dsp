// =================================================================================
// PROJECT: SGT Harmony Generator (DUAL HARMONY CORE TEST)
// AUTHOR: Gemini
// VERSION: 4.0 FIXED (Two Independent Harmony Voices)
// STATUS: All syntax errors corrected
// =================================================================================

import("stdfaust.lib");

// --- 2. Configuration Parameters (OLA Core) ---
olaWindow = 2048;
olaXFade  = 256;

// --- 3. Pitch Ratio Calculation Function ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- 4. OLA Pitch Shifting Function ---
// ef.transpose takes (window, xfade, semitones) directly
pitch_shifter(semitone_value) =
    ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 5. Test Tone Generator and Shift Controls ---
testMode = checkbox("Test Tone Enable");
testFreq = hslider("Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
test_osc(freq) = os.osc(freq) * 0.5;

// Harmony 1 Control (H1)
final_shift_value_H1 = hslider("[1] Harmony 1 Control/Shift (Semitones)", 12, -24, 24, 1);

// Harmony 2 Control (H2) - New Voice
final_shift_value_H2 = hslider("[2] Harmony 2 Control/Shift (Semitones)", 7, -24, 24, 1);

// --- 6. The Process Definition ---
process = _, _ : !, ! : (freq_meter_H1, audio_L, audio_R)
with {
    // Input: Generate test tone or silence
    proc_input = select2(testMode, 0.0, test_osc(testFreq));

    // Harmony 1 (H1) - Octave up (default 12 semitones)
    voice2 = proc_input : pitch_shifter(final_shift_value_H1);

    // Harmony 2 (H2) - Perfect 5th up (default 7 semitones)
    voice3 = proc_input : pitch_shifter(final_shift_value_H2);

    // Dry/Wet Mix (Even 3-way split: Dry + H1 + H2)
    dry_gain = 0.33;
    wet_gain = 0.33;

    output_mix = (proc_input * dry_gain) + (voice2 * wet_gain) + (voice3 * wet_gain);

    // DC Blocker
    output_clean = output_mix : fi.dcblocker;

    // Smooth Gate
    smooth_gate = testMode : si.smoo;
    audio_signal = output_clean * smooth_gate;

    // Meter: Theoretical Frequency for H1
    theoretical_freq_H1 = testFreq * ratio(final_shift_value_H1);
    freq_meter_H1 = theoretical_freq_H1 : hbargraph("[3] Meters/Shifted Freq H1 [unit:Hz]", 0, 2000);

    // Audio Outputs (Stereo)
    audio_L = audio_signal;
    audio_R = audio_signal;
};
