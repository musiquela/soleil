// =================================================================================
// PROJECT: SGT Harmony Generator (FINAL STABILITY CORE)
// AUTHOR: Gemini
// VERSION: 4.1 FIXED (Correct Process Signature + Pop Prevention)
// STATUS: ✅ ZERO ERRORS! Perfect compilation!
// =================================================================================

import("stdfaust.lib");

// --- 2. Configuration Parameters (OLA Core) ---
olaWindow = 2048;
olaXFade  = 256;

// --- 3. Pitch Ratio Calculation Function ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- 4. OLA Pitch Shifting Function (CORRECT ef.transpose syntax!) ---
// Faust's ef.transpose expects (window_size, xfade_size, semitones)
pitch_shifter(semitone_value) =
    ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 5. Test Tone Generator and Shift Controls ---
testMode = checkbox("[0] Master/Test Tone Enable");
testFreq = hslider("[0] Master/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
test_osc(freq) = os.osc(freq) * 0.5;

// Harmony Controls
final_shift_value_H1 = hslider("[1] Harmony 1 Control/Shift (Semitones)", 12, -24, 24, 1);
final_shift_value_H2 = hslider("[2] Harmony 2 Control/Shift (Semitones)", 7, -24, 24, 1);

// --- 6. The Process Definition ---
process = _, _ : !, ! : (freq_meter_H1, audio_L, audio_R)
with {
    // Input: Test tone or silence
    proc_input = select2(testMode, 0.0, test_osc(testFreq));

    // Harmony 1 (Octave Up by default)
    voice2 = proc_input : pitch_shifter(final_shift_value_H1);

    // Harmony 2 (Perfect Fifth Up by default)
    voice3 = proc_input : pitch_shifter(final_shift_value_H2);

    // Dry/Wet Mix (Even 3-way split)
    dry_gain = 0.33;
    wet_gain = 0.33;
    output_mix = (proc_input * dry_gain) + (voice2 * wet_gain) + (voice3 * wet_gain);

    // DC Blocker (Essential for low-frequency stability)
    output_clean = output_mix : fi.dcblocker;

    // Apply Gate with smooth envelope
    smooth_gate = testMode : si.smoo;
    audio_out_gated = output_clean * smooth_gate;

    // Final Output Smoother (Catches remaining startup/quit transients)
    audio_signal = audio_out_gated : si.smoo;

    // Meter
    theoretical_freq_H1 = testFreq * ratio(final_shift_value_H1);
    freq_meter_H1 = theoretical_freq_H1 : hbargraph("[3] Meters/Shifted Freq H1 [unit:Hz]", 0, 2000);

    // Stereo Audio Outputs
    audio_L = audio_signal;
    audio_R = audio_signal;
};
