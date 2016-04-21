function [libFileList, srcFileList, objFileList, ...     
          addIncPaths, addLibPaths, addSrcPaths, ...
          preProcDefList, preProcUndefList,      ...
          unrecognizedInfo ] = parseLibCodePaneText(libTextCode)
% This function parses out the following flags from the text in the
% library pane of the S-Function Builder:
%
% 1. $INCLUDE_PATH path1,path2,path3,path4
% 2. $LIB_PATH path1,path2,path3,path4
% 3. $SRC_PATH path1,path2,path3,path4
% 4. -DPREPROCDEF1 -DPREPROCDEF2=1
%    -DPREPROCDEF3
% 5. abc.obj
% 6. pqr.lib
% 7. stu.so
%
% In order for the windows versions to be consistent (especially when there
% can be spaces in the paths), we enforce the comma/semi-colon separated format
% for the features 1,2,3 above.

% Copyright 2004 The MathWorks, Inc.

libFileList = {};
srcFileList = {};
objFileList = {};
addIncPaths = {};
addLibPaths = {};
addSrcPaths = {};
preProcDefList   = {};
preProcUndefList = {};
unrecognizedInfo = {};

libTextCode = [libTextCode sprintf('\n')];
newLineIdx = regexp(libTextCode,sprintf('\n'));
if isempty(newLineIdx)
  newLineIdx = length(libTextCode) + 1;
end

startLineIdx = 1;

for endLineIdx = newLineIdx
  [featureType,parseList] = parseLibCodePaneTextLine( ...
      libTextCode(startLineIdx:endLineIdx-1));

  switch(featureType)
   case 'libFile', libFileList = {libFileList{:},parseList{:}};,
   case 'srcFile', srcFileList = {srcFileList{:},parseList{:}};,
   case 'objFile', objFileList = {objFileList{:},parseList{:}};,
   case 'libPath', addLibPaths = {addLibPaths{:},parseList{:}};,
   case 'srcPath', addSrcPaths = {addSrcPaths{:},parseList{:}};,
   case 'incPath', addIncPaths = {addIncPaths{:},parseList{:}};,
   case 'preProc', preProcDefList   = {preProcDefList{:},parseList{:}};,
   case 'prePrcU', preProcUndefList = {preProcUndefList{:},parseList{:}};,
   otherwise, unrecognizedInfo      = {unrecognizedInfo{:},parseList{:}};,
  end
  
  startLineIdx = endLineIdx+1;
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [featureType,parseList] = parseLibCodePaneTextLine(lineStr)
% parse and return a cell array of objects with tags as to what kind
% of objects they are. In case they are unrecognized, return ''as featureType.
splittingStr = '\,|\;';
retStr       = ' ';

if     ~isempty(regexpi(lineStr,'^\s*INCLUDE_PATH'))
  featureType = 'incPath';
  retStr      = regexprep(lineStr,'INCLUDE_PATH','','ignorecase');
  parseList   = splitText(retStr,splittingStr);
elseif ~isempty(regexpi(lineStr,'^\s*LIB(RARY)?_PATH'))
  featureType = 'libPath';
  retStr      = regexprep(lineStr,'LIB(RARY)?_PATH','','ignorecase');
  parseList   = splitText(retStr,splittingStr);
elseif ~isempty(regexpi(lineStr,'^\s*SRC_PATH'))
  featureType = 'srcPath';
  retStr      = regexprep(lineStr,'SRC_PATH','','ignorecase');
  parseList   = splitText(retStr,splittingStr);
elseif ~isempty(regexpi(lineStr,'^\s*\-D'))
  featureType = 'preProc';
  parseList   = splitText(lineStr,[splittingStr '|\-(D|d)']);
elseif ~isempty(regexpi(lineStr,'^\s*\-U'))
  featureType = 'prePrcU';
  parseList   = splitText(lineStr,[splittingStr '|\-(U|u)']);
elseif ~isempty(regexpi(lineStr,'\.o(bj)?\s*$'))
  featureType = 'objFile';
  parseList   = splitText(lineStr,splittingStr);
elseif ~isempty(regexpi(lineStr,'\.c(pp)?\s*$'))
  featureType = 'srcFile';
  parseList   = splitText(lineStr,splittingStr);
elseif ~isempty(regexpi(lineStr,'\.((lib)|(a)|(so))\s*$'))
  featureType = 'libFile';
  parseList   = splitText(lineStr,splittingStr);
else
  featureType = '';
  retStr = lineStr;
  parseList   = {retStr};
end

if isempty(parseList)
  retStr = lineStr;
  parseList = {retStr};
elseif isequal(featureType,'incPath') || isequal(featureType,'libPath') ||...
       isequal(featureType,'srcPath')
  for idx = 1:length(parseList)
    if ~isempty(parseList{idx})
        parseList{idx} = strrep(parseList{idx},'$MATLABROOT',matlabroot);
    end
  end
end
