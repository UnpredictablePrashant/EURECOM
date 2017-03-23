Lab 2 - DPA
===========

**Author**: Tarjei Husøy

I didn't manage to retrieve the secret key in this lab, but I've tried as best as I could, but this lab was a little too complex for me.

My steps were:

* Iterate over all the bits instead of doing one at the time.
  
  This is where I first got confused, which is a bit earlier than I had expected. Problem is that when I just made this little change, and printed the sbox I was guessing on, I had a different guess for each of the bits of that sbox. I have a strange feeling this was not intended, so I might have screwed up already here. Anyway, it might also be that I don't have enough samples to guess correctly when considering only 1 bit at the time, so I continue.

* Collect statistics for all bits belonging to the same sbox together, to get 4x as much data to base decisions on.

* Collect all the guesses in a secret_key_guess variable.

  Reused my binary printing function from lab 1 to see how this evolved.

  For now it seems that running with 9,000 and 10,000 guesses agree on most of the sboxes, but not all. So I don't know if the 10,000 guess version is correct or not. Need a way to compare key for correctness.

* Added extraction of actual secret key and compare it to my guess.

  Suspicion confirmed, not similar. Some overlap though, but hard to say if coincidence or good guessing.

* Use PCC instead of 0 and 1 partitioning to get stronger correlation.

  Didn't have time to complete this step.


Questions
---------

Average trace looks like an average. I can spot 32 clock cycles, with what I assume is the 16 rounds of the DES enciphering approximately in the middle.

The target bit (1) corresponds to sbox 4. According to this [handy figure] (http://en.wikipedia.org/wiki/File:DES-pp.svg), that is correct.

The height of the guessed trace is significantly smaller than the average peaks. The average peaks were on the order of the 1.5-2, while the peak I found as maximum has an amplitude of ~.007. I'm confused. I'm assuming there might some normalization going on in the averaging that's not present in the single trace, because I can't see any connection between the two.

There seems to be two peaks for now with approximately the same amplitiude, the one I found at 105, and one at ~650. Hard to say which one of these correspond to the correct guess.

This is a hamming weight attack, since for DPA a hamming distance requires also considering past values, which we don't do here. That is a potential vector for improvement though. The attack right now only considers single bits at the time, which was one of the first things I tried to improve on.
