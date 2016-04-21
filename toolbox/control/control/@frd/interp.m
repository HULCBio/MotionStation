function sys = interp(sys,w)
%INTERP  Interpolates FRD model between frequency points.
%
%   ISYS = INTERP(SYS,FREQS) interpolates the frequency response
%   data contained in the FRD model SYS at the frequencies FREQS.
%   INTERP uses linear interpolation and returns an FRD model ISYS
%   containing the interpolated data at the new frequencies FREQS.
%
%   The frequency values FREQS should be expressed in the same 
%   units as SYS.FREQUENCY and lie between the smallest and largest
%   frequency points in SYS (extrapolation is not supported). 
%
%   See also FREQRESP, LTIMODELS.

%   Author(s):  P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:17:43 $

error(nargchk(2,2,nargin));
if ~isa(w,'double') | ndims(w)>2 | min(size(w))>1,
   error('W must be a vector of real frequencies.')
elseif ~isreal(w)
   error('Frequencies must be real numbers.')
elseif length(w) & ~length(sys.Frequency)
   error('FRD model contains no data.')
end

% Perform linear interpolation
try
   sys.ResponseData = linear(sys,w);
   sys.Frequency = w(:);
catch
   rethrow(lasterror)
end



