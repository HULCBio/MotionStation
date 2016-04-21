%FILTMSB Most significant bit of a CIC filter.
%   FILTMSB(Hm) is the most significant bit (MSB) of the filter output and 
%   is a function of the parameters, R, M, N and the InputBitWidth.  Since the 
%   output of the integrators can grow without bound, this MSB represents the 
%   maximum number of bits, which can be propagated through the filter without 
%   loss of data. This MSB is not only the MSB at the filter output; it is also 
%   the MSB for all stages.  
%
%   See also MFILT, MFILT/GAIN

%   Author: P. Costa
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/11/07 14:37:52 $

% Help for the MFILT.CICDECIM & MFILT.CICINTERP FILTMSB methods.

% [EOF]
