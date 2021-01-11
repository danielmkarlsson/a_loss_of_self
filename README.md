# A loss of self
A drone of infinite duration.
Made with SuperCollider 3.7
This .scd contains working code that can be taken apart to make your own Synthdef (which can make a sound) and your own Pdef (which can make sequencing).
At the top there is a no previous experience explanation of how to get sound going in SuperCollider and how to get the patch running.
Throughout the .scd I have tried to make as few assumptions about previous knowledge of SuperCollider as possible although I have presupposed that the reader has some previous experience with synthesis and working with sound in general. I also trust that you are able to search online. This is in my opinion a reasonable level of trust to have in a user.

In the Synthdef there is code that can be looked at to: 

• Learn how to .clip value ranges. This is good for frequency parameters.

• Frequency Modulation. (Actual FM)

• Phase Modulation. (This is often referred to as FM because of the DX7)

• Glissando using XLine (Xline is exponential which I like for frequency domain stuff but you may prefer linear)

• Amplitude envelope using EnvGen & Env. (fade in, hold, fade out, repeat with new values)

• Panning.

• Mixing between different parts of the Synthdef.

• Resonant Low Pass Filter using RLPF.

• tanh (A kind of distortion)

• Resonz (A kind of ringing filter)

• AmpCompA (Does a kind of compensation that follows your hearing. It's good)

• Compression using Compander. (Too much dynamics is not good)

• LeakDC (If you have a problem with DC offset then this might be part of the solution)

• High Pass Filter (used here as a DC problems and rumbly low end fix)


In the Pdef there is code that can be looked at to:

• Learn how to do some sequencing of parameters in a Synthdef using the Patterns paradigm.

• Pseed (Set a number for a permutation of infinite duration that will be the same every time you run it)

• Pwhite (Random floats between two values)

• Pexprand (Random values chosen exponentially so the lower the value the more likely it is to get chosen)

• Prand (Random values chosen linearly so all of the values are just as likely to get chosen at any time)

• Learn how to sequence various paramenters that control timbre in your Synthdef.

• An example of patterns in patterns. SC let's you mix & match or chain things together.

• Pkey (So that choices can be made concerning one parameter based on the outcome of another parameter)

```text

(
// 1: Press Cmd and hold it down and then press A to select all text.
// 2: Press Cmd and hold it down and then press Enter to run everything. If you change something then do this again to update.
s.waitForBoot { // This boots the server for you. Yup, it's swank. Cmd + B boots the server otherwise.
	(
		SynthDef.new(\als, { // This synth definition has a bunch of stuff in it that makes this sound the way it does. It's the instrument.
			arg freq = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0, gain = 1, modIndex = 2, phaseModIndex = 2,
			lpfFreq =18000, resonance = 0, hold = 6.0, freqDeviation = 0.975, transitionTime = 0.875, resonzQ = 0.1;
			var sig, mod, phasemod, env;
			freq = freq.clip(20, 20000); // .clip because better safe than sorry. SC can get superLoud otherwise.
			mod = SinOsc.ar(freq/2, 0, Line.ar(0, modIndex, transitionTime) * freq); // Frequency Modulation.
			phasemod = SinOsc.ar(freq, 0, phaseModIndex); // Phase Modulation.
			sig = SinOsc.ar(XLine.ar(freqDeviation, freq, atk) + mod, phasemod); // Glissando.
			env = EnvGen.kr(Env.new([0, 1, 1, 0], [atk, hold, rel], \sine)); // Envelope.
			sig = Pan2.ar(sig, Line.ar(0,pan, transitionTime), amp); // Panning.
			sig = (sig * 0.8) + (Pluck.ar(sig, PinkNoise.ar(), 0.25, freq.reciprocal, 64.0, 0.5) * 0.4); // Mixer.
			sig = RLPF.ar(sig, lpfFreq.clip(200, 20000), (Line.ar(1.0,resonance, resonance, atk)).clip(0.1, 1.0) ) * env; // Resonant Low Pass Filter.
			sig = tanh(Line.ar(0.001, gain, transitionTime) * sig); // A kind of distortion.
			sig = (sig * 0.75) + (Resonz.ar(sig, freq, resonzQ) * 1.125); // A kind of ringing filter.
			sig = sig * AmpCompA.kr(freq,12.978271799373); // AmpComp does a kind of compensation that follows your hearing. It's good.
			sig = Compander.ar(sig,sig,0.25, 0.33, 1, 0.002, 0.1); // Compressor.
			sig = LeakDC.ar(sig) ; // This protects against DC offset.
			sig = HPF.ar( sig, 32 )  ; // This is a high pass filter.
			DetectSilence.ar(sig.sum, 0.000001, doneAction:2); // This is intended to release synths when they become silent.
			Out.ar(0, Limiter.ar(sig,0.1)); // Limiter.
		}
		).add;
	);
	
	s.sync; // This makes sure the synth has been created before we start sequencing it. The order is important.
	
	( // This part below makes all the things that happen in the music happen. It also controls when these things happen. It's the score.
		Pdef( // All of the ones that start with P are part of Patterns which is one way of making music in SuperCollider. It is a good way.
			\alspat,
			Pseed(2160,Pbind( // Change this number for another permutation of infinite duration that will be the same every time you run it.
				\instrument, \als, //
				\dur, Pwhite(0.1, 10.0, inf), // The possible total durations. Double click Pwhite, then press Cmd + D. This tells you what stuff is.
				\gain, Pexprand(0.001, 1.5), // The gain that goes into tanh. All of these blue ones can be looked up with Cmd + D.
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
				\harmonic, Pexprand(1, 9, inf).round, // You know about the Harmonic Series right? It is The bees knees let me tell you.
				\freqDeviation, Pkey(\harmonic) * (Pkey(\midinote) + Pwhite(-0.25, 0.0, inf)).midicps, // The size of the glissando.
				\atk, Pwhite(15.0, 45.0, inf), // The possible durations of the attack part of the amplitude envelope.
				\hold, Pwhite(4.0, 14.0, inf), // This is where the sustain or hold part of the envelope gets made.
				\rel, Pwhite(30.0, 60.0, inf), // The release goes here.
				\amp, Pkey(\harmonic).reciprocal * 0.75, // This makes it so that higher pitches are less loud which is good to have in there.
				\lpfFreq, ((Pkey(\midinote).midicps * Pkey(\harmonic)) * Pwhite(3.0, 9.0,inf)), // This scales the low pass according to the harmonic.
				\resonzQ, Pwhite(0.001, 1.0, inf), // The q or the resonance of the resonz filter. 
				\resonance, Pwhite(0.6, 0.05,inf),// The q or the resonance of the low pass filter.
				\pan, Prand([ Pwhite(-1.0, -0.5, 1), Pwhite(0.5, 1.0, 1) ], inf); // Panning gets its values made in this line.
			);
			)
		).play;
	);
}
)
```

