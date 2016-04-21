function y = mu2lin(mu)
%MU2LIN Convert mu-law encoding to linear signal.
%   Y = MU2LIN(MU) converts mu-law encoded 8-bit audio signals,
%   stored as "flints" in the range 0 <= MU <= 255, to
%   linear signal amplitude in the range -s < Y < s where
%   s = 32124/32768 ~= .9803.  The input MU is often obtained 
%   using fread(...,'uchar') to read byte-encoded audio files.
%   "Flints" are MATLAB's integers -- floating point numbers
%   whose values are integers.
%
%   See also LIN2MU, AUREAD.

%  MATLAB translation of C program by:
%  Craig Reese: IDA/Supercomputing Research Center
%  Joe Campbell: Department of Defense
%  29 September 1989
% 
%  References:
%  1) CCITT Recommendation G.711.
%  2) "A New Digital Technique for Implementation of Any
%      Continuous PCM Companding Law," Villeret, Michel,
%      et al. 1973 IEEE Int. Conf. on Communications, Vol 1,
%      1973, pg. 11.12-11.17.
%  3) MIL-STD-188-113,"Interoperability and Performance Standards
%      for Analog-to_Digital Conversion Techniques,"
%      17 February 1987.
%   C. B. Moler, 3-9-91.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:44 $

% The mu-law encoding is sort of like an 8-bit floating point
% number system, with one sign bit, s, three exponent bits, e, and
% four fraction bits, f.  We break the elements of mu into these
% three pieces, then use pow2 to put them back together again.

SCALE = 1/32768;
ETAB = [0 132 396 924 1980 4092 8316 16764];

mu = 255 - mu;
sig = mu > 127;
e = fix(mu/16) - 8*sig + 1;
f = rem(mu,16);
y = pow2(f,e+2);
e(:) = ETAB(e);
y = SCALE*(1-2*sig).*(e+y);

