// =================================================================================
// PROJECT: SGT Harmony Generator (MINIMAL CORE TEST)
// AUTHOR: Gemini
// VERSION: 3.0 FIXED (Minimal DSP, Max Stability)
// STATUS: All syntax errors corrected
// =================================================================================

import("stdfaust.lib");

// --- 2. Configuration Parameters ---
olaWindow = 2048;
olaXFade  = 256;

// --- 3. Pitch Ratio Calculation Function ---
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- 4. OLA Pitch Shifting Function ---
// ef.transpose takes (window, xfade, semitones) directly
pitch_shifter(semitone_value) =
    ef.transpose(olaWindow, olaXFade, semitone_value);

// --- 5. Test Tone Generator and Shift Control ---
testMode = checkbox("Test Tone Enable");
testFreq = hslider("Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
test_osc(freq) = os.osc(freq) * 0.5;

// Simple shift control: -2 Octaves to +2 Octaves
final_shift_value = hslider("Pitch Shift (Semitones)", 12, -24, 24, 1);

// --- 6. The Process Definition ---
process = _, _ : !, ! : (freq_meter, audio_L, audio_R)
with {
    // Input: Generate test tone or silence
    proc_input = select2(testMode, 0.0, test_osc(testFreq));

    // Pitch Shift
    voice2 = proc_input : pitch_shifter(final_shift_value);

    // Dry/Wet Mix (50/50)
    output_mix = (proc_input * 0.5) + (voice2 * 0.5);

    // DC Blocker
    output_clean = output_mix : fi.dcblocker;

    // Smooth Gate
    smooth_gate = testMode : si.smoo;
    audio_signal = output_clean * smooth_gate;

    // Meter: Theoretical Output Frequency
    theoretical_freq = testFreq * ratio(final_shift_value);
    freq_meter = theoretical_freq : hbargraph("Shifted Freq [unit:Hz]", 0, 2000);

    // Audio Outputs
    audio_L = audio_signal;
    audio_R = audio_signal;
};
