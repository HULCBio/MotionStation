function varargout = arrayviewfunc(whichcall, varargin)
%ARRAYVIEWFUNC  Support function for Array Editor component

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2004/04/10 23:23:51 $

varargout = cell(1, 1);
  switch whichcall
    case 'getdata',
      varargout{1} = getData(varargin{1}, varargin{2});
    case 'setdata',
      varargout{1} = setData(varargin{1}, varargin{2}, varargin{3});
    case 'setvarwidth',
      varargout{1} = setVarWidth(varargin{1}, varargin{2});
    case 'setvarheight',
      varargout{1} = setVarHeight(varargin{1}, varargin{2});
    case 'overlayclipboarddata',
      varargout{1} = overlayClipboardData(varargin{:});
    case 'removerowsorcolumns',
      varargout{1} = removeRowsOrColumns(varargin{:});
    case 'insertrowsorcolumns',
      varargout{1} = insertRowsOrColumns(varargin{:});
    case 'renamefield',
      varargout{1} = renameField(varargin{1}, varargin{2}, varargin{3});
    case 'valueHasAppropriateIndexing',
      varargout{1} = valueHasAppropriateIndexing(varargin{:});
    case 'isPossibleIndexedEntityName',
        varargout{1} = isPossibleIndexedEntityName(varargin{:});
    case 'getBaseVariableName',
      varargout{1} = getBaseVariableName(varargin{1});
    otherwise
      error('MATLAB:arrayviewfunc:UnknownOption', ...
          ['Unknown command option ' upper(whichcall)]);
  end

%********************************************************************
function result = getData(x, format)
  if (ischar(x))
	% First, make sure that there aren't a newline in the string.
	% If there are, we can't display it properly.
	if ~isempty(findstr(x, char(10))) || ~isempty(findstr(x, char(13)))
	  result = [];
	  return;
	end
    result = sprintf('%s', x);
  elseif iscellstr(x)
	% First, make sure that there are no newlines in the strings.
	% If there are, we can't display them properly.
	for i = 1:length(x)
	  if ~isempty(findstr(x{i}, char(10))) || ~isempty(findstr(x{i}, char(13)))
		result = [];
		return;
	  end
    end
    % have to pad with a space so java tokenizer will function
    % properly when a cell contains an empty string.
    result = sprintf('%s \n', x{:});
  elseif iscell(x)
    result = [];
  else
    oldFormat = get(0, 'format');
    oldSpacing = get(0, 'formatspacing');

    set(0, 'format', format);
    set(0, 'formatspacing', 'compact');

    result = evalc('disp(x(:))');

    set(0, 'format', oldFormat);
    set(0, 'formatspacing', oldSpacing);
  end;

%********************************************************************
function newRef = setData(var, coord, expr)
  try
    if ischar(var),
      var = expr;
    elseif iscellstr(var),
      var{coord{:}} = expr;
    else
      var(coord{:}) = eval(expr);
    end;

    newRef = system_dependent(45, var);
  catch
    newRef = lasterr;
  end;

%********************************************************************
function newRef = setVarWidth(var, width)
  try
    sz = size(var);
    oldWidth = sz(2);

    if iscellstr(var),
      repl = {''};
    else
      repl = 0;
    end;

    if width > oldWidth,
      var(:,end+1:width) = repl;
    elseif width < oldWidth,
      var(:,width+1:end) = [];
    end;

	newRef = system_dependent(45, var);
  catch
    newRef = lasterr;
  end;

%********************************************************************
function newRef = setVarHeight(var, height)
  try
    sz = size(var);
    oldHeight = sz(1);

    if iscellstr(var),
      repl = {''};
    else
      repl = 0;
    end;

    if height > oldHeight,
      var(end+1:height,:) = repl;
    elseif height < oldHeight,
      var(height+1:end,:) = [];
    end;

	newRef = system_dependent(45, var);
  catch
    newRef = lasterr;
  end;

