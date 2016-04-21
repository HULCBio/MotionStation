function fmt = format(q)
%FORMAT  Format of a quantizer object.
%   FORMAT(Q) returns the value of the FORMAT property of quantizer object
%   Q.  
%
%   If Q is a fixed-point quantizer, then FORMAT(Q) = [W, F] where W is the
%   wordlength in bits, and F is the fractionlength in bits.  For signed
%   fixed-point (MODE(Q)='FIXED'), 53 >= W > F >= 0.  For unsigned fixed point
%   (MODE(Q)='UFIXED'), 53 >= W >= F >= 0.
%
%   If Q is a floating-point quantizer, then FORMAT(Q) = [W, E] where W is
%   the wordlength in bits, and E is the exponentlength in bits.
%   64 >= W > E > 0, and 11 >= E.
%
%   Examples:
%     q = quantizer('single');
%     format(q)
%   returns [32 8].
%
%     q = quantizer([8 7]);
%     format(q)
%   returns [8 7].
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/SET, QUANTIZER/MODE,
%   QUANTIZER/WORDLENGTH, QUANTIZER/FRACTIONLENGTH,
%   QUANTIZER/EXPONENTLENGTH. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:35:00 $

fmt = get(q,'format');

