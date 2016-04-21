function y=cellpipe(x)
% CELLPIPE Convert between pipe-delimited strings and a cell-array
%   of strings.
%
%   If input is a string, it is assumed to be a pipe-delimited string;
%     a cell-array of strings is returned.
%   If input is a cell-array, it is assumed to be a cell-array of strings;
%     a pipe-delimited string is returned.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 20:52:22 $

if isstr(x),
   y=pipe2cell(x);
elseif iscell(x),
   y=cell2pipe(x);
else
   error('Input must be either a string or a cell-array of strings.');
end

function c = pipe2cell(p)
% PIPE2CELL Convert pipe-delimited string to a cell-array

% Build list of positions indices for the pipe characters.
% Also append one additional index at the end of the list.

% If the pipe-delimited string is empty, return an empty cell
if isempty(p),
   c={}; return
end

pidx = [find(p=='|') length(p)+1];
c = {p(1:pidx(1)-1)}; % Get first string
for i=2:length(pidx), % Get all remaining strings
   next_str = p(pidx(i-1)+1 : pidx(i)-1);
   if isempty(next_str),
      next_str='';  % prevent "Empty string: 1-by-0"
   end
   c{i} = next_str;
end

function p=cell2pipe(c)
% CELL2PIPE Convert cell-array of strings to a pipe-delimited string.

if ~iscell(c),
   error('Input must be a cell array of strings.');
end
c=c(:); % force into a vector cell-array

p=c{1};
for i=2:length(c),
   str=c{i};
   if isempty(str),
      str='';  % Force it to be an empty string
   end
   if ~isstr(str),
      error('Cell array must contain only strings.');
   end
   p=[p '|' str];
end
