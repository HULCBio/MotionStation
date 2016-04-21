function Hm = firsrc(varargin)
%FIRSRC Direct-Form FIR Polyphase Sample-Rate Converter.
%   Hm = MFILT.FIRSRC(L,M,NUM) constructs a direct-form FIR polyphase
%   sample-rate converter.
%   
%   L is the interpolation factor. It must be an integer. If not specified,
%   it defaults to 2.
%
%   M is the decimation factor. It must be an integer. If not specified, it
%   defaults to 1. If L is also not specified, M defaults to 3.
%
%   NUM is a vector containing the coefficients of the FIR lowpass filter
%   used for sample-rate conversion. If omitted, a lowpass Nyquist filter
%   of gain L and cutoff frequency of Pi/max(L,M) is used by default.
%
%   EXAMPLE: Sample-rate conversion by a factor of 147/160 (used to
%   downconvert from 48kHz to 44.1kHz)
%      L  = 147; M = 160;                   % Interpolation/decimation factors.
%      Hm = mfilt.firsrc(L,M);              % We use the default filter
%      Fs = 48e3;                           % Original sampling frequency: 48kHz
%      n = 0:10239;                         % 10240 samples, 0.213 seconds long
%      x  = sin(2*pi*1e3/Fs*n);             % Original signal, sinusoid at 1kHz
%      y = filter(Hm,x);                    % 9408 samples, still 0.213 seconds
%      stem(n(1:49)/Fs,x(1:49))             % Plot original sampled at 48kHz
%      hold on
%      % Plot fractionally decimated signal (44.1kHz) in red
%      stem(n(1:45)/(Fs*L/M),y(13:57),'r','filled') 
%      xlabel('Time (sec)');ylabel('Signal value')
%
%   See also MFILT/FIRFRACINTERP, MFILT/FIRFRACDECIM, MFILT/FIRINTERP,
%   MFILT/FIRDECIM, FDESIGN/SRC, FDESIGN/INTERP, FDESIGN/DECIM.

%   Author: R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/12 23:24:50 $

Hm = mfilt.firsrc(varargin{:});
