// Cmd + B to boot the server

(  // Cmd + A to select all text and then press Shift + Enter to run everything
(
SynthDef.new(\sine, { // This synth definition has a bunch of stuff in it that makes this sound the way it does. It's the instrument.
	arg freq = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0, gain = 1, modIndex = 2, phaseModIndex = 2,
	lpfFreq =18000, resonance = 0, hold = 6.0, freqDeviation = 0.975, transitionTime = 0.875, resonzQ = 0.1;
	var sig, mod, phasemod, env;
	freq = freq.clip(20, 20000); // .clip because better safe than sorry. SC can get superLoud otherwise.
	mod = SinOsc.ar(freq/2, 0, Line.ar(0, modIndex, transitionTime) * freq); // Frequency Modulation
	phasemod = SinOsc.ar(freq, 0, phaseModIndex); // Phase Modulation
	sig = SinOsc.ar(XLine.ar(freqDeviation, freq, atk) + mod, phasemod); // Glissando
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [atk, hold, rel], \sine)); // Envelope
	sig = Pan2.ar(sig, Line.ar(0,pan, transitionTime), amp); // Panning
	sig = (sig * 0.7) + (Pluck.ar(sig, PinkNoise.ar(), 0.25, freq.reciprocal, 64.0, 0.5) * 0.3); // Mixer
	sig = RLPF.ar(sig, lpfFreq.clip(200, 20000), (Line.ar(1.0,resonance, resonance, atk)).clip(0.1, 1.0) ) * env; // Resonant Low Pass Filter
	sig = tanh(Line.ar(0.001, gain, transitionTime) * sig); // A kind of distortion
	sig = (sig * 0.75) + (Resonz.ar(sig, freq, resonzQ) * 1.125); // A kind of ringing filter
	sig = sig * AmpCompA.kr(freq,12.978271799373); // AmpComp does a kind of compensation that follows your hearing. It''s good.
	sig = Compander.ar(sig,sig,0.25, 0.33, 1, 0.002, 0.1); // Compressor

		DetectSilence.ar(sig.sum, 0.000001, doneAction:2); // This is intended to release synths when they become silent.
	Out.ar(0, Limiter.ar(sig,0.1)); // Limiter

}).add;
);

( // This part below makes all the things that happen in the music happen. It also controls when these things happen. It's the score.
Pdef( // All of these ones that start with P are part of Patterns which is one way of making music in SuperCollider. It is a good way.
	\sinepat,
	Pseed(2160,Pbind( // Change this number for another permutation of infinite duration that will be the same every time you run it.
		\instrument, \sine, //
		\dur, Pwhite(0.1, 10.0, inf), // The possible total durations. Double click Pwhite, then press Cmd + D. This tells you what stuff is.
        \gain, Pexprand(0.001, 1.5), // The gain that goes inte Tanh. All of these blue ones can for be looked up with Cmd + D. Do it.
		\transitionTime, Prand([0.875,2.0], inf),
		\modIndex, Pwhite(0.00001, 3.0,inf),
		\phaseModIndex, Pwhite(0.00001, 0.1, inf),
		\midinote,Pstutter(Pwhite(2,7)*2, // This is an example of patterns in patterns. SC let's you mix & match 'em up. It's pretty neat.
			    Prand([
                    Pseq([44, 20, 21, 27]),
                    Pseq([32, 20, 39, 40]),
                    Pseq([20, 44, 45, 20, 51]),
                    Pseq([44, 56, 20, 51, 52]),
                    Pseq([32, 44, 51, 20, 28]),
                ], inf)
        ),
		\harmonic, Pexprand(1, 9, inf).round, // You know about the Harmonic Series right? It is The Bees Knees let me tell you.
		\freqDeviation, Pkey(\harmonic) * (Pkey(\midinote) + Pwhite(-0.25, 0.0, inf)).midicps, // The size of the glissando.
		\atk, Pwhite(15.0, 45.0, inf), // The possible durations of the Attack part of the amplitude envelope.
		\hold, Pwhite(4.0, 14.0, inf), // This is where the Sustain or Hold part of the envelope gets made.
		\rel, Pwhite(30.0, 60.0, inf), // The realease goes here.
		\amp, Pkey(\harmonic).reciprocal * 0.75, // This makes it so that higher pitches are less loud which is good to have in there.
		\lpfFreq, ((Pkey(\midinote).midicps * Pkey(\harmonic)) * Pwhite(3.0, 9.0,inf)), // This scales the LoPass according to the harmonic
		\resonzQ, Pwhite(0.001, 1.0, inf), // The Q or the resonace of the Resonz filter. It's the ringing one I told you about earlier..
		\resonance, Pwhite(0.6, 0.05,inf),// The Q or the resonace of the low pass filter.
		\pan, Prand([ Pwhite(-1.0, -0.5, 1), Pwhite(0.5, 1.0, 1) ], inf); // Panning gets its values made in this line.
	);
)).play;
) ;
)
