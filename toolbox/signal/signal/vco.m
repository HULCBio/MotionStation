function y = vco(x,range,Fs)
%VCO  Voltage controlled oscillator
%   Y = VCO(X,Fc,Fs) creates a signal which oscillates at a frequency
%   determined by the input vector X.  Fc is the carrier or reference 
%   frequency, and Fs is the sampling frequency; if you input 0 for X, 
%   Y will be a Fc Hertz cosine with amplitude 1 sampled at Fs Hertz.  
%   The range of values for X is from -1 to 1; -1 corresponds to a 0 
%   frequency output, 0 to Fc and 1 to 2*Fc.  Y is the same size as X.
%
%   Y = VCO(X,[Fmin Fmax],Fs) scales the frequency modulation range so 
%   that -1 and 1 values of X yield oscillations of Fmin and Fmax 
%   Hertz respectively.  For best results, Fmin and Fmax should be in
%   the range 0 to Fs/2.
%
%       If you do not specify either Fc or Fs, VCO uses the default values
%   Fs = 1 and Fc = Fs/4.
%
%   If X is a matrix, VCO produces a matrix whose columns oscillate
%   according to the columns of X.
%
%   See also MODULATE, DEMOD.

% 	Author(s): T. Krauss, 1993
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:14:43 $

if nargin<3
    Fs = 1;
end
if nargin<2
    Fc = Fs/4;
    range = Fc;
end
x_max = max(max(x));
x_min = min(min(x));
if (x_max>1)|(x_min<-1)
    error('   X outside of range [-1,1]')
end
if length(range)>1
    Fc = mean(range);
    range = (range(2) - Fc)/Fs*2*pi;
else
    Fc = range;
    range = (Fc/Fs)*2*pi;
end

y = modulate(x,Fc,Fs,'fm',range);

