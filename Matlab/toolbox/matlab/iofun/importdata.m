function [out, delimiter, headerlines] = importdata(varargin)
%IMPORTDATA Load data from a file into MATLAB.
%
% IMPORTDATA(FILENAME) loads data from FILENAME into the workspace.
% A = IMPORTDATA(FILENAME) loads data from FILENAME into A.
%
% IMPORTDATA(FILENAME, D) loads data from FILENAME using D as the column
% separator (if text).  Use '\t' for tab.
%
% IMPORTDATA looks at the file extension to determine which helper function
% to use.  If the extension is mentioned in FILEFORMATS, IMPORTDATA will
% call the appropriate helper function with the maximum number of output
% arguments.  If the extension is not mentioned in FILEFORMATS, IMPORTDATA
% calls FINFO to determine which helper function to use.  If no helper
% function is defined for this extension, IMPORTDATA treats the file as
% delimited text.  Empty outputs from the helper function are removed from
% the result.
%
% NOTE: When the file to be imported is an ASCII text file and IMPORTDATA has
%     trouble importing the file, try TEXTSCAN with a more elaborate argument
%     set than the rather simple application of TEXTSCAN in IMPORTDATA.
% NOTE: When reading of a rather old Excel format fails, try updating the
%     the Excel file to Excel 2000 or 95 format by opening and saving
%     with Excel 2000 or Excel 95.
%
% Examples:
%
%    s = importdata('ding.wav')
% s =
%
%    data: [11554x1 double]
%      fs: 22050
%
%   s = importdata('flowers.tif');
%   size(s)
% ans =
%
%    362   500     3
%
% See also LOAD, FILEFORMATS, TEXTSCAN, OPEN, LOAD, UIIMPORT.

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.17.4.5 $  $Date: 2004/03/26 13:26:28 $

error(nargchk(1,3,nargin));
error(nargoutchk(0,3,nargout));

FileName = varargin{1};

if nargin > 1
    requestedDelimiter = varargin{2};
else
    requestedDelimiter = NaN;
end

if nargin > 2
    requestedHeaderLines = varargin{3};
else
    requestedHeaderLines = NaN;
end

out = [];

if nargout > 1
    delimiter = [];
end

if nargout > 2
    headerlines = 0;
end

fromClipboard = false;

if strcmpi(FileName,'-pastespecial')
    % fetch data from clipboard
    cb = clipboard('paste');
    if isnan(requestedDelimiter)
        delimiter = guessdelim(cb);
    else
        delimiter = sprintf(requestedDelimiter);
    end
    [out.data, out.textdata, headerlines] = stringparse(cb, delimiter, requestedHeaderLines);
    out = LocalRowColShuffle(out);

    FileType = '';
    fromClipboard = true;
