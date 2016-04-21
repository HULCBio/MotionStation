function resp = p_ind2sub(nn,siz,ndx,arrayorder)
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

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:13:41 $

error(nargchk(3,4,nargin));
ndx = reshape(ndx,[],1);
resp = [];
n = length(siz);
ndx = ndx - 1;
if nargin==4 & strcmp(arrayorder,'row-major')
    k = [fliplr(cumprod(fliplr(siz(2:end)))) 1];     
	for i = 1:n,
      resp = horzcat(resp,floor(ndx/k(i))+1);
      ndx = rem(ndx,k(i));
    end
else
    k = [1 cumprod(siz(1:end-1))];
	for i = n:-1:1,
      resp = horzcat(floor(ndx/k(i))+1,resp);
      ndx = rem(ndx,k(i));
    end
end

% [EOF] p_ind2sub.m