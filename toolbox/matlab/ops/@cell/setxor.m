function [c,ia,ib] = setxor(a,b,flag)
%SETXOR Set exclusive-or for cell array of strings.
%   SETXOR(A,B) when A and B are vectors returns the values that are
%   not in the intersection of A and B.  The result will be sorted.
%
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such
%   that C is a sorted combination of the elements of A(IA) and B(IB).
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.3 $  $Date: 2004/01/24 09:22:20 $
%--------------------------------------------------------------------
% handle inputs

nIn = nargin;
nOut = nargout;

if nIn < 2
    error('MATLAB:CELL:SETXOR:NotEnoughInputs',...
        'Not enough input arguments.'); 
elseif nIn > 2
    warning('MATLAB:CELL:SETXOR:RowsFlagIgnored',...
        '''rows'' flag is ignored for cell arrays.'); 
end

if ~any([iscellstr(a),iscellstr(b),ischar(a),ischar(b)])
    error('MATLAB:CELL:SETXOR','Input must be cell arrays of strings or strings')
end

ia = [];
ib = [];

if isempty(b) 
    c = a;
    ia = 1:length(a);
    return
end

if isempty(a) 
    c = b;
    ib = 1:length(b);
    return
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
    ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

% check and set flag if input is a row vector.
if ~iscell(a)
    a = cellstr(a);
end

if ~iscell(b)
    b = cellstr(b);
end

isrowa = ndims(a)==2 & size(a,1)==1;
if isrowa
    a = a'; % transpose to column vector
end

% check and set flag if input is a row vector.
isrowb = ndims(b)==2 & size(b,1)==1;
if isrowa
    b = b'; % transpose to column vector
end

a = a(:);
b = b(:);


if nOut <= 1
    a = unique(a);
    b = unique(b);
else
    [a,ia] = unique(a);
    [b,ib] = unique(b);
end

if ispc && (length(b) == length(a)) && (length(a) > 0) && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This hack is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.	
    S = rand('state');
    rand('state',1);
	r =randperm(length(a)); 
    a = a(r); 
	if nOut > 1
		ia = ia(r);
		ib = ib(r);
	end
    b = b(r); 
    rand('state',S);
end

[c,ndx] = sort([a;b]);

d = ~strcmp(c(1:end-1),c(2:end));
d = [true ;d];
d(end + 1 , 1) = true;

d = ~(d(1:end-1) & d(2:end));

c(d) = [];

if nOut > 1
    n = size(a,1);
    ndx = ndx(~d);
    d = ndx <= n;
    ia = ia(ndx(d));
    ib = ib(ndx(~d) - n);
end

if isrowa || isrowb
    c = c';
    ia = ia';
    ib = ib';
end

if (isempty(c) && ambiguous)
    c = reshape(c,0,0);
    ia = [];
    ib = [];
end