else
    % fetch data from file
    if exist(FileName) ~= 2
        error('Unable to open file.')
    end

    % attempt extracting descriptive information about file
    [FileType,openCmd,loadCmd,descr] = finfo(FileName);

    % Test success of FINFO call
    if strcmp(descr,'FileInterpretError')

        % Generate a warning that FINFO could not interpret data file
        Message = 'File contains uninterpretable data.';
        warning('MATLAB:IMPORTDATA:InvalidDataSection',Message)
        out.data=[]; % return an empty matrix object
        out.textdata={}; % return an empty cell object
        return
    end

    delimiter = NaN;
    %Just in case we found incorrect command, i.e. the name was a
    %coincidence, we'll try to load, but if we fail, we'll try to load
    %using other means.
    loaded = 0;
    if ~isempty(loadCmd) && ~strcmp(loadCmd,'importdata')
        try
            out.data = feval(loadCmd, FileName);
            loaded = 1;
        catch
            err = lasterror;
            err.message = [err.message sprintf('\t Using %s command', loadCmd)];
        end
    end
    if (loaded == 0)
        switch FileType
            case 'xls'
                % special case for single sheet
                if length(descr) == 1
                    [n,s] = xlsread(FileName,descr{1});
                    if ~isempty(n)
                        out.data = n;
                    end
                    if ~isempty(s)
                        out.textdata = s;
                    end
                    out = LocalRowColShuffle(out);
                else
                    % top level fields so assignments below work right
                    for i = 1:length(descr)
                        [n,s] = xlsread(FileName,descr{i});
                        if ~isempty(n)
                            if ~isfield(out,'data')
                                out.data = struct();
                            end
                            %Generate variable names.  Since generating one
                            %name, might conflict with another, we need to
                            %do this for all names.
                            name = genvarname(descr{i},fieldnames(out.data));
                            try
                                out.data.(name) = n;
                            catch
                                error('Sheet name cannot be mapped to a valid MATLAB variable name.')
                            end
                        end
                        if ~isempty(s)
                            if ~isfield(out,'textdata')
                                out.textdata = struct();
                            end                            
                            name = genvarname(descr{i},fieldnames(out.textdata));
                            try
                                out.textdata.(name) = s;
                            catch
                                error('Sheet name cannot be mapped to a valid MATLAB variable name.')
                            end
                        end
                        
                        if ~isempty(s) && ~isempty(n)
                            [dm, dn] = size(n);
                            [tm, tn] = size(s);
                            if tn == 1 && tm == dm
                                if ~isfield(out,'rowheaders')
                                    out.rowheaders = struct();
                                end
                                name = genvarname(descr{i},fieldnames(out.rowheaders));
                                % use as row headers
                                out.rowheaders.(name) = s(:,end);
                            elseif tn == dn
                                if ~isfield(out,'colheaders')
                                    out.colheaders = struct();
                                end                                
                                % use last row as col headers
                                name = genvarname(descr{i},fieldnames(out.colheaders));
                                out.colheaders.(name) = s(end,:);
                            end
                        end
                    end
                end

            case 'wk1'
                [out.data, out.textdata] = wk1read(FileName);
                out = LocalRowColShuffle(out);
            case 'avi'
                out = aviread(FileName);
            case 'im'
                [out.cdata, out.colormap] = imread(FileName);
            case {'au','snd'}
                [out.data, out.fs] = auread(FileName);
            case 'wav'
                [out.data, out.fs] = wavread(FileName);
            case 'mat'
                wasError = false;
                try
                    if ~isempty(whos('-file',FileName))
                        % call load with -mat option
                        out = load('-mat',FileName);
                    else
                        wasError = true;
                    end
                catch
                    wasError = true;
                end
                if wasError
                    % call load with -ascii option
                    out = load('-ascii',FileName);
                end
                if isempty(out)
                    error('Unable to load file.  Not a MAT file.');
                end
            otherwise
                % try to treat as hidden mat file
                try
                    out = load('-mat',FileName);
                catch
                    out = [];
                end
                if isempty(out)
                    % file is an unknown format, treat it as text
                    [out, delimiter, headerlines] = LocalTextRead(FileName, requestedDelimiter, requestedHeaderLines);
                end
        end
    end
end

if (length(out) == 1 && isstruct(out))
    % remove empty fields from output struct
    names = fieldnames(out);
    for i = 1:length(names)
        if isempty(out.(names{i}))
            out = rmfield(out, names{i});
        end
    end
    if ~isempty(out)
        % flatten output struct if single variable
        names = fieldnames(out);
        if length(names) == 1
            out = out.(names{1});
        end
    end
end

if isempty(out) || (isstruct(out) && isempty(fieldnames(out)))
    if fromClipboard
        error('Clipboard does not contain any recognizable data.');
    else
        err = lasterror;
        if ~isempty(err)
            err.message = [err.message  sprintf('\nUnable to load file.\nUse TEXTSCAN or FREAD for more complex formats.')];
            rethrow(err);
        else
            error('MATLAB:importdata:UnableToLoad', sprintf('Unable to load file.\nUse TEXTSCAN or FREAD for more complex formats.'));
        end
    end
end


function [out, delimiter, headerlines] = LocalTextRead(filename, requestedDelimiter, hlines)

str = '';

% get the delimiter for the file
if isnan(requestedDelimiter)
    fid = fopen(filename);
    str = fread(fid, 4096,'*char')';
    fclose(fid);
    delimiter = guessdelim(str);
else
    delimiter = sprintf(requestedDelimiter);
end

