function f = wordlength(q)
%WORDLENGTH  Word length of a quantizer object.
%   WORDLENGTH(Q) returns the word length in bits of quantizer object Q.
%   The word length is the first element of FORMAT(Q).
%
%   Example:
%     q = quantizer('double');
%     wordlength(q)
%   returns 64.
%
%   See also QUANTIZER, QUANTIZER/FORMAT, QUANTIZER/FRACTIONLENGTH,
%   QUANTIZER/EXPONENTLENGTH. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:33:40 $

f = q.quantizer.wordlength;
