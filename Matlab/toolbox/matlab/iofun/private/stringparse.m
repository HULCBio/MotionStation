function [numericData, textData, numHeaderRows] = stringparse(string, delimiter, headerLines)
%STRINGPARSE Helper function for importdata.
%
% See also: LOAD, FILEFORMATS

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.10.4.4 $  $Date: 2004/04/10 23:29:41 $ 

error(nargchk(1,3,nargin));

numericData = [];
textData = {};
numHeaderRows = 0;

% gracefully handle empty
if isempty(string) && isempty(regexp(string,'\S','once')); 
    %regexp is faster than all(isspace(string));
        return;
end

% validate delimiter 
if nargin == 1
    delimiter = guessdelim(string);
else
    % handle \t
    delimiter = sprintf(delimiter);
    if length(delimiter) > 1
        error('Multi character delimiters not supported.')
    end
end

if nargin < 3
    headerLines = NaN;
end

% use what user asked for header lines if specified
[numDataCols, numHeaderRows, numHeaderCols, numHeaderChars] = ...
    analyze(string, delimiter, headerLines);

% fetch header lines and look for a line of column headers
headerLine = {};
headerData = {};
origHeaderData = headerData;
useAsCells = 1;

firstLineOffset = 0;
if numHeaderRows
    firstLineOffset = numHeaderRows - 1;
    
    headerData = strread(string,'%[^\n]',firstLineOffset,'delimiter',delimiter);
    origHeaderData = headerData;
    
    if numDataCols
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
    else
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols)];
    end
    
    headerLine = strread(string,'%[^\n]',1,'headerlines',firstLineOffset,'delimiter',delimiter);
    origHeaderLine = headerLine;
    
    useAsCells = 0;
    
    if ~isempty(delimiter) && ~isempty(headerLine) && ~isempty(strfind(deblank(headerLine{:}), delimiter))
        cellLine = split(headerLine{:}, delimiter);
        if length(cellLine) == numHeaderCols + numDataCols
            headerLine = cellLine;
            useAsCells = 1;
        end
    end
    
    if ~useAsCells
        if numDataCols
            headerLine = [origHeaderLine, cell(1, numHeaderCols + numDataCols - 1)];
        else
            headerLine = [origHeaderLine, cell(1, numHeaderCols)];
        end
    end
end

if isempty(delimiter)
    formatString = [repmat('%s', 1, numHeaderCols) repmat('%n', 1, numDataCols)];
else
    formatString = [repmat(['%[^' delimiter ']'], 1, numHeaderCols) repmat('%n', 1, numDataCols)];
end

textCellData = {};
numericCellData = cell(numDataCols,1);

% call strread with format string
% (if we got here, there must be at least one good chunk on the 1st line in the file)
if numHeaderCols && numDataCols
    [textCellData{1:numHeaderCols}, numericCellData{1:numDataCols}] = ...
        strread(string,formatString,1,'delimiter',delimiter,'headerlines',numHeaderRows);
elseif numDataCols
    [numericCellData{1:numDataCols}] = ...
        strread(string,formatString,1,'delimiter',delimiter,'headerlines',numHeaderRows);
end

% now try again for the whole shootin' match
try
    if numHeaderCols && numDataCols
        [textCellData{1:numHeaderCols}, numericCellData{1:numDataCols}] = ...
            strread(string,formatString,'delimiter',delimiter,'headerlines',numHeaderRows);
    elseif numDataCols
        [numericCellData{1:numDataCols}] = ...
            strread(string,formatString,'delimiter',delimiter,'headerlines',numHeaderRows);
    end
    wasError = 0;
catch
    wasError = 1;
end

% setup some default answers if we're not able to do the full read below
if numHeaderCols
    numRows = length(textCellData{1});
else
    numRows = 0;
end

if numDataCols && ~numRows && ~isempty(numericCellData{1})
    numRows = length(numericCellData{1});
end

if nargout > 1
    textData = cell(numRows,numDataCols+numHeaderCols);
    for i = 1:numHeaderCols
        textData(:,i) = textCellData{i};
    end
end

numericData = zeros(numRows,numDataCols);

for i = 1:numDataCols
    numericData(:,i) = numericCellData{i};
end

if nargout > 1
    if ~isempty(headerLine)
        textData = [headerLine; textData];
    end
    
    if ~isempty(headerData)
        textData = [headerData; textData];
    end    
end

% if the first pass failed to read the whole shootin' match, try again using the character offset
if wasError && numHeaderChars
    % rebuild format string
    formatString = ['%' num2str(numHeaderChars) 'c' repmat('%n', 1, numDataCols)];
    textCharData = '';
    try
        [textCharData, numericCellData{1:numDataCols}] = ...
            strread(string,formatString,'delimiter',delimiter,'headerlines',numHeaderRows,'returnonerror',1);
        numHeaderCols = 1;
        if ~isempty(numericCellData)
            numRows = length(numericCellData{1});
        else
            numRows = length(textCharData);
        end
    end        
    
    numericData = [];
    
    if numDataCols
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
    else
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols)];
    end
    
    if ~useAsCells
        if numDataCols
            headerLine = [origHeaderLine, cell(1, numHeaderCols + numDataCols - 1)];
        else
            headerLine = [origHeaderLine, cell(1, numHeaderCols)];
        end
    end
    
    for i = 1:numDataCols
        numericData(:,i) = numericCellData{i};
    end
    
    if nargout > 1 && ~isempty(textCharData)
        textCellData = cellstr(textCharData);
        if ~isempty(headerLine)
            textData = [headerLine;
                textCellData(1:numRows), cell(numRows, numHeaderCols + numDataCols - 1)];
        else
            textData = [textCellData(1:numRows), cell(numRows, numHeaderCols + numDataCols - 1)];
        end
        
        if ~isempty(headerData)
            textData = [headerData; textData];
        end
    end
