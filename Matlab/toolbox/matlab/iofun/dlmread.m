function result= dlmread(filename,delimiter,r,c,range)
%DLMREAD Read ASCII delimited file.
%   RESULT = DLMREAD(FILENAME) reads numeric data from the ASCII
%   delimited file FILENAME.  The delimiter is inferred from the formatting
%   of the file.
%
%   RESULT = DLMREAD(FILENAME,DELIMITER) reads numeric data from the ASCII
%   delimited file FILENAME using the delimiter DELIMITER.  The result is
%   returned in RESULT.  Use '\t' to specify a tab.
%
%   When a delimiter is inferred from the formatting of the file,
%   consecutive whitespaces are treated as a single delimiter.  By
%   contrast, if a delimiter is specified by the DELIMITER input, any
%   repeated delimiter character is treated as a separate delimiter.
%
%   RESULT = DLMREAD(FILENAME,DELIMITER,R,C) reads data from the
%   DELIMITER-delimited file FILENAME.  R and C specify the row R and column
%   C where the upper-left corner of the data lies in the file.  R and C are
%   zero-based so that R=0 and C=0 specifies the first value in the file.
%
%   RESULT = DLMREAD(FILENAME,DELIMITER,RANGE) reads the range specified
%   by RANGE = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RANGE
%   can also be specified using spreadsheet notation as in RANGE = 'A1..B7'.
%
%   DLMREAD fills empty delimited fields with zero.  Data files where
%   the lines end with a non-space delimiter will produce a result with
%   an extra last column filled with zeros.
%
%   See also DLMWRITE, TEXTSCAN, TEXTREAD, LOAD, FILEFORMATS.

% Obsolete syntax:
%   RESULT= DLMREAD(FILENAME,DELIMITER,R,C,RANGE) reads only the range specified
%   by RANGE = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RANGE
%   can also be specified using spreadsheet notation as in RANGE = 'A1..B7'.
%   A warning will be generated if R,C or both don't match the upper
%   left corner of the RANGE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.40.4.6 $  $Date: 2004/03/26 13:26:22 $

% Validate input args
if nargin==0
    error('MATLAB:dlmread:Nargin','Not enough input arguments.'); 
end

% Get Filename
if ~ischar(filename)
    error('MATLAB:dlmread:InvalidInputType','Filename must be a string.'); 
end

% Get Delimiter
if nargin==1 % Guess default delimiter
    [fid message] = fopen(filename);
	if fid < 0
		error('MATLAB:dlmread:FileNotOpened',...
			'The file ''%s'' could not be opened because: %s',filename,message);
	end
	str = fread(fid, 4096,'*char')';
    fclose(fid);
    delimiter = guessdelim(str);
    if isspace(delimiter);
        delimiter = '';
    end 
else
    delimiter = sprintf(delimiter); % Interpret \t (if necessary)
end
if length(delimiter) > 1,
    error('MATLAB:dlmread:InvalidDelimiter',...
          'DELIMITER must be a single character.');
end

% Get row and column offsets
offset = 0;
if nargin<=2, % dlmread(file) or dlmread(file,dim)
    r = 0;
    c = 0;
    nrows = -1; % Read all rows
    range = [];
elseif nargin==3, % dlmread(file,delimiter,range)
    if length(r)==1, % Catch obsolete syntax dlmread(file,delimiter,r)
        warning('MATLAB:dlmread:ObsoleteSyntax',...
        'Obsolete syntax. C must be specified with R.');
        result= dlmread(filename,delimiter,r,0);
        return
    end
    range = r;
    if ischar(range)
        range = str2rng(range);
    end
    r = range(1);
    c = range(2);
    nrows = range(3) - range(1) + 1;
elseif nargin==4, % dlmread(file,delimiter,r,c)
    nrows = -1; % Read all rows
    range = [];
elseif nargin==5, % obsolete syntax dlmread(file,delimiter,r,c,range)
    if ischar(range)
        range = str2rng(range);
    end
    rold = r; cold = c;
    if r > range(3) | c > range(4), result= []; return, end
    if r ~= range(1) | c ~= range(2)
        warning('MATLAB:dlmread:InvalidRowsAndColumns',...
        ['R and C should match RANGE(1:2).  Use DLMREAD(FILE,DELIMITER,RANGE)' ...
         ' instead.'])
        offset = 1;
    end
    % For compatibility
    r = max(range(1),r);
    c = max(range(2),c);
    nrows = range(3) - r + 1;
end

% attempt to open data file
[fid message] = fopen(filename);
if fid < 0
	error('MATLAB:dlmread:FileNotOpened',...
		'The file ''%s'' could not be opened because: %s',filename,message);
end

% Read the file using textscan
if isempty(delimiter)
    cresult  = textscan(fid,'',nrows,'headerlines',r,'headercolumns',c,...
                       'returnonerror',0,'emptyvalue',0);
else
    delimiter = sprintf(delimiter);
    whitespace  = setdiff(sprintf(' \b\t'),delimiter);
    cresult  = textscan(fid,'',nrows,...
                   'delimiter',delimiter,'whitespace',whitespace, ...
                   'headerlines',r,'headercolumns',c,...
                   'returnonerror',0,'emptyvalue',0);
end


% delimiter = sprintf(delimiter);
% whitespace  = setdiff(sprintf(' \b\t'),delimiter);
% cresult  = textscan(fid,'',nrows,...
%                'delimiter',delimiter,'whitespace',whitespace, ...
%                'headerlines',r,'headercolumns',c,...
%                'returnonerror',0,'emptyvalue',0);
% 
% close data file
fclose(fid);

% since only numbers were imported, combine cells into numeric array
result = cell2array(cresult,0);

% textread only trims leading columns, trailing columns may need clipping
if ~isempty(range)
    ncols = range(4) - range(2) + 1;

    % adjust ncols if necessary
    if ncols ~= size(result,2)
        result= result(:,1:ncols);
    end
end

% num rows should be correct, textread clips
if nrows > 0 & nrows ~= size(result,1)
    error('Internal size mismatch')
end


% When passed in 5 args, we have an offset and a range.  If the offset is
% not equal to the top left corner of the range the user wanted to read
% range Ai..Bj and start looking in that matrix at rold and cold.  For
% backwards compatibility we create a result the same size as the specified
% range and place the data in the result at the requested offset.

% For example, given a file with [1 2 3; 4 5 6], reading A1..C2 with offset
% 1,2 produces this result:
% 0 0 0
% 0 5 6

if nargin==5 & offset
    rowIndex = rold+1:rold+nrows;
    columnIndex = cold+1:cold+ncols;
    if rold == 0
        rowIndex = rowIndex + 1;
    end
    if cold == 0
        columnIndex = columnIndex + 1;
    end

    % assign into a new matrix of the desired size
    % need to create temp matrix here cuz we want the
    % offset region filled with zeros
    new_result(rowIndex,columnIndex) = result;
    result = new_result;
end
%==============================================================================
function narray = cell2array(carray,missingdata)
% convert cell vector of numeric column vectors to numeric array
% padds incomplete columns with missing data value

% find number of rows of returned cells
nrows = cellfun('size',carray,1);

% find incomplete columns (with less rows than max rows);
rowpadding = max(nrows) - nrows; % shortfall in rows for each column
incomplete = find(rowpadding > 0);

% pad incomplete 
if ~isempty(incomplete)
    carray{incomplete} = [carray{incomplete};...
                          ones(rowpadding(incomplete),1)*missingdata];
end
% convert cell array to numeric array
narray = [carray{:}];

