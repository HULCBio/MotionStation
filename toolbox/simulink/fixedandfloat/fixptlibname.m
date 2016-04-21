function name = fixptlibname(keywordStr,categoryStr);
%FIXPTLIBNAME Return name of the latest version of the Simulink library
%
% Advanced usage:
%   name = FIXPTLIBNAME(keywords,category)
% This function can also find the names of subsystems or blocks based on
% two optional inputs.
%  category      specifies seek a block or a library/subsystem (default)
%  keywords      can be a string or a cell of strings of criteria for name

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.9.2.4 $  
% $Date: 2004/04/15 00:34:49 $

baseLib = ['simulink'];

%
% default result is the name of the base library
%
name = baseLib;

if nargin < 1
  %
  % no arguments, so return early with default
  return
end
load_system(baseLib);

keywordStr = upper(keywordStr);

if nargin < 2
  categoryStr = 'LIB';
end

categoryStr = upper(categoryStr);

if ~isempty(findstr(categoryStr,'LIB'))
  %
  % find a library or subsystem based on keyword
  %
  libNames = find_system(baseLib,'SearchDepth',1);

  matches = {};
  for i = 1:length(libNames)
    if findstr_all(upper(libNames{i}),keywordStr)
      matches{end+1} = libNames{i};
    end
  end

  if isempty(matches)
    return;
  else
    % of all the matches, return the one with the shortest name
    lens = [];
    for i = 1:length(matches)
      lens(end+1) = length(matches{i});
    end
    [minlen,iminlen]=min(lens);    
    name = matches{iminlen};
  end

elseif ~isempty(findstr(categoryStr,'BL'))
  %
  linkedBlocks = find_system(baseLib,'Type','block','LinkStatus','resolved');
  %
  baseLibraries = {baseLib};
  for i = 1:length(linkedBlocks)
    refBlock = get_param(linkedBlocks{i},'referenceblock');
    if ~isempty(findstr(get_param(linkedBlocks{i},'referenceblock'),'fxlib_'))
      baseLibraries{end+1} = bdroot(refBlock);
    end  
  end
  %  
  % find a block based on keyword
  %
  for i = 1:length(baseLibraries)
    load_system(baseLibraries{i});
  end
  fixptlib_blocks = find_system(baseLibraries, 'Type', 'block','LinkStatus','none');
  numFixptBlocks = length(fixptlib_blocks);

  matches = {};
  for i = 1:numFixptBlocks
    curBlk = fixptlib_blocks{i};
    if ~isempty(get_param(curBlk,'MaskType'))
      curType = upper(get_param(curBlk,'MaskType'));
    else
      curType = upper(get_param(curBlk,'BlockType'));
    end
    if findstr_all(curType,keywordStr)
      matches{end+1} = curBlk;
    end
  end

  % map gateway in and gateway out
  if findstr_all('GATEWAY IN',keywordStr)
    matches{length(matches)+1} = sprintf('simulink/Signal\nAttributes/Data Type Conversion');
  end
  if findstr_all('GATEWAY OUT',keywordStr)
    matches{length(matches)+1} = sprintf('simulink/Signal\nAttributes/Data Type Conversion');
  end

  if ~isempty(matches)
    % of all the matches, return the one with the shortest name
    lens = [];
    for i = 1:length(matches)
      lens(end+1) = length(matches{i});
    end
    [minlen,iminlen]=min(lens);    
    name = matches{iminlen};
  end
end
    
function boolResult = findstr_all(a,b)
%
% this is a support function for doing a keywords search
% the inputs can be strings or cell arrays of strings
%
if ~iscell(a)
  a = { a };
end

if ~iscell(b)
  b = { b };
end

for i=1:length(a)
  for j=1:length(b)
    if isempty(findstr(a{i},b{j}))
      boolResult = 0;
      return
    end
  end
end
boolResult = 1;