% try load first (it works with tabs, spaces, and commas)
out = [];
if isnan(hlines) && ~isempty(findstr(delimiter, sprintf('\t ,')))
    try
        % load -ascii works well with all numeric data but fails
        % with text data. So we first look at the start of the file
        % to see if there is text.
        if isempty(str)
            fid = fopen(filename);
            str = fread(fid, 80,'*char')';
            fclose(fid);
        end
        if isempty(regexpi(str,'[a-cg-hk-z/]','once'))
            out = load('-ascii', filename);
            headerlines = 0;
        end
    catch
        out = '';
    end
end
if isempty(out)
    try
        [out.data, out.textdata, headerlines] = fileparse(filename, delimiter, hlines);
        out = LocalRowColShuffle(out);
    catch
        out = [];
        headerlines = 0;
    end
end

function out = LocalRowColShuffle(in)

out = in;

if isempty(in) | ~isfield(in, 'data') | ~isfield(in,'textdata') | isempty(in.data) | isempty(in.textdata)
    return;
end

[dm, dn] = size(in.data);
[tm, tn] = size(in.textdata);

if tn == 1 && tm == dm
    % use as row headers
    out.rowheaders = in.textdata(:,end);
elseif tn == dn
    % use last row as col headers
    out.colheaders = in.textdata(end,:);
end


function [numericData, textData, numHeaderRows] = fileparse(filename, delimiter, headerLines)
%This is a copy of stringparse, changed to use textscan and a filename to
%read in the data.  The old copy of stringparse still exists, and parses a
%string using strread.  Once textscan is capable of parsing strings,
%fileparse should be used to parse strings as well.

error(nargchk(1,3,nargin));

numericData = [];
textData = {};
numHeaderRows = 0;
string = fileread(filename);

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
    analyze(filename, string, delimiter, headerLines);

% fetch header lines and look for a line of column headers
headerLine = {};
headerData = {};
origHeaderData = headerData;
useAsCells = 1;

firstLineOffset = 0;
if numHeaderRows
    firstLineOffset = numHeaderRows - 1;
    if firstLineOffset > 0
        fid = fopen(filename);
        try
            headerData = textscan(fid,'%[^\n]',firstLineOffset,'whitespace','','delimiter','\n');
        catch
        end
        fclose(fid);
        origHeaderData = headerData{1};
        if numDataCols
            headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
        else
            headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols)];
        end
    else
       headerData = [cell(0, numHeaderCols + numDataCols)];
    end
    
    fid = fopen(filename);
    try
        Data = textscan(fid,'%[^\n]',1,'headerlines',firstLineOffset,'delimiter',delimiter);
    catch
    end
    fclose(fid);
    headerLine = Data{1};
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

fid = fopen(filename);
% now try for the whole shootin' match
try
    if numDataCols
		 %When the delimiter is a space, multiple spaces do NOT mean
		 %multiple delimiters.  Thus, call textsscan such that it will
		 %treat them as one.
		if isequal(delimiter,' ')
	        Data = textscan(fid,formatString,'headerlines',numHeaderRows);
		else
	        Data = textscan(fid,formatString,'delimiter',delimiter,'headerlines',numHeaderRows);
		end
		if numHeaderCols
	        textCellData = Data(1:numHeaderCols);
		    numericCellData = Data(numHeaderCols+1:numHeaderCols+numDataCols);
		else
	        numericCellData = Data(1:numDataCols);
		end
    end
    wasError = false;
catch
    wasError = true;
end
fclose(fid);

% setup some default answers if we're not able to do the full read below
try
	if numHeaderCols
		numRows = length(textCellData{1});
	else
		numRows = 0;
	end

	if nargout > 1
		textData = cell(numRows,numDataCols+numHeaderCols);
		for i = 1:numHeaderCols
			numCellRows = length(textCellData{i});			
			textData(1:numCellRows,i) = textCellData{i}; 
			if (numCellRows < numRows)
				[textData{numCellRows+1:end,i}] = deal('');
				wasError = true;
			end
		end
	end

	if numDataCols && ~numRows && ~isempty(numericCellData{1})
		numRows = length(numericCellData{1});
	end

	numericData = NaN(numRows,numDataCols);

	for i = 1:numDataCols
		numCellRows = length(numericCellData{i});
		numericData(1:numCellRows,i) = numericCellData{i}; 
		if (numCellRows ~= numRows)
			wasError = true;
		end
	end

	if nargout > 1
		if ~isempty(headerLine)
			textData = [headerLine; textData];
		end

		if ~isempty(headerData)
			textData = [headerData; textData];
		end    
	end
