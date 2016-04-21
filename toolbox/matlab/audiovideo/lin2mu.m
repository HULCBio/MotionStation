function mu = lin2mu(y)
%LIN2MU Convert linear signal to mu-law encoding.
%   MU = LIN2MU(Y) converts linear audio signal amplitudes
%   in the range  -1 <= Y <= 1 to mu-law encoded "flints"
%   in the range 0 <= MU <= 255.
%
%   See also MU2LIN, AUWRITE for more details and references.

%   C. B. Moler, 3-9-91, 4-26-92.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:43 $

% The mu-law encoding is sort of like an 8-bit floating point
% number system.  Essentially, we break the elements of y
% into their floating point exponents and fractions, make some
% sign and bias adjustments, and then put some of the bits
% back together to form bytes stored in floating point form.
%
% Note that for mu = 0:255, lin2mu(mu2lin(mu)) == mu, except
% for mu = 127 because lin2mu(0) could equal either 127 or 255.

SCALE  = 32768;
BIAS   =   132;
CLIP   = 32635;
OFFSET =   335;

y = SCALE*y;
sig = sign(y) + (y==0);
y = min(abs(y),CLIP);
[f,e] = log2(y+BIAS);
mu = 64*sig - 16*e - fix(32*f) + OFFSET;
