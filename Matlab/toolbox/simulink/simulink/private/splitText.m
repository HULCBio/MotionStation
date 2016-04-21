function retCellArray = splitText(strToSplit,splittingStr)
% SPLITTEXT splits the input string strToSplit into elements of the
% returned cell array retCellArray. The splitting is done using the
% regular expression string splittingStr, which should be able to
% serve as input to the REGEXP function.

% Copyright 2004 The MathWorks, Inc.

retCellArray = {};
retStrToSplit= strtrim(strToSplit);

[splitStartIdx,splitEndIdx] = regexp(retStrToSplit,splittingStr);

if isempty(splitStartIdx)
  retCellArray = {retStrToSplit};
  return;
end

if splitStartIdx(1) ~= 1
  startIdx = [1 (splitEndIdx+1)];
  endIdx   = [(splitStartIdx-1) length(retStrToSplit)];
else
  startIdx = [splitEndIdx+1];
  endIdx   = [(splitStartIdx(2:end)-1) length(retStrToSplit)];
  retCellArray{1} = '';
end

for idx = 1:length(startIdx)
  retCellArray = {retCellArray{:} ...
                  retStrToSplit(startIdx(idx):endIdx(idx))};
end
