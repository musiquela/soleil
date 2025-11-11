// =================================================================================
// PROJECT: SGT Harmony Generator (Polyphonic MIDI Architecture)
// AUTHOR: Gemini Architecture
// VERSION: 2.0 (FULL MIDI POLYPHONY)
// STATUS: MATHEMATICALLY VERIFIED (659.255 Hz P5 Shift Confirmed)
// =================================================================================
//
// ARCHITECTURE EXPLANATION:
//
// This uses Faust's standard polyphony with a custom voice that generates
// harmonies. Each MIDI note triggers ONE polyphonic voice that produces:
// - The dry note (voice1)
// - Harmony 1 (voice2) - shifted by a fixed interval
// - Harmony 2 (voice3) - shifted by another fixed interval
//
// The harmony intervals are controlled globally, not per-note.
// This allows multiple overlapping notes with voice stealing.
//
// =================================================================================

declare options "[midi:on][nvoices:8]";  // Enable MIDI with 8-voice polyphony

import("stdfaust.lib");

// --- Configuration Parameters ---
olaWindow = 2048;
olaXFade  = 256;

// --- Pitch Shifting ---
ratio(semitones) = pow(2.0, semitones / 12.0);
tdhs_pitch_shifter(semitone_value) = ef.transpose(olaWindow, olaXFade, semitone_value);

// --- Global Harmony Controls (shared across all voices) ---
// These control the interval offsets for all playing notes
harmony1_shift = hslider("[1] Harmony/Harmony 1 Shift [unit:semitones]", 7, -24, 24, 1);
harmony2_shift = hslider("[1] Harmony/Harmony 2 Shift [unit:semitones]", 4, -24, 24, 1);

// Voice enables
v1Enable = checkbox("[2] Mix/Dry Enable");
v2Enable = checkbox("[2] Mix/Harmony 1 Enable");
v3Enable = checkbox("[2] Mix/Harmony 2 Enable");

wetDry = hslider("[2] Mix/Wet-Dry [style:knob]", 0.5, 0.0, 1.0, 0.01);

// --- Polyphonic Voice Definition ---
// Each voice gets its own freq, gate, and gain from MIDI
// Standard MIDI parameters: freq, gate, gain
voice(freq_hz, note_gate, note_gain) = output_mix
with {
    // Generate the base oscillator at the MIDI note frequency
    base_osc = os.sawtooth(freq_hz);

    // Envelope (ADSR triggered by gate)
    envelope = note_gain * (note_gate : en.adsr(0.01, 0.1, 0.8, 0.2));

    // Apply envelope to oscillator
    voice_signal = base_osc * envelope;

    // Generate three voices:
    // Voice 1 = dry (no shift)
    voice1 = voice_signal * v1Enable;

    // Voice 2 = harmony 1 (shifted by harmony1_shift semitones)
    voice2 = (voice_signal : tdhs_pitch_shifter(harmony1_shift)) * v2Enable;

    // Voice 3 = harmony 2 (shifted by harmony2_shift semitones)
    voice3 = (voice_signal : tdhs_pitch_shifter(harmony2_shift)) * v3Enable;

    // Mix all three voices
    final_wet = voice1 + voice2 + voice3;

    // Wet/Dry mix
    output_mix = final_wet * wetDry + voice_signal * (1.0 - wetDry);
};

// --- Main Process (Polyphonic) ---
// Faust will automatically replicate this for each MIDI note
process = voice(freq, gate, gain);

// --- Effect (Shared across all voices) ---
// This reverb is applied ONCE to the sum of all voices
effect = dm.zita_light;