%********************************************************************
function out = overlayClipboardData(orig, startindices, endindices, xlString)
% Given a variable, the dimensions over which to "overlay" new data,
% and (optionally) a Microsoft Excel clipboard-formatted string, this
% function "overlays" the variable.  If the clipboard-style data is not
% supplied, we will read the clipboard contents.

if nargin < 4
    xlString = clipboard('paste');
end
[x2m1, x2m2] = excelToMatlabData(xlString, orig);
out = overlayDataPrivate (orig, x2m1, startindices, endindices, x2m2);

%********************************************************************
function [outNums, outMask] = excelToMatlabData(in, orig)
% Given the kind of text data that Microsoft Excel puts on the Clipboard,
% generate the MATLAB array that represents that data.
% We handle this differently than MATLAB's xlsread, since this routine must
% also generate a MASK for the data.  Since the array that we generate is
% designed to be pasted  "over" a preexisting MATLAB array, we need to
% be able to position it properly.

% We need orig to determine whether to create cell arrays or normal arrays.
tab = char(9);
cr = char(10);
makeCells = isa(orig, 'cell');

if isa(orig, 'char')
    outNums = in;
    while(length(outNums) > 1) && strcmp(outNums(end), cr)
        outNums = outNums(1:end-1);
    end
    outMask = true;
    return;
end

lines = strread(in, '%d');    
outMask = [];
if ~makeCells
    outNums = [];
else
    outNums = {};
end

for i = 1:length(lines)
    thisLine = lines{i};
    thisLine = [tab thisLine tab];
    if ~makeCells
        thisRow = [];
        thisMaskRow = [];
    end
    tabIndexes = find(thisLine == tab);
    for j = 1:length(tabIndexes)-1
        thisCell = thisLine(tabIndexes(j)+1:tabIndexes(j+1)-1);
        if ~makeCells
            if isempty(thisCell)
                thisElement = '';
            else
                thisElement = str2double(thisCell);
            end
        else
            thisElement = thisCell;
        end
        if ~isempty(thisElement)
            if ~makeCells
                thisRow = [thisRow thisElement];
                thisMaskRow = [thisMaskRow 1];
            else
                outNums{i, j} = thisElement;
                outMask(i, j) = 1;
            end
        else
            if ~makeCells
                thisRow = [thisRow 0];
                thisMaskRow = [thisMaskRow 1];
            else
                outNums{i, j} = '';
                outMask(i, j) = 1;
            end
        end
    end
    if ~makeCells
        outNums = vertcat(outNums, thisRow);
        outMask = vertcat(outMask, thisMaskRow);
    end
end

%********************************************************************
function out = overlayDataPrivate (orig, over, startindices, endindices, mask)
% Given a variable, other data, the dimensions over which to "overlay" that
% data, and a "mask" that may allow some underlying data to remain untouched,
% this function "overlays" the variable.

if isa(orig, 'char') && any(any(mask))
    if isa(over, 'char') && strcmp(over, '0.0')
        over = ' ';
    end
    out = over;
