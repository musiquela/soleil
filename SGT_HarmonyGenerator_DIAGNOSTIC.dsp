// =================================================================================
// DIAGNOSTIC VERSION - Simplified for Testing
// =================================================================================

import("stdfaust.lib");

testMode = checkbox("[1] Test Tone Enable");
testFreq = hslider("[1] Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
shift = hslider("[1] Semitone Shift", 7, -24, 24, 1);

// Simple calculation
ratio(semitones) = pow(2.0, semitones / 12.0);
output_freq = testFreq * ratio(shift);

// Simple oscillator
test_tone = os.osc(testFreq) * 0.3 * testMode;

// Pitch shifted version
shifted = test_tone : ef.transpose(2048, 256, shift);

process = test_tone, shifted <:
    // Meters
    hbargraph("[2] Meters/Input Freq", 0, 1000)(testFreq),
    hbargraph("[2] Meters/Output Freq (Calculated)", 0, 2000)(output_freq),
    // Audio outputs
    _, _;
