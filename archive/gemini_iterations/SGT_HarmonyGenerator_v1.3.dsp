// =================================================================================
// SGT Harmony Generator v1.3
// Based on official Faust pitch shifter example
// THREE VOICES: Dry + Harmony 1 + Harmony 2
// TRUE STEREO - Explicit left/right routing
// =================================================================================

declare name "SGT Harmony Generator";
declare version "1.3";
declare author "Official Faust Example";
declare license "BSD";

import("stdfaust.lib");

// ==================== PITCH SHIFTER CORE ====================

// Shared OLA parameters for both harmony voices
window_size = hslider("[0] Settings/Window (samples)", 2048, 50, 10000, 1);
xfade_size = hslider("[0] Settings/Crossfade (samples)", 256, 1, 1000, 1);

// Harmony voice constructor
harmony_voice(shift_semitones) = ef.transpose(window_size, xfade_size, shift_semitones);

// ==================== HARMONY CONTROLS ====================

// Harmony 1 (default: octave up)
h1_shift = hslider("[1] Harmony 1/Shift (semitones)", 12, -24, 24, 0.1);
h1_gain = hslider("[1] Harmony 1/Gain", 0.33, 0, 1, 0.01);

// Harmony 2 (default: perfect 5th up)
h2_shift = hslider("[2] Harmony 2/Shift (semitones)", 7, -24, 24, 0.1);
h2_gain = hslider("[2] Harmony 2/Gain", 0.33, 0, 1, 0.01);

// Dry signal gain
dry_gain = hslider("[3] Mix/Dry Gain", 0.34, 0, 1, 0.01);

// ==================== PROCESS ====================
// Stereo in, stereo out - process each channel through the same effect chain

process = left_channel, right_channel
with {
    // Left channel processing
    left_channel = _ <: (_ * dry_gain),
                        (harmony_voice(h1_shift) * h1_gain),
                        (harmony_voice(h2_shift) * h2_gain)
                   :> _;

    // Right channel processing (identical to left)
    right_channel = _ <: (_ * dry_gain),
                         (harmony_voice(h1_shift) * h1_gain),
                         (harmony_voice(h2_shift) * h2_gain)
                    :> _;
};