else    
    % Error checking/"growing" the array appropriately.
    if all(startindices == endindices)
        endindices = size(over) + startindices - [1 1];
    else
        targetSize = endindices - startindices + [1 1];
        overSize = size(over);
        if any(overSize ~= targetSize)
            % We either error, or expand the orig and mask to fit integral
            % multiples.
            if any(rem(targetSize, overSize) ~= [0 0])
                error('MATLAB:Desktop:ArrayEditor:dataVsIndexMismatch', 'Specified indices incompatable with overlay size.');
            else
                over = repmat(over, targetSize(1)/overSize(1), targetSize(2)/overSize(2));
                mask = repmat(mask, targetSize(1)/overSize(1), targetSize(2)/overSize(2));
            end
        end
    end
    
    if any(size(over) ~= size(mask))
        error('MATLAB:Desktop:ArrayEditor:dataVsMaskMismatch', 'Mask size incompatable with overlay size.');
    end
    % End error checking
    
    if ~isa(orig, 'cell')
        newMask = zeros(size(orig));
        newMask(startindices(1):endindices(1), startindices(2):endindices(2)) = mask;
        
        newOver = zeros(size(orig));
        newOver(startindices(1):endindices(1), startindices(2):endindices(2)) = over;
        newOver = newOver.*newMask;
        
        reverseMask = ones(size(newMask)) - newMask;
        if any(size(newMask) > size(orig))
            orig(endindices(1), endindices(2)) = 0;
        end
        nanMask = isnan(orig);
        %newOrig(nanMask) = 2;
        orig(nanMask) = pi;
        newOrig = orig.*reverseMask;
        newOrig(logical(nanMask.*reverseMask)) = NaN;
        out = newOrig + newOver;
    else
        out = orig;
        sizeArray = size(mask);
        for i = 1:sizeArray(1)
            for j = 1:sizeArray(2)
                if mask(i, j) == 1
                    ov = over{i, j};
                    if (isa (ov, 'char') && strcmp(ov, '0.0'))
                        ov = '';
                    end
                    out{i+startindices(1)-1, j+startindices(2)-1} = ov;
                end
            end
        end
        sizeOut = size(out);
        for i = 1:sizeOut(1)
            for j = 1:sizeOut(2)
                if isempty(out{i, j})
                    out{i, j} = '';
                end
            end
        end
    end
end

%********************************************************************
function out = removeRowsOrColumns(orig, rowindices, colindices, direction)

% Take care of the easy cases first
if isa(orig, 'char')
    % A char array (guaranteed to be 1xN)
    orig = '';
elseif strcmp(rowindices, ':')
    % Entire columns.  Rip them out.
    orig(:, colindices) = [];
elseif strcmp(colindices, ':')
    % Entire rows.  Rip them out.
    orig(rowindices, :) = [];