end

if nargout > 1 && ~isempty(textData)
    % trim trailing empty rows from textData
    i = 1;
    while i <= size(textData,1)
        if all(cellfun('isempty',textData(i,:)))
            break;
        end
        i = i + 1;
    end
    if i <= size(textData,1)
        textData = textData(1:i-1,:);
    end
    
    % trim trailing empty cols from textData
    i = 1;
    while i <= size(textData,2)
        if all(cellfun('isempty',textData(:,i)))
            break;
        end
        i = i + 1;
    end
    if i <= size(textData,2)
        textData = textData(:,1:i-1);
    end
end



function [numColumns, numHeaderRows, numHeaderCols, numHeaderChars] = analyze(string, delimiter, header)
%ANALYZE count columns, header rows and header columns

numColumns = 0;
numHeaderRows = 0;
numHeaderCols = 0;
numHeaderChars = 0;

if ~isnan(header)
    numHeaderRows = header;
end

thisLine = strread(string,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
if isempty(thisLine)
    return;
end
thisLine = thisLine{:};

[isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);

if ~isvalid
    numHeaderRows = numHeaderRows + 1;
    thisLine = strread(string,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
    if isempty(thisLine)
        return;
    end
    
    % g142663: remove trailing blanks that could imply a false column.
    thisLine = deblank(thisLine);
    
    thisLine = thisLine{1};
    
    [isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);
    if ~isvalid
        newLines = strfind(string,sprintf('\n'));
        
        if isempty(newLines)% must be a MAC
            newLines = strfind(string,char(13));
            if isempty(newLines) % do not know what to do with this...
                return
            end
        end
        % deal with the case where the file is not terminated with a \n
        if newLines(end) ~= length(string)
            newLines(end + 1) = length(string);
        end
        numLines = length(newLines);
        newLines(end+1) = length(string) + 1;
        
        while ~isvalid 
            if(numHeaderRows == numLines)
                break;
            end
            
            % stop now if the user specified a number of header lines
            
            if ~isnan(header) && numHeaderRows == header
                break;
            end
            numHeaderRows = numHeaderRows + 1;
            
            thisLine = string((newLines(numHeaderRows)+1):(newLines(numHeaderRows+1)-1));
            if isempty(thisLine)
                break;
            end
            [isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);
        end
    end
end

% This check could happen earlier
if ~isnan(header) && numHeaderRows >= header
    numHeaderRows = header;
end

if isvalid
    % determine num columns
    delimiterIndexes = strfind(thisLine, delimiter);
    if all(delimiter ==' ') && length(delimiterIndexes) > 1
        delimiterIndexes = delimiterIndexes([logical(1) diff(delimiterIndexes) ~= 1]);
    end
    
    % format string should have 1 more specifier than there are delimiters
    numColumns = length(delimiterIndexes) + 1;
    if numHeaderCols > 0
        % add one to numColumns because the two set of columns share a delimiter
        numColumns = numColumns - numHeaderCols;
    end
    
    newLine = strread(string,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
    thisLine = newLine{:};
end


function [status, numHeaderCols, numHeaderChars] = isvaliddata(string, delimiter)
% ISVALIDDATA delimiters and all numbers or e or + or . or -
% what about single columns???

numHeaderCols  = 0;
numHeaderChars = 0;

if isempty(delimiter)
    % with no delimiter, the line must be all numbers, +, . or -
    status = isdata(string);
    return
end
delims = strfind(string, delimiter);
if isempty(delims)
    % a delimiter must occur on each line of data (or there is no delimiter...)
    status = 0;
    return
end

% if there is data at the end of the line, it's legit

checkstring = string(delims(end)+1:end);
[dummya,dummyb,c] = sscanf(checkstring, '%g');
flag = isempty(c); 

status = 0;
if flag
    try
        cellstring = split(string, delimiter);   
        flags = isdata(cellstring);
        % num leading zeros in flags is num header cols
        numHeaderCols = max(find(flags == 0));
        if isempty(numHeaderCols)
            numHeaderCols = 0;
        end
        
        % use contents of 1st data data cell to find num leading chars
        numHeaderChars = strfind(string, cellstring{numHeaderCols + 1}) - 1;
        status = 1;
    catch
        numHeaderCols = 0;
        numHeaderChars = 0;
        return
    end
end

function status = isdata(cellstring)
%ISDATA true if string can be shoved into a number

if ~isa(cellstring,'cell')
    cellstring = cellstr(cellstring);
end

status = logical([]);
len = length(cellstring);
if len > 1
    for i = 1:len - 1
        [a,b,c] = sscanf(cellstring{i}, '%g');
        status(i) = isempty(c);
    end
end
% ignore empty last field
if len > 0 && ~isempty(cellstring{end})
    [a,b,c] = sscanf(cellstring{end}, '%g');
    status(len) = isempty(c);
end

function cellOut = split(string, delimiter)
%SPLIT rip string apart using strtok
cellOut = strread(string,'%s','delimiter',delimiter)';
