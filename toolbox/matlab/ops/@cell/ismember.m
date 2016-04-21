function [tf,loc] = ismember(a,s,flag)
%ISMEMBER True for set member for cell array of strings.
%   ISMEMBER(A,S) for the cell array of strings A returns a logical array of
%   the same size as A containing 1 where the elements of A are in the set S
%   and 0 otherwise.
%
%   [TF,LOC] = ISMEMBER(...) also returns an index array LOC containing the
%   highest absolute index in S for each element in A which is a member of S
%   and 0 if there is no such index.
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, UNION.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.5 $  $Date: 2004/04/16 22:07:36 $


% handle input
if nargin < 2
    error('MATLAB:ISMEMBER:NumberOfInputs','Not enough input arguments.');
elseif nargin > 2
    error('MATLAB:ISMEMBER:NumberOfInputs','Too many input arguments.');
end
if ~((ischar(a) || iscellstr(a)) && (ischar(s) || iscellstr(s)))
   error('MATLAB:ISMEMBER:InputClass','Input must be cell arrays of strings.')
end

% convert input to cell arrays of strings
if ischar(a), a = cellstr(a); end
if ischar(s), s = cellstr(s); end

% handle special empty cases
if isempty(a) && isempty(s)
   tf = logical([]); % indefinite result. 
   loc = []; % indefinite result. 
   return
elseif length(s) == 1 && cellfun('isempty',s)
	tempTF = cellfun('isempty',a);
	if any(tempTF(:))
		tf = tempTF;				%in case where s is empty, a is found
								   %in s when a is empty      
		loc = double(tf);           %location = 1 since s has only one member
		return
	end
end

lS = cellfun('length',s);
lengthS = length(lS(:));
memS = max(lS(:)) * lengthS;

% work in chunks of at most 16Mb
maxMem = 8e6;
stepsS = ceil(memS/maxMem);
if memS 
   offset = ceil(lengthS/stepsS);
else
   offset = lengthS;
end

lengthA = numel(a);
tf = false(lengthA,1);
loc = zeros(lengthA,1);
chunkEnd  = lengthS;

while chunkEnd >0
    chunkStart = chunkEnd - offset;
    if chunkStart < 1, chunkStart = 1;end
    chunk = chunkStart:chunkEnd; 
    chunkEnd = chunkStart -1;
    % Only return required arguments from ISMEMBER.
    if nargout > 1
        [tfstep,locstep] = ismember(char(a),char(s(chunk)),'rows');
        loc = max(loc,locstep + chunkStart - 1);
    else
        tfstep = ismember(char(a),char(s(chunk)),'rows');
    end
    tf = tf | tfstep;
end

tf = reshape(tf,size(a));

if nargout > 1
    loc = reshape(loc,size(a));
end
