"""Generate a cute notification chime sound (WAV format for Android raw resource)"""
import struct
import math
import wave

SAMPLE_RATE = 44100

def generate_tone(freq, duration, volume=0.5, fade_out=True):
    """Generate a sine wave tone."""
    samples = []
    n_samples = int(SAMPLE_RATE * duration)
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # Sine wave
        val = math.sin(2 * math.pi * freq * t)
        # Add a soft harmonic for warmth
        val += 0.3 * math.sin(2 * math.pi * freq * 2 * t)
        val += 0.15 * math.sin(2 * math.pi * freq * 3 * t)
        # Apply envelope
        if fade_out:
            envelope = max(0, 1.0 - (i / n_samples) ** 0.5)
        else:
            envelope = 1.0
        # Attack (first 5ms)
        attack_samples = int(SAMPLE_RATE * 0.005)
        if i < attack_samples:
            envelope *= i / attack_samples
        val *= envelope * volume
        # Clamp
        val = max(-1.0, min(1.0, val))
        samples.append(val)
    return samples

def mix_samples(*sample_lists):
    """Mix multiple sample lists together."""
    max_len = max(len(s) for s in sample_lists)
    result = [0.0] * max_len
    for samples in sample_lists:
        for i, s in enumerate(samples):
            result[i] += s
    # Normalize
    peak = max(abs(s) for s in result) or 1.0
    return [s / peak * 0.8 for s in result]

# Create a cute "ding-ding-ding" chime - like a music box
# Notes: E5, G5, B5, E6 (cute ascending sparkle)
notes = [
    (659.25, 0.15, 0.0),   # E5
    (783.99, 0.15, 0.12),  # G5
    (987.77, 0.15, 0.24),  # B5
    (1318.5, 0.25, 0.36),  # E6 (held longer)
]

all_samples = []
total_duration = 0.8  # seconds
total_samples = int(SAMPLE_RATE * total_duration)
result = [0.0] * total_samples

for freq, dur, start_time in notes:
    tone = generate_tone(freq, dur, volume=0.5)
    start_idx = int(start_time * SAMPLE_RATE)
    for i, s in enumerate(tone):
        idx = start_idx + i
        if idx < total_samples:
            result[idx] += s

# Add a gentle sparkle overlay (high freq shimmer)
sparkle = generate_tone(2637, 0.3, volume=0.08)  # E7 very quiet
for i, s in enumerate(sparkle):
    start = int(0.36 * SAMPLE_RATE) + i
    if start < total_samples:
        result[start] += s

# Normalize
peak = max(abs(s) for s in result) or 1.0
result = [s / peak * 0.7 for s in result]

# Write WAV
output_path = "android/app/src/main/res/raw/cute_notification.wav"
with wave.open(output_path, 'w') as wav:
    wav.setnchannels(1)
    wav.setsampwidth(2)  # 16-bit
    wav.setframerate(SAMPLE_RATE)
    for sample in result:
        val = int(sample * 32767)
        val = max(-32768, min(32767, val))
        wav.writeframes(struct.pack('<h', val))

print(f"✓ Cute notification sound saved to {output_path}")
print(f"  Duration: {total_duration}s, Samples: {total_samples}")
