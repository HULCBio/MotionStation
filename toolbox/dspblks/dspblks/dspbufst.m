function st = dspbufst(Ts, bufsize, initial_offset)
% DSPBUFST  Compute sample times for Signal Processing Blockset buffer 
%       and unbuffer blocks. 
%	DSPBUFST(Ts,N,Ko) is a 2-by-2 matrix whose first row is the fast 
%	(base) sample rate and offset and whose second row is the slow 
%	sample rate and offset, for a Buffer / Unbuffer pair with base 
%	sample rate Ts, buffer length N, and initial unbuffer offset Ko.
%	
%	This function is called in the masks of the obsolete Buffer and
%       Unbuffer blocks in the Signal Processing Blockset.

%	Copyright 1995-2003 The MathWorks, Inc.
%	$Revision: 1.7.4.2 $ $Date: 2004/04/12 23:05:14 $ 

st = Ts(:)';   % either 1 or 2 elements
st(2,2) = 0;   % grow the matrix
st(2,1) = st(1)*bufsize;
st(2,2) = rem(st(1,2)+st(1,1)*initial_offset,st(2,1));

% Clear result if fp x./y falls short of the true x./y and fix is too small.
% In other words, if offset of slow task creeps too close to the sample
% time of the slow task, set the offset back to 0.

if ( abs(st(2,2)-st(2,1))./st(2,1) < sqrt(eps) )
    st(2,2) = 0;
end

% Also set VERY small offsets equal to zero:
if ( abs(st(2,2))./st(1,1) < 1e-10 )
    st(2,2) = 0;
end

