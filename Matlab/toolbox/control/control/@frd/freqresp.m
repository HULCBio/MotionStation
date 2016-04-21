function h = freqresp(sys,w)
%FREQRESP  Frequency response of LTI models.
%
%   H = FREQRESP(SYS,W) computes the frequency response H of the 
%   LTI model SYS at the frequencies specified by the vector W.
%   These frequencies should be real and in radians/second.  
%
%   If SYS has NY outputs and NU inputs, and W contains NW frequencies, 
%   the output H is a NY-by-NU-by-NW array such that H(:,:,k) gives 
%   the response at the frequency W(k).
%
%   If SYS is a S1-by-...-Sp array of LTI models with NY outputs and 
%   NU inputs, then SIZE(H)=[NY NU NW S1 ... Sp] where NW=LENGTH(W).
%
%   See also EVALFR, BODE, SIGMA, NYQUIST, NICHOLS, LTIMODELS.

%   Author(s):  S. Almy, P. Gahinet
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.12 $  $Date: 2002/04/10 06:17:47 $

error(nargchk(2,2,nargin));
if ~isa(w,'double') | ndims(w)>2 | min(size(w))>1,
   error('W must be a vector of real frequencies.')
elseif ~isreal(w)
   error('Frequencies must be real numbers.')
elseif length(w) & ~length(sys.Frequency)
   error('FRD model contains no data.')
end

% Absorb time delays
if hasdelay(sys)
   sys = delay2z(sys);
end

% Convert FRD units to rad/s (W always expressed in these units)
sys = chgunits(sys,'rad/s');

% Interpolate response data linearly at new frequencies
try
   h = linear(sys,w);
catch
   rethrow(lasterror)
end
