function Hd = fftfir(varargin)
%FFTFIR Overlap-add FIR.
%   Hd = DFILT.FFTFIR(NUM,L) constructs a discrete-time FIR filter object
%   for filtering using the overlap-add method.
%
%   NUM is a vector of numerator coefficients.
%
%   L is the length of each block of input data used in the filtering.
%
%   The number of FFT points is given by L+length(NUM)-1. It may be
%   advantageous to choose L such that the number of FFT points is a power
%   of two.
%
%   % EXAMPLE
%   b = [0.05 0.9 0.05];
%   len = 50;
%   Hd = dfilt.fftfir(b,len)
%
%   See also DFILT.   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:00:02 $

Hd = dfilt.fftfir(varargin{:});

% [EOF]
