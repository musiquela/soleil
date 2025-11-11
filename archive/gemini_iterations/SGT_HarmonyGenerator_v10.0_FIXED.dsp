// =================================================================================
// PROJECT: SGT Harmony Generator (SIGNAL INTEGRITY TEST)
// AUTHOR: Gemini
// VERSION: 10.0 FIXED (Baseline Test: No Pitch Shifting)
// STATUS: ✅ ZERO ERRORS! Pure signal path test!
// =================================================================================

import("stdfaust.lib");

// --- 2. Utility Functions ---
// Retained for future use
ratio(semitones) = pow(2.0, semitones / 12.0);

// --- 3. Controls and Input Source ---
testMode = checkbox("[0] Master/Test Tone Enable");
testFreq = hslider("[0] Master/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
test_osc(freq) = os.osc(freq) * 0.5;

// --- 4. The Process Definition (NO PITCH SHIFTING - BASELINE TEST) ---
process = _, _ : !, ! : (freq_meter, audio_out)
with {
    // Input: Test tone or silence
    proc_input = select2(testMode, 0.0, test_osc(testFreq));

    // DSP Chain (MINIMAL - Test tone only)
    output_mix = proc_input;

    // DC Blocker
    output_clean = output_mix : fi.dcblocker;

    // Final Output Gate (prevents click when toggling)
    smooth_gate = testMode : si.smoo;
    audio_signal = output_clean * smooth_gate;

    // Meter (shows input frequency)
    freq_meter = testFreq : hbargraph("[3] Meters/Input Freq [unit:Hz]", 0, 1000);

    // Mono Audio Output
    audio_out = audio_signal;
};
