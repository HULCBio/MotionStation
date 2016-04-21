function a = ipermute(b,order)
%IPERMUTE Inverse permute array dimensions.
%   A = IPERMUTE(B,ORDER) is the inverse of permute. IPERMUTE
%   rearranges the dimensions of B so that PERMUTE(A,ORDER) will
%   produce B.  The array produced has the same values of A but the
%   order of the subscripts needed to access any particular element
%   are rearranged as specified by ORDER.  The elements of ORDER must be a
%   rearrangement of the numbers from 1 to N.
%
%   PERMUTE and IPERMUTE are a generalization of transpose (.') 
%   for N-D arrays.
%
%   Example
%      a = rand(1,2,3,4);
%      b = permute(a,[3 2 1 4]);
%      c = ipermute(b,[3 2 1 4]); % a and c are equal
%
%   See also PERMUTE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 03:46:29 $

ndx = [order ones(1,ndims(b)-length(order))];
ndx(ndx) = 1:max(length(order),ndims(b));  % Inverse permutation order

a = permute(b,ndx);
