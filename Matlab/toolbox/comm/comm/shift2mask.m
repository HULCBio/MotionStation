function mask = shift2mask(prpoly, shift)
%SHIFT2MASK Convert shift to mask vector for a shift register configuration.
%   MASK = SHIFT2MASK(PRPOLY, SHIFT) returns the equivalent mask for a
%   specified shift (or offset) for a linear feedback shift register whose
%   connections are given by the primitive polynomial, PRPOLY. 
%  
%   The primitive polynomial, PRPOLY must either be a binary vector of 
%   coefficients in descending powers or an equivalent scalar decimal number.
%   The SHIFT parameter must be an integer scalar.
%  
%   Example:
%     For a polynomial x^3 + x + 1, and a shift of 2,
%     m = shift2mask([1 0 1 1], 2)
%     returns  
%
%     m = 
%
%          1  0  0
%
%   See also MASK2SHIFT, GF/DECONV, ISPRIMITIVE, PRIMPOLY, DE2BI.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:01:23 $

error(nargchk(2,2,nargin));

% Convert to binary vector
if isscalar(prpoly)
    if (prpoly < 3) % => [1 1]
        error('Invalid primitive polynomial parameter specified.');
    end
    prpoly = de2bi(prpoly, 'left-msb');
end

% Check for polynomial argument
if ( ~( isvector(prpoly) && ~isempty(prpoly) && ~isscalar(prpoly) ) | ...
     any(prpoly~=1 & prpoly~=0) | prpoly(1)==0 | prpoly(end)==0)
    error('The primitive polynomial must be a binary vector of coefficients in descending powers.');
end

% Check for shift argument
if ( ~isscalar(shift) | ~isreal(shift) | floor(shift) ~= shift )
    error('The shift parameter must be a scalar real integer.');
end

% Compute degree/order of polynomial
ord = length(prpoly)-1;
if ord > 53
    error('Only primitive polynomials of degree 53 or less are allowed.');
end

% Revise the shift desired to be in range of [0,...,period]
shift = rem(shift, 2^ord - 1);
if (shift < 0)
    shift = shift + 2^ord - 1;
end

% Function call
mask = sh2mkormk2sh(prpoly, shift);

% [EOF]