else
    % User specified only CERTAIN cells.  More complicated.
    % We'll be removing the selected cells, and moving the
    % "neighbors" up or left, depending on the user's choice.
    empty = 0;
    if isa(orig, 'cell')
        empty = {[]};
    end
    [lastRow lastCol] = size(orig);
    numberOfRows = length(rowindices);
    numberOfCols = length(colindices);
    if strcmp(direction, 'up/down')    
        for destRow = rowindices(1):lastRow
            sourceRow = destRow + numberOfRows;
            for colCounter = 1:numberOfCols
                destCol = colindices(colCounter);
                newValue = empty;
                if (sourceRow <= lastRow)
                    newValue = orig(sourceRow, destCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    elseif strcmp(direction, 'left/right')
        for destCol = colindices(1):lastCol
            sourceCol = destCol + numberOfCols;
            for rowCounter = 1:numberOfRows
                destRow = rowindices(rowCounter);
                newValue = empty;
                if (sourceCol <= lastCol)
                    newValue = orig(destRow, sourceCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    end
end
if numel(orig) == 0 && isnumeric(orig) && sum(size(orig)) > 0
    % Reduces the array to a 0x0 without changing its class.
    orig = repmat(orig, 0, 0);
end
out = orig;

%********************************************************************
function out = insertRowsOrColumns(orig, rowindices, colindices, direction)

empty = 0;
if isa(orig, 'cell')
    empty = {[]};
else if isa(orig, 'struct')
        empty = createEmptyStruct(orig);
    end
end

[height width] = size(orig);

% Take care of the easy cases first
if isa(orig, 'char')
    % A char array (guaranteed to be 1xN)
    orig = '';
elseif strcmp(rowindices, ':')
    % Entire columns.  Shift all higher columns down and fill the selection
    % with 'empty' (whatever's appropriate for the data type).
    if strcmp(colindices, ':')
        colindices = 1:width;
    end
    numToShift = length(colindices);
    for i = (width + numToShift):-1:max([colindices numToShift+1])
        orig(:, i) = orig(:, i-numToShift);
    end
    for i = colindices
        orig(:, i) = empty;
    end
elseif strcmp(colindices, ':')
    % Entire rows.  Shift all higher rows to the left and fill the selection
    % with 'empty' (whatever's appropriate for the data type).
    if strcmp(rowindices, ':')
        rowindices = 1:width;
    end
    numToShift = length(rowindices);
    for i = (height + numToShift):-1:max([rowindices numToShift+1])
        orig(i, :) = orig(i-numToShift, :);
    end
    for i = rowindices
        orig(i, :) = empty;
    end
else
    % User specified only CERTAIN cells.  More complicated.
    % We'll be moving the selected cells and their "neighbors"
    % down or to the right, depending on the user's choice.
    % Fill in the selected cells with 'empty' (whatever's 
    % appropriate for the data type).
    
    % Move things around
    [lastRow lastCol] = size(orig);
    lastRowOfSelection = rowindices(end);
    lastColOfSelection = colindices(end);
    numberOfRows = length(rowindices);
    numberOfCols = length(colindices);
    if strcmp(direction, 'up/down')    
        for sourceRow = lastRow:-1:rowindices(1)
            destRow = sourceRow + numberOfRows;
            for colCounter = 1:numberOfCols
                destCol = colindices(colCounter);
                newValue = empty;
                if (destRow > lastRowOfSelection)
                    newValue = orig(sourceRow, destCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    elseif strcmp(direction, 'left/right')
        for sourceCol = lastCol:-1:colindices(1)
            destCol = sourceCol + numberOfCols;
            for rowCounter = 1:numberOfRows
                destRow = rowindices(rowCounter);
                newValue = empty;
                if (destCol > lastColOfSelection)
                    newValue = orig(destRow, sourceCol);
                end
                orig(destRow, destCol) = newValue;
            end
        end
    end
    
    % Zero out the selection...
    orig(rowindices, colindices) = empty;
    
    % "Patch up" cell arrays to preserve the char array nature of empties.
    if isa(orig, 'cell')
        [l, w] = size(orig);
        for i = 1:l
            for j = 1:w
                if isempty(orig{i, j})
                    orig(i, j) = {[]};
                end
            end
        end
    end
end
out = orig;

%********************************************************************
function in = renameField(in, oldFieldName, newFieldName)
if ~strcmp(oldFieldName, newFieldName)
  allNames = fieldnames(in);
  matchingIndex = find(strcmp(allNames, oldFieldName));
  if ~isempty(matchingIndex)
    allNames{matchingIndex(1)} = newFieldName;
    in.(newFieldName) = in.(oldFieldName);
    in = rmfield(in, oldFieldName);
    in = orderfields(in, allNames);
  end
end

%********************************************************************
function out = createEmptyStruct(in)
fields = fieldnames(in);
args = cell(1, 2*length(fields));
for inc = 1:length(fields)
  args{2*inc-1} = fields{inc};
  args{2*inc} = [];
end
out = struct(args{:});

%********************************************************************
function out = valueHasAppropriateIndexing(name, value)
out = false;
if length(name) < 3
    return;
end
special = getIndicesOfIndexingChars(name);
if length(special) > 0 && special(1) ~= 1
    try
        le = lasterror;
        eval(['local_noop(value' name(special(1):end) ');']);
        out = true;
    catch
        lasterror(le);
    end
end

%********************************************************************
function out = getBaseVariableName(name)
out = '';
if isempty(name)
    return;
end
if isvarname(name)
    out = name;
    return;
end

special = getIndicesOfIndexingChars(name);
if length(special) > 0
    out = name(1:special(1)-1);
end

%********************************************************************
function local_noop(unused)
% Do absolutely nothing.

%********************************************************************
function out = isPossibleIndexedEntityName(in)
out = false;
if length(in) < 3
  return;
end
special = getIndicesOfIndexingChars(in);
if ~isempty(special)
    out = special(1) ~= 1 && special(end) ~= length(in);
end
  
%********************************************************************
function out = getIndicesOfIndexingChars(in)
out = [];
if length(in) < 2
  return;
end
dots = strfind(in, '.');
parens = strfind(in, '(');
curleys = strfind(in, '{');

out = sort([dots parens curleys]);
    
