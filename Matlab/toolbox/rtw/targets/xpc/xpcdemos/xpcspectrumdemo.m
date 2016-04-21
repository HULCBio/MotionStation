function xpcspectrumdemo
% XPCSPECTRUMDEMO How to use the Spectrum Analyzer demo with xPC Target
%
%   The Spectrum Analyzer demo is contained in the Simulink model file
%   xpcdspspectrum.mdl. In order to use this demo, you must have the DSP
%   blockset, and the xPC Target PC must be running with TargetScope
%   enabled.
%
%   The demo emulates a spectrum analyzer by displaying the Fast Fourier
%   Transform (FFT) of the input signal using a buffer of 512 samples. The
%   input signal is the sum of two sine waves, one with an amplitude of 0.6
%   and a frequency of 250 Hz, and the other with an amplitude of 0.25 and
%   a frequency of 600 Hz. The results will display in a scope of type
%   Target on the xPC Target PC monitor.
%
%   You can open the Spectrum Analyzer demo by typing
%   >> xpcdspspectrum
%   at the MATLAB command line. You can then select
%   Tools|Real-Time Workshop|Build from the Simulink Window to build and
%   download this model to the target PC. This also creates a variable
%   called 'tg' in the MATLAB workspace, which is the xpc object used to
%   communicate with the target application.
%
%   You can then type
%   >> start(tg)
%   at the MATLAB command line to start the application and
%   display the frequency spectrum of the input signal.
%
%   By executing the commands
%
%   >> s1amp = getparamid(tg, ...
%               'Sine Wave f=250Hz, amp= 0.6', 'Amplitude');
%   >> s1fre = getparamid(tg, ...
%               'Sine Wave f=250Hz, amp= 0.6', 'Frequency');
%   >> s2amp = getparamid(tg, ...
%               'Sine Wave f=600Hz, amp= 0.25', 'Amplitude');
%   >> s2fre = getparamid(tg, ...
%               'Sine Wave f=600Hz, amp= 0.25', 'Frequency');
%
%   and then using the commands
%   >> setparam(tg, s1amp, 0.3);
%   >> setparam(tg, s1fre, 300);
%   >> setparam(tg, s2amp, 0.55);
%   >> setparam(tg, s2fre, 500);
%   the input signal parameters can be varied while the application is
%   running, thus enabling you to monitor the varying signal in
%   real-time. The set command(s) can be repeated with different values
%   for the amplitude and the frequency.
%
%   The details of the 'xPC Target Spectrum Scope' block can be examined by
%   right clicking on the block and selecting 'Look under mask'. This
%   reveals how the spectrum analyzer functionality is achieved.
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.1 $ $Date: 2004/04/08 21:05:32 $

help(mfilename);