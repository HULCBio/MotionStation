function [c,ia,ib] = union(a,b,flag)
%UNION  Set union for cell array of strings.
%   UNION(A,B) when A and B are vectors returns the combined values
%   from A and B but with no repetitions.  The result will be sorted.
%
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such
%   that C is a sorted combination of the elements A(IA) and B(IB).
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.3 $  $Date: 2004/01/24 09:22:21 $


nIn = nargin;

if nIn < 2
  error('MATLAB:union:TooFewInputs', 'Not enough input arguments.');
elseif nIn > 2
  error('MATLAB:union:TooManyInputs', 'Too many input arguments.');
end

if ischar(a), a = cellstr(a); end
if ischar(b), b = cellstr(b); end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
            ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

isrow = ~((size(a,1)>1 && size(b,2)<=1) || (size(b,1)>1 && size(a,2)<=1));
a = a(:); b = b(:);
lenA = length(a);
lenB = length(b);
if ispc && (lenB == lenA) && lenA > 0 && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This hack is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.
	S = rand('state');
    rand('state',1);
    r = randperm(lenA);
    a = a(r); 
    b = b(r); 
    rand('state',S);
end

% Only return required arguments from UNIQUE.
if nargout > 1
    [c,ndx] = unique([a;b]);    
else
    c = unique([a;b]);
    ndx = [];
end
if (isempty(c) && ambiguous)
  c = reshape(c,0,0);
  ia = [];
  ib = [];
elseif isrow
  c = c'; ndx = ndx';
end

if nargout > 1 % Create index vectors.
  n = length(a);
  d = ndx > n;
  ia = ndx(~d);
  ib = ndx(d)-n;
end
