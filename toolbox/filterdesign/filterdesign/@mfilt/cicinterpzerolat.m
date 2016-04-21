function Hm = cicinterpzerolat(varargin)
%CICINTERPZEROLAT Zero-Latency Cascaded Integrator-Comb Interpolator.
%   Hm = MFILT.CICINTERPZEROLAT(R,M,N,IBITS,OBITS)constructs a 
%   Zero-latency Cascaded Integrator-Comb (CIC) interpolation filter object. 
%   
%   Inputs:
%   R is the interpolation factor
%   M is the differential delay
%   N is the number of stages
%   IBITS is the wordlength of the input signal. It can be either 8, 16, 
%         or 32 (default is 16).
%   OBITS is the wordlength of the output signal. It can be any positive integer
%         in the range of 0 to 32 (default is 16).
%
%   % EXAMPLE: Interpolation by a factor of 2 (used to convert from 22.05kHz
%   % to 44.1kHz)
%   R = 2;                               % Interpolation factor
%   Hm = mfilt.cicinterpzerolat(R);      % Use default NumberofStages & DifferentialDelay
%   Fs = 22.05e3;                        % Original sampling frequency: 22.05kHz
%   n = 0:5119;                          % 5120 samples, 0.232 second long signal
%   x  = sin(2*pi*1e3/Fs*n);             % Original signal, sinusoid at 1kHz
% 
%   % Scaled input to use the full dynamic range of the INT16 data type
%   x = int16((2^15-1)*x/gain(Hm));
% 
%   y_int = filter(Hm,x); % 5120 samples, still 0.232 seconds
% 
%   % Scale the input and output to overlay plots
%   x = double(x); x = x/max(abs(x)); y = double(y_int); y = y/max(abs(y));
%   stem(n(1:22)/Fs,x(1:22),'filled'); hold on; % Plot original sampled at 22.05kHz 
%   stem(n(1:44)/(Fs*R),y(2:45),'r');           % Plot interpolated signal (44.1kHz) in red
%   xlabel('Time (sec)');ylabel('Signal value');
%
%   See also MFILT/CICINTERP, MFILT/CICDECIM, MFILT/CICDECIMZEROLAT

%   Author: P. Costa
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/11/01 21:52:47 $

Hm = mfilt.cicinterpzerolat(varargin{:});

% [EOF] 
