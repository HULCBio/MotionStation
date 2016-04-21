function n = innerprodintbits(U,V)
%INNERPRODINTBITS  Number of integer bits for fixed-point inner product.
%
%   INNERPRODINTBITS(U,V) computes the minimum number of integer bits
%   necessary in the inner product of U'*V to guarantee that no overflow
%   will occur and to preserve the best precision such that:
%
%     * both U and V are fi vectors
%     * the values of U are known
%     * only the numeric type of V is relevant (the values are ignored)
%
%   The main use of this function is to determine the number of integer
%   bits necessary in the output Y of an FIR filter that computes the
%   inner product between constant coefficient row vector B and state
%   column vector Z.  For example,
%
%     for k=1:length(X);
%       Z = [X(k);Z(1:end-1)];
%       Y(k) = B * Z;
%     end
%
%   Algorithm:  
%
%   In general, an inner product will grow log2(n) bits for vectors of
%   length n.  However, we know everything about the vector U and they
%   aren't going to change, so we take advantage of that to compute the
%   smallest number of integer bits that are necessary in the output to
%   guarantee that no overflow will occur.
%
%   The largest gain will be when vector V is lined up in sign with the
%   constant vector U.  Thus, the largest gain due to the U will be
%   U*sign(U'), which is equal to sum(abs(U)).  Add log2 of this to the
%   number of integer bits in V plus one bit for the sign (in case of
%   -1*-1) to get the overall number of integer bits necessary to
%   guarantee that no overflow will occur in the inner product.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/20 23:18:32 $

if ~isfi(U) || ~isfi(V)
  error('Both arguments must be fi objects.')
end

maxgain = sum(abs(double(U)));
n = ceil(log2(maxgain)) + V.WordLength - V.FractionLength;

if U.Signed && V.Signed
  % Add an extra bit if both U and V are signed to handle the possibility
  % of (-1)*(-1).
  n = n+1;
end

