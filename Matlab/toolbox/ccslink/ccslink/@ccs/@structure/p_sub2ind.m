function ndx = p_sub2ind(nn,siz,subndx,arrayorder)
%SUB2IND Linear index from multiple subscripts.
%   SUB2IND is used to determine the equivalent single index
%   corresponding to a given set of subscript values.
%
%   IND = SUB2IND(SIZ,I,J) returns the linear index equivalent to the
%   row and column subscripts in the arrays I and J for an matrix of
%   size SIZ.
%
%   IND = SUB2IND(SIZ,I1,I2,...,In) returns the linear index
%   equivalent to the N subscripts in the arrays I1,I2,...,In for an
%   array of size SIZ.
%
%   See also IND2SUB.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:13:43 $

error(nargchk(3,4,nargin));
for i=size(subndx,2):-1:1,
  mn(i) = min(subndx(:,i));
  mx(i) = max(subndx(:,i));
  s{i} = size(subndx(:,i));
end
if any(mn < 1) | any(mx > siz), error('Out of range index.'); end
if length(s)>1 & ~isequal(s{:}),
   error('The subscripts must all the be same size.');
end
n = length(siz);
if nargin==4 & strcmp(arrayorder,'row-major')
	k = [fliplr(cumprod(fliplr(siz(2:end)))) 1];
	ndx = 1;
	for i = 1:n,
      ndx = ndx + (subndx(:,i)-1)*k(i);
	end
else
	k = [1 cumprod(siz(1:end-1))];
	ndx = 1;
	for i = 1:n,
      ndx = ndx + (subndx(:,i)-1)*k(i);
	end
end

% [EOF] p_sub2ind.m