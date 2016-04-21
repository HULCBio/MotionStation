function Hm = cicdecim(varargin)
%CICDECIM Cascaded Integrator-Comb Decimator.
%   Hm = MFILT.CICDECIM(R,M,N,IBITS,OBITS,BPS)constructs a 
%   Cascaded Integrator-Comb (CIC) decimation filter object. This structure
%   has a latency of N (number of stages).
%   
%   Inputs:
%   R is the decimation factor
%   M is the differential delay 
%   N is the number of stages
%   IBITS is the wordlength of the input signal. It can be either 8, 16, 
%         or 32 (default is 16).
%   OBITS is the wordlength of the output signal. It can be any positive integer
%         in the range of 1 to 32 (default is 16).
%   BPS can be a scalar or vector (of length 2*N). BPS defines the bits per 
%       stage used during either the accumulation of the data in the integrator 
%       stages or the subtraction of the data performed by the comb stages 
%       (using 'wrap' arithmetic). If BPS is a scalar, that value is applied 
%       to each filter stage. The default is 16 for each stage.
%
%   % EXAMPLE: Decimation by a factor of 2 (used to convert from 44.1kHz
%   % to 22.05kHz)
%   R = 2;                       % Decimation factor
%   Hm = mfilt.cicdecim(R);      % Use default NumberofStages & DifferentialDelay
%   Fs = 44.1e3;                 % Original sampling frequency: 44.1kHz
%   n = 0:10239;                 % 10240 samples, 0.232 second long signal
%   x  = sin(2*pi*1e3/Fs*n);     % Original signal, sinusoid at 1kHz
% 
%   % Scale input to use the full dynamic range of the INT16 data type
%   x = int16((2^15-1)*x/gain(Hm));
%
%   y_int = filter(Hm,x); % 5120 samples, still 0.232 seconds
% 
%   % Scale the input and output to overlay plots
%   x = double(x); x = x/max(abs(x)); y = double(y_int); y = y/max(abs(y));
%   stem(n(1:44)/Fs,x(2:45)); hold on;           % Plot original sampled at 44.1kHz 
%   stem(n(1:22)/(Fs/R),y(3:24),'r','filled');   % Plot decimated signal (22.05kHz) in red
%   xlabel('Time (sec)');ylabel('Signal value'); 
%
%   See also MFILT/CICDECIMZEROLAT, MFILT/CICINTERP, MFILT/CICINTERPZEROLAT

%   Author: P. Costa
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/04 16:32:23 $

Hm = mfilt.cicdecim(varargin{:});

% [EOF] 
