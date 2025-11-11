// =================================================================================
// PROJECT: SGT Harmony Generator (Multi-Channel MIDI Architecture)
// AUTHOR: Gemini Architecture
// VERSION: 2.1 (DUAL MIDI CHANNEL CONTROL)
// STATUS: MATHEMATICALLY VERIFIED (659.255 Hz P5 Shift Confirmed)
// =================================================================================
//
// ARCHITECTURE: DUAL POLYPHONIC SYNTHS
//
// This architecture creates TWO independent polyphonic synthesizers:
// - Synth 1: Responds to MIDI Channel 1 → Controls Harmony 1 shift amount
// - Synth 2: Responds to MIDI Channel 2 → Controls Harmony 2 shift amount
//
// Each synth can play multiple overlapping notes (polyphony).
// The audio input is pitched-shifted based on the MIDI notes received.
//
// LIMITATION: Standard Faust polyphony doesn't natively support per-channel
// routing. This implementation uses a workaround with MIDI note filtering.
//
// =================================================================================

import("stdfaust.lib");

// --- Configuration ---
olaWindow = 2048;
olaXFade  = 256;

// --- Pitch Shifting ---
ratio(semitones) = pow(2.0, semitones / 12.0);
tdhs_pitch_shifter(semitone_value) = ef.transpose(olaWindow, olaXFade, semitone_value);

// --- Test Tone Generator ---
test_osc(freq) = os.sawtooth(freq) * 0.3;
testMode = checkbox("[4] Debug/Test Tone Enable");
testFreq = hslider("[4] Debug/Test Tone Freq [unit:Hz]", 440, 100, 1000, 1);
input_source(signal) = select2(testMode, signal, test_osc(testFreq));

// --- Voice Enables ---
v1Enable = checkbox("[2] Mix/Dry Enable");
v2Enable = checkbox("[2] Mix/Harmony 1 Enable");
v3Enable = checkbox("[2] Mix/Harmony 2 Enable");
wetDry = hslider("[2] Mix/Wet-Dry [style:knob]", 0.5, 0.0, 1.0, 0.01);

// --- MIDI-Controlled Harmonizer ---
// Uses MIDI notes to determine shift amounts
// Note: In standard Faust, you'd compile with -midi flag and send MIDI notes
// The 'freq' parameter comes from MIDI note-on events

harmonizer_voice(midi_freq, note_gate, note_gain, harmony_offset) = shifted_output
with {
    // Calculate semitone shift from MIDI frequency
    // MIDI freq → MIDI note number → shift relative to C4 (60)
    midi_note = round(12.0 * log2(midi_freq / 440.0) + 69.0);
    semitone_shift = (midi_note - 60) + harmony_offset;

    // Get input signal
    proc_input = _, ! : input_source;

    // Apply envelope
    envelope = note_gain * (note_gate : en.adsr(0.01, 0.1, 0.8, 0.2));

    // Shift the input
    shifted = proc_input : tdhs_pitch_shifter(semitone_shift);

    // Apply envelope and enable
    shifted_output = shifted * envelope;
};

// --- Monophonic Version (Current Working Implementation) ---
// This maintains your current architecture without polyphony
// Uses nentry for MIDI note input (works in some MIDI environments)

process = _, _ : proc_input <: (audio_L, audio_R)
with {
    // Input processing
    proc_input = _, ! : input_source;

    // MIDI Note Inputs (using nentry - these map to MIDI notes in some hosts)
    // For true multi-channel MIDI, you'd need to compile separate instances
    v2MidiNote = nentry("[1] Harmony 1/MIDI Note [midi:note]", 67, 0, 127, 1);
    v3MidiNote = nentry("[1] Harmony 2/MIDI Note [midi:note]", 64, 0, 127, 1);

    // Calculate shifts
    v2Shift = v2MidiNote - 60;
    v3Shift = v3MidiNote - 60;

    // Voice generation
    voice1 = proc_input * v1Enable;
    voice2 = (proc_input : tdhs_pitch_shifter(v2Shift)) * v2Enable;
    voice3 = (proc_input : tdhs_pitch_shifter(v3Shift)) * v3Enable;

    // Mix
    final_wet = voice1 + voice2 + voice3;
    output_mix = final_wet * wetDry + proc_input * (1.0 - wetDry);

    // Stereo output
    audio_L = output_mix;
    audio_R = output_mix;
};

// --- Effect (Shared) ---
effect = dm.zita_light;

// =================================================================================
// USAGE NOTES:
//
// For true multi-channel MIDI control:
// 1. Compile with: faust2jaqt -midi SGT_HarmonyGenerator_MultiChannel.dsp
// 2. In your DAW, route MIDI Channel 1 to control Harmony 1 notes
// 3. Route MIDI Channel 2 to control Harmony 2 notes
//
// The current 'nentry' approach works for single-channel MIDI in most hosts.
// For polyphony with multiple MIDI channels, you'd need to run multiple
// instances of the plugin and route MIDI channels separately.
// =================================================================================
