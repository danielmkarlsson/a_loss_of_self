# A loss of self
A drone of infinite duration.
Made with SuperCollider 3.7
This .scd contains working code that can be taken apart to make your own Synthdef (which can make a sound) and your own Pdef (which can make sequencing).

In the Synthdef there is code that can be looked at to: 

• Learn how to .clip value ranges. This is good for frequency parameters.

• Frequency Modulation. (Actual FM)

• Phase Modulation. (This is often referred to as FM because of the DX7)

• Glissando using XLine (Xline is exponential which I like for frequency domain stuff but you may prefer linear)

• Amplitude envelope using EnvGen & Env. (fade in, hold, fade out, repeat w/ new values)

• Panning.

• Mixing between different parts of the Synthdef.

• Resonant Low Pass Filter using RLPF.

• tanh (A kind of distortion)

• Resonz (A kind of ringing filter)

• AmpCompA (Does a kind of compensation that follows your hearing. It's good.

• Compression using Compander. (Too much dynamics is not good)

• LeakDC (If you have a problem with DC offset then this might part of the solution)

• High Pass Filter (used here as a DC problems and rumbly low end fix)


In the Pdef there is code that can be looked at to:

• Learn how to connect to sequence a Synthdef using the Patterns paradigm.

• Pseed (Set a number for a permutation of infinite duration that will be the same every time you run it.

• Pwhite (Random floats between two values)

• Pexprand (Random values chosen exponentially so the lower the value the more likely it is to get chosen)

• Prand (Random values chosen linearly so all of the values are just as likely to get chosen at any time)

• Learn how to sequence various paramenters that control timbre in your Synthdef.

• An example of patterns in patterns. SC let's you mix & match or chain things together.

• Pkey (So that choices can be made concerning one parameter based on the outcome of another parameter)
