// =================================================================================
// SGT Harmony Generator - CLEAN IMPLEMENTATION
// Based on official Faust pitch shifter example
// =================================================================================

declare name "SGT Harmony Generator";
declare version "1.0";
declare author "Faust";
declare license "BSD";

import("stdfaust.lib");

// Test tone generator
test_tone = os.osc(testFreq) * 0.3
with {
    testFreq = hslider("[0]Test Freq [unit:Hz]", 440, 100, 1000, 1);
};

// Enable/disable test tone
test_enable = checkbox("[0]Test Tone Enable");

// Pitch shifter with adjustable parameters
harmony_voice(shift_semitones) = ef.transpose(
    hslider("[1]Window (samples)", 2048, 50, 10000, 1),
    hslider("[1]Crossfade (samples)", 256, 1, 10000, 1),
    shift_semitones
);

// Harmony controls
h1_shift = hslider("[2]H1 Shift (semitones)", 12, -24, 24, 1);
h2_shift = hslider("[3]H2 Shift (semitones)", 7, -24, 24, 1);

// Dry/wet mix
dry_wet = hslider("[4]Dry/Wet", 0.5, 0, 1, 0.01);

// Main process: stereo input, stereo output
process = input_signal <: dry_path, wet_path :> _, _
with {
    // Select test tone or pass through input
    input_signal = _ * (1 - test_enable) + test_tone * test_enable;

    // Dry path
    dry_path = _ * (1 - dry_wet);

    // Wet path: mix of two harmony voices
    wet_path = _ <: (harmony_voice(h1_shift) + harmony_voice(h2_shift)) * 0.5 * dry_wet;
};
