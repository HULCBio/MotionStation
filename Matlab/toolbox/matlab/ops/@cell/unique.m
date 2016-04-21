function [b,ndx,pos] = unique(a,flag)
%UNIQUE Return unique set for a cell array of strings.
%   UNIQUE(A) for the cell vector A returns the same strings as in A but
%   with no repetitions.  A will be also be sorted.
%
%   [B,I,J] = UNIQUE(A) also returns index vectors I and J such
%   that B = A(I) and A = B(J) (or B = A(I,:) and A = B(J,:)).
%   
%   See also UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:07:37 $
% ----------------------------------------------------------------------------------------------------
if nargin>1, 
   warning('MATLAB:CELL:UNIQUE:RowsFlagIgnored','''rows'' flag is ignored for cell arrays.'); 
end

if ~iscellstr(a)
   error('MATLAB:CELL:UNIQUE:InputClass','Input must be a cell array of strings.')
end

% check is input is a column vector with each element a single row text array.
if any(cellfun('size',a,1)>1)
   error('MATLAB:CELL:UNIQUE:NotARowVector','Each element in A must be a single-row text array.')
end

% initialise output variables
if isempty(a)
   b = {};
   ndx = [];
   pos = [];
   return
end

% number of elements in input
numelA = numel(a);

% check and set flag if input is a row vector.
isrow = ndims(a)==2 && size(a,1)==1;
if isrow
   a = a'; % transpose to column vector
end

% initialise variables
[m,n] = size(a);
d = zeros(m-1,1);

% first sort the rows of the cell array.
[b,ndx] = sort(a);

if m > 1 && n ~= 0
    d = ~strcmp(b(1:end-1),b(2:end));
end

% Final element is always a member of unique list.
d(numelA,1) = 1;

% extract unique elements
b = b(d);

% create position index vector
pos = cumsum([1;d]);
% Remove extra element introduced by d.
pos(numelA+1) = [];     
% Re-reference POS to indexing of SORT.
pos(ndx) = pos;

% create index vector
ndx = ndx(d);

% if the original input was a row vector, transpose unique result, indices and inverse indices to row vectors
if isrow
  b = b'; 
  ndx = ndx';
  pos = pos';
end
% ----------------------------------------------------------------------------------------------------

