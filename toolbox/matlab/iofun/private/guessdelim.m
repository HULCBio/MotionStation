function delim = guessdelim(str)
%GUESSDELIM Take stab at default delim for this string.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:25:28 $

% bail if str is empty
if isempty(str)
    delim = '';
    return;
end

% count num lines
numLines = length(find(str == sprintf('\n')));

% set of column delimiters to try - ordered by quality as delim
delims = {sprintf('\t'), ',', ';', ':', '|', ' '};

% remove any delims which don't appear at all
% need to rethink based on headers and footers which are plain text
goodDelims = {};
goodDelimCounts = [];
for i = 1:length(delims)
    numDelims(i) = length(find(str == sprintf(delims{i})));
    if numDelims(i) ~= 0
        % this could be a delim
        goodDelims{end+1} = delims{i};
    end
end

% if no delims were found, return empty string
if isempty(goodDelims)
    delim = '';
    return;
end

% if the num delims is greater or equal to num lines,
% this will be the default (so return)
for i = 1:length(delims)
    delim = delims{i};
    if numDelims(i) > numLines
        return;
    end
end

% no delimiter was a clear win from above, choose the first
% in the delimiter list
delim = goodDelims{1};

