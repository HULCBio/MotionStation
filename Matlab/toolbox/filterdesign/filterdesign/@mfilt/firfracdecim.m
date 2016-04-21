function Hm = firfracdecim(varargin)
%FIRFRACDECIM Direct-Form FIR Polyphase Fractional Decimator.
%   Hm = MFILT.FIRFRACDECIM(L,M,NUM) constructs a direct-form FIR polyphase
%   fractional decimator.
%   
%   L is the interpolation factor. It must be an integer. If not specified,
%   it defaults to 2.
%
%   M is the decimation factor. It must be an integer. If not specified, it
%   defaults to L+1.
%
%   NUM is a vector containing the coefficients of the FIR lowpass filter
%   used for decimation. If omitted, a lowpass Nyquist filter of gain L
%   and cutoff frequency of Pi/max(L,M) is used by default.
%
%   EXAMPLE: Fractional decimation by a factor of 2/3 (used to downconvert
%   from 48kHz to 32kHz)
%      L  = 2; M = 3;                       % Interpolation/decimation factors.
%      Hm = mfilt.firfracdecim(L,M);        % We use the default filter
%      Fs = 48e3;                           % Original sampling frequency: 48kHz
%      n  = 0:10239;                        % 10240 samples, 0.213 second long signal
%      x  = sin(2*pi*1e3/Fs*n);             % Original signal, sinusoid at 1kHz
%      y  = filter(Hm,x);                   % 9408 samples, still 0.213 seconds
%      stem(n(1:49)/Fs,x(1:49)); hold on    % Plot original signal sampled at 48kHz
%      stem(n(1:32)/(Fs*L/M),y(13:44),'r','filled') % Plot decimated signal at 32kHz
%      xlabel('Time (sec)');
%
%   See also MFILT/FIRSRC, MFILT/FIRFRACINTERP, MFILT/FIRINTERP, MFILT/FIRDECIM.

%   Author: V. Pellissier
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/30 22:41:30 $

Hm = mfilt.firfracdecim(varargin{:});
 
% [EOF]
