function [c,ia] = setdiff(a,b,flag)
%SETDIFF Set difference for cell array of strings.
%   SETDIFF(A,B) when A and B are vectors returns the values
%   in A that are not in B. The result will be sorted.
%
%   [C,I] = SETDIFF(A,B) also returns an index vector I such that
%   C = A(I).
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.3 $  $Date: 2004/01/24 09:22:19 $
%--------------------------------------------------------------------
% handle inputs

nIn = nargin;
nOut = nargout;

if nIn < 2
    error('MATLAB:CELL:SETDIFF:NotEnoughInputs',...
        'Not enough input arguments.'); 
elseif nIn > 2
    warning('MATLAB:CELL:SETDIFF:RowsFlagIgnored',...
        '''rows'' flag is ignored for cell arrays.'); 
end

if ~any([iscellstr(a),iscellstr(b),ischar(a),ischar(b)])
    error('MATLAB:CELL:SETDIFF','Input must be cell arrays of strings or strings')
end

ia = [];

if isempty(a)
    if ~iscell(a)
        c = {};
    else
        c = a;
        ia = zeros(size(a));
    end
    return
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
    ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

% check and set flag if input is a row vector.
if ~iscell(a)
    a = cellstr(a);
end

if isempty(b)
    b = {};
elseif ~iscell(b)
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
else
    [a,ia] = unique(a);
end

if ispc && (length(b) == length(a)) && (length(a) > 0) && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This hack is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.
	S = rand('state');
    rand('state',1);
	r =randperm(length(a)); 
    a = a(r); 
	b = b(r); 
	if nOut > 1
		ia = ia(r);
	end
    rand('state',S);
end
    
[c,ndx] = sort([a;b]);

d = ~strcmp(c(1:end-1),c(2:end));
n = size(a,1);
if length(c) > 1
    d(end + 1,1) = 1;
else if length(c) == 1 
        if n > 0
            ia = 1;
            return 
        end
    end
end
% d = 1 now for any unmatched entry of A or of B.

d = d & (ndx <= n); % Now find only the ones in A.

c = c(d);
if nOut > 1
    ia = ia(ndx(d));
end

if (isrowa || isrowb) && ~isempty(c) || ((isrowa && isrowb) && isempty(c) )
    c = c';
    ia = ia';
end

if (isempty(c) && ambiguous)
    c = reshape(c,0,0);
end