catch
	%There was an unanticipated mismatch, implying a failure to read the file properly.
	%We will thus try again, with a 'fixed' column header format.
	wasError = true;
end

% if the first pass failed to read the whole shootin' match, try again using the character offset
if wasError && numHeaderChars
    % rebuild format string
    fid = fopen(filename);

    formatString = ['%' num2str(numHeaderChars) 'c' repmat('%n', 1, numDataCols)];
    textCharData = '';
    try
		%When the delimiter is a space, multiple spaces do NOT mean
		%multiple delimiters.  Thus, call textsscan such that it will
		%treat them as one.
		if isequal(delimiter,' ')
		    Data = textscan(fid,formatString,'headerlines',numHeaderRows,'returnonerror',1);
		else
	        Data = textscan(fid,formatString,'delimiter',delimiter,'headerlines',numHeaderRows,'returnonerror',1);
		end
		textCharData = Data{1};
        numericCellData = Data(2:end);
        numHeaderCols = 1;
        if ~isempty(numericCellData)
            numRows = length(numericCellData{1});
        else
            numRows = length(textCharData);
        end
    catch
    end    
    fclose(fid);
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
    wasError = false;
    for i = 1:numDataCols
		numCellRows = length(numericCellData{i});
		numericData(1:numCellRows,i) = numericCellData{i}; 
		if (numCellRows ~= numRows)
			wasError = true;
		end
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

if wasError
	warning('MATLAB:importdata:FormatMismatch', ...
		'An unexpected format mismatch was detected.\nPlease check results against original file.');
end

if nargout > 1 && ~isempty(textData)
	
    % trim trailing empty cols from textData
    i = size(textData,2);
    while i >= 1
        if ~all(cellfun('isempty',textData(:,i)))
            break;
        end
        i = i - 1;
    end
    if i < size(textData,2)
        textData = textData(:,1:i);
    end	
	
	% trim trailing empty rows from textData	
	i = size(textData,1);
	while i >= 1
		if ~all(cellfun('isempty',textData(i,:)))
			break;
		end
		i = i - 1;
	end
	if i < size(textData,1)
		textData = textData(1:i,:);
	end
end

function [numColumns, numHeaderRows, numHeaderCols, numHeaderChars] = analyze(filename, string, delimiter, header)
%ANALYZE count columns, header rows and header columns

numColumns = 0;
numHeaderRows = 0;
numHeaderCols = 0;
numHeaderChars = 0;

if ~isnan(header)
    numHeaderRows = header;
end
fid=fopen(filename);
try
    Data = textscan(fid,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
catch
end
fclose(fid);
thisLine = Data{1};
if isempty(thisLine)
    return;
end
thisLine = thisLine{:};

[isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);

if ~isvalid
    numHeaderRows = numHeaderRows + 1;
    fid=fopen(filename);
    try
        Data = textscan(fid,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
    catch
    end
    thisLine = Data{1};
    fclose(fid);
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
		delimiterIndexes = delimiterIndexes(delimiterIndexes > 1);
    end
    
    % format string should have 1 more specifier than there are delimiters
    numColumns = length(delimiterIndexes) + 1;
    if numHeaderCols > 0
        % add one to numColumns because the two set of columns share a delimiter
        numColumns = numColumns - numHeaderCols;
    end
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
        [cellstring indices] = split(string, delimiter);   
        flags = isdata(cellstring);
        % num leading zeros in flags is num header cols
        numHeaderCols = max(find(flags == 0));
        if isempty(numHeaderCols)
            numHeaderCols = 0;
		end
		% use contents of 1st data data cell to find num leading chars
		if numHeaderCols > 0
			numHeaderChars = indices(numHeaderCols);
		end
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

function [cellOut indOut] = split(string, delimiter)
%SPLIT rip string apart using strtok
cellOut = strread(string,'%s','delimiter',delimiter)';
if delimiter == ' '
	indOut = regexp(strtrim(string),' [^ ]') ; 
else
	indOut = regexp(string,delimiter) ;
end
