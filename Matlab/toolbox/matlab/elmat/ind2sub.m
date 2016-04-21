function varargout = ind2sub(siz,ndx)
%IND2SUB Multiple subscripts from linear index.
%   IND2SUB is used to determine the equivalent subscript values
%   corresponding to a given single index into an array.
%
%   [I,J] = IND2SUB(SIZ,IND) returns the arrays I and J containing the
%   equivalent row and column subscripts corresponding to the index
%   matrix IND for a matrix of size SIZ.  
%   For matrices, [I,J] = IND2SUB(SIZE(A),FIND(A>5)) returns the same
%   values as [I,J] = FIND(A>5).
%
%   [I1,I2,I3,...,In] = IND2SUB(SIZ,IND) returns N subscript arrays
%   I1,I2,..,In containing the equivalent N-D array subscripts
%   equivalent to IND for an array of size SIZ.
%
%   See also SUB2IND, FIND.
 
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2003/11/18 03:10:58 $

nout = max(nargout,1);
if length(siz)<=nout,
  siz = [siz ones(1,nout-length(siz))];
else
  siz = [siz(1:nout-1) prod(siz(nout:end))];
end
n = length(siz);
k = [1 cumprod(siz(1:end-1))];
ndx = ndx - 1;
for i = n:-1:1,
  v = floor(ndx/k(i))+1;  
  varargout{i} = v; 
  ndx = rem(ndx,k(i));
end
