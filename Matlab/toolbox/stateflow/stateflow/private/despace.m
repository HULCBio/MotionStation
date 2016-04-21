function x = despace(x),
% X = DESPACE(X)  Vectorized routine that expects a space padded matrix
% as input and returns the matrix with a zero at the end of each valid
% string segment in each row.

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13.2.1 $  $Date: 2004/04/15 00:56:44 $

if (isempty(x) | iscell(x)) return; end;

[m,n] = size(x);
mask = x~=' ' & x~=0;
[i,j] = find(mask);
[ui,jInd] = unique(i);
ind = j(jInd);
if isempty(ind)
	good = [];
else
	good = find(ind~=n);
end
ind=ind(good); ui=ui(good);
x(m*ind + ui) = 0;
x(all(~mask.'),1) = 0; % also catch any rows with just spaces


 
