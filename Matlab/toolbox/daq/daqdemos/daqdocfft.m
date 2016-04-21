function [f, mag] = daqdocfft(data,Fs,blocksize) 
%    [F,MAG]=DAQDOCFFT(X,FS,BLOCKSIZE) calculates the FFT of X
%    using sampling frequency FS and the SamplesPerTrigger provided
%    in BLOCKSIZE.
%
%    See also DAQDOC4_1, DAQDOC4_2.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2003/08/29 04:45:04 $

xfft = abs(fft(data));

% Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

mag = 20*log10(xfft);
mag = mag(1:floor(blocksize/2));
f = (0:length(mag)-1)*Fs/blocksize;
f = f(:);
