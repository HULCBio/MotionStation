function [success,message]=xlswrite(file,data,sheet,range)
% XLSWRITE Stores numeric array or cell array in Excel workbook.
%   [SUCCESS,MESSAGE]=XLSWRITE(FILE,ARRAY,SHEET,RANGE) writes ARRAY to the Excel
%   workbook, FILE, into the area, RANGE in the worksheet specified in SHEET.
%   FILE and ARRAY must be specified. If either FILE or ARRAY is empty, a
%   error is thrown and XLSWRITE terminates. The first worksheet of the
%   workbook is the default. If SHEET does not exist, a new sheet is added at
%   the end of the worksheet collection. If SHEET is an index larger than the
%   number of worksheets, new sheets are appended until the number of worksheets
%   in the workbook equals SHEET. The size defined  by the  RANGE should fit the
%   size of ARRAY or contain only the first cell, e.g. 'A2'. If RANGE is larger
%   than the size of ARRAY, Excel will fill the remainder of the region with
%   #N/A. If RANGE is smaller than the size of ARRAY, only the sub-array that
%   fits into RANGE will be written to FILE. The success of the operation is
%   returned in SUCCESS and any accompanying message, in MESSAGE. On error,
%   MESSAGE shall be a struct, containing the error message and message ID.
%   See NOTE 1.
%
%   [SUCCESS,MESSAGE]=XLSWRITE(FILE,ARRAY) writes ARRAY to the Excel workbook,
%   FILE, starting at cell A1 of the first worksheet. The return values are as
%   for the above example.
%
%   XLSWRITE ARRAY FILE, is the command line version of the above example.
%
%   INPUT PARAMETERS:
%       file:   string defining the workbook file to write to.
%               Default directory is pwd; default extension 'xls'.
%       array:  m x n numeric array or cell array.
%       sheet:  string defining worksheet name;
%               double, defining worksheet index.
%       range:  string defining data region in worksheet, using the Excel
%               'A1' notation.
%
%   RETURN PARAMETERS:
%       SUCCESS: logical scalar.
%       MESSAGE: struct containing message field and message_id field.
%
%   EXAMPLES:
%
%   SUCCESS = XLSWRITE('c:\matlab\work\myworkbook.xls',A,'A2:C4') will write A to
%   the workbook file, myworkbook.xls, and attempt to fit the elements of A into
%   the rectangular worksheet region, A2:C4. On success, SUCCESS will contain true,
%   while on failure, SUCCESS will contain false.
%
%   NOTE 1: The above functionality depends upon Excel as a COM server. In
%   absence of Excel, ARRAY shall be written as a text file in CSV format. In
%   this mode, the SHEET and RANGE arguments shall be ignored.
%
% See also XLSREAD, WK1WRITE, CSVWRITE.
%

%   JP Barnard
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/03/26 13:26:38 $
%==============================================================================
% Set default values.
Sheet1 = 1;

if nargin < 3
    sheet = Sheet1;
    range = '';
elseif nargin < 4
    range = '';
end

if nargout > 0
    success = true;
    message = struct('message',{''},'identifier',{''});
end

% Handle input.
try
    % handle requested Excel workbook filename.
    if ~isempty(file)
        if ~ischar(file)
            error('MATLAB:xlswrite:InputClass','Filename must be a string');
        end
        % check for wildcards in filename
        if any(findstr('*', file))
            error('MATLAB:xlswrite:FileName', 'Filename must not contain *');
        end
        [Directory,file,ext]=fileparts(file);
        if isempty(ext) % add default Excel extension;
            ext = '.xls';
        end
        file = abspath(fullfile(Directory,[file ext]));
        [a1 a2 a3] = fileattrib(file);
        if a1 && ~(a2.UserWrite == 1)
            error('MATLAB:xlswrite:FileReadOnly', 'File can not be read only.');
        end
    else % get workbook filename.
        error('MATLAB:xlswrite:EmptyFileName','Filename is empty.');
    end

    % Check for empty input data
    if isempty(data)
        error('MATLAB:xlswrite:EmptyInput','Input array is empty.');
    end

    % Check for N-D array input data
    if ndims(data)>2
        error('MATLAB:xlswrite:InputDimension',...
            'Dimension of input array cannot be higher than two.');
    end

    % Check class of input data
    if ~(iscell(data) || isnumeric(data) || ischar(data)) && ~islogical(data)
        error('MATLAB:xlswrite:InputClass',...
            'Input data must be a numeric, cell, or logical array.');
    end


    % convert input to cell array of data.
    if iscell(data)
        A=data;
    else
        A=num2cell(data);
    end

    if nargin > 2
        % Verify class of sheet parameter.
        if ~(ischar(sheet) || (isnumeric(sheet) && sheet > 0))
            error('MATLAB:xlswrite:InputClass',...
                'Sheet argument must a string or a whole number greater than 0.');
        end
        if isempty(sheet)
            sheet = Sheet1;
        end
        % parse REGION into sheet and range.
        % Parse sheet and range strings.
        if ischar(sheet) && ~isempty(strfind(sheet,':'))
            range = sheet; % only range was specified.
            sheet = Sheet1;% Use default sheet.
        elseif ~ischar(range)
            error('MATLAB:xlswrite:InputClass',...
                'Range argument must a string of Excel A1 notation.');
        end
    end

catch
    if ~isempty(nargchk(2,4,nargin))
        error('MATLAB:xlswrite:InputArguments',nargchk(2,4,nargin));
    elseif nargout == 0
        rethrow(lasterror);  	   % Display last error.
    else
        success = false;
        message = lasterror;       % Return last error.
    end
    return;
end
%------------------------------------------------------------------------------
% Attempt to start Excel as ActiveX server.
try
    Excel = actxserver('Excel.Application');

catch
    warning('MATLAB:xlswrite:NoCOMServer',...
        ['Could not start Excel server for export.\n' ...
        'XLSWRITE attempts to file in CSV format.']);
    if nargout > 0
        [message.message,message.identifier] = lastwarn;
    end
    % write data as CSV file, that is, comma delimited.
    file = regexprep(file,'(\.xls)$','.csv'); % change extention to 'csv'.
    try
        dlmwrite(file,data,','); % write data.
    catch
        [last_error] = lasterror;
        erroridentifier = 'MATLAB:xlswrite:dlmwrite';
        errormessage = ['An error occurred on data export in CSV format.\n',...
            last_error.message];
        if nargout == 0
            % Throw error.
            error(erroridentifier,errormessage);
        else
            success = false;
            message.message = sprintf(errormessage);
            message.identifier = erroridentifier;
        end
    end
    return;
end
%------------------------------------------------------------------------------
try
    % Construct range string
    if isempty(strfind(range,':'))
        % Range was partly specified or not at all. Calculate range.
        [m,n] = size(A);
        range = calcrange(range,m,n);
    end
catch
    if nargout == 0
        rethrow(lasterror);  	   % Display last error.
    else
        success = false;
        message = lasterror;       % Return last error.
    end
    return;
end

%------------------------------------------------------------------------------
try
    if ~exist(file,'file');
        % Create new workbook.
        ExcelWorkbook = Excel.workbooks.Add;
    else
        % Open workbook.
        ExcelWorkbook = Excel.workbooks.Open(file);
    end

    try % select region.
        % Activate indicated worksheet.
        message = activate_sheet(Excel,sheet);

        % Select range in worksheet.
        Select(Range(Excel,sprintf('%s',range)));

    catch % Throw data range error.
        error('MATLAB:xlswrite:SelectDataRange',lasterr);
    end

    % Export data to selected region.
    set(Excel.selection,'Value',A);

    if ~exist(file,'file') % invoke saveAs dialogue;
        ExcelWorkbook.SaveAs(file,1); % save as Excel Workbook;
    else % replace existing file.
        ExcelWorkbook.Save;
    end

    ExcelWorkbook.Close(false)  % Close Excel workbook.

catch
    try
        ExcelWorkbook.Close(false);    % Close Excel workbook.
    end
    delete(Excel);                 % Terminate Excel server.
    if nargout == 0
        rethrow(lasterror);  	   % Display last error.
    else
        success = false;
        message = lasterror;       % Return last error.
    end
end
%--------------------------------------------------------------------------
function message = activate_sheet(Excel,Sheet)
% Activate specified worksheet in workbook.

% Initialise worksheet object
WorkSheets = Excel.sheets;
message = struct('message',{''},'identifier',{''});

% Get name of specified worksheet from workbook
try
    TargetSheet = get(WorkSheets,'item',Sheet);
catch
    % Worksheet does not exist. Add worksheet.
    TargetSheet = addsheet(WorkSheets,Sheet);
    warning('MATLAB:xlswrite:AddSheet','Added specified worksheet.');
    if nargout > 0
        [message.message,message.identifier] = lastwarn;
    end
end

% activate worksheet
Activate(TargetSheet);
%------------------------------------------------------------------------------
function newsheet = addsheet(WorkSheets,Sheet)
% Add new worksheet, Sheet into worsheet collection, WorkSheets.

if isnumeric(Sheet)
    % iteratively add worksheet by index until number of sheets == Sheet.
    while WorkSheets.Count < Sheet
        % find last sheet in worksheet collection
        lastsheet = WorkSheets.Item(WorkSheets.Count);
        newsheet = WorkSheets.Add([],lastsheet);
    end
else
    % add worksheet by name.
    % find last sheet in worksheet collection
    lastsheet = WorkSheets.Item(WorkSheets.Count);
    newsheet = WorkSheets.Add([],lastsheet);
end
% If Sheet is a string, rename new sheet to this string.
if ischar(Sheet)
    set(newsheet,'Name',Sheet);
end

%------------------------------------------------------------------------------
function [absolutepath]=abspath(partialpath)

% parse partial path into path parts
[pathname filename ext] = fileparts(partialpath);
% no path qualification is present in partial path; assume parent is pwd, except
% when path string starts with '~' or is identical to '~'.
if isempty(pathname) && isempty(strmatch('~',partialpath))
    Directory = pwd;
elseif isempty(regexp(partialpath,'(.:|\\\\)')) && ...
        isempty(strmatch('/',partialpath)) && ...
        isempty(strmatch('~',partialpath));
    % path did not start with any of drive name, UNC path or '~'.
    Directory = [pwd,filesep,pathname];
else
    % path content present in partial path; assume relative to current directory,
    % or absolute.
    Directory = pathname;
end

% construct absulute filename
absolutepath = fullfile(Directory,[filename,ext]);
%------------------------------------------------------------------------------
function range = calcrange(range,m,n)
% Calculate full target range, in Excel A1 notation, to include array of size
% m x n

range = upper(range);
cols = isletter(range);
rows = ~cols;
% Construct first row.
if ~any(rows)
    firstrow = 1; % Default row.
else
    firstrow = str2double(range(rows)); % from range input.
end
% Construct first column.
if ~any(cols)
    firstcol = 'A'; % Default column.
else
    firstcol = range(cols); % from range input.
end
try
    lastrow = num2str(firstrow+m-1);   % Construct last row as a string.
    firstrow = num2str(firstrow);      % Convert first row to string image.
    lastcol = dec2base27(base27dec(firstcol)+n-1); % Construct last column.

    range = [firstcol firstrow ':' lastcol lastrow]; % Final range string.
catch
    error('MATLAB:xlswrite:CalculateRange',...
        'Data range must be between A1 and IV65536.');
end

%------------------------------------------------------------------------------
function s = dec2base27(d)

%   DEC2BASE27(D) returns the representation of D as a string in base 27,
%   expressed as 'A'..'Z', 'AA','AB'...'AZ', until 'IV'. Note, there is no zero
%   digit, so strictly we have hybrid base26, base27 number system.  D must be a
%   negative integer bigger than 0 and smaller than 2^52, which is the maximum
%   number of columns in an Excel worksheet.
%
%   Examples
%       dec2base(1) returns 'A'
%       dec2base(26) returns 'Z'
%       dec2base(27) returns 'AA'
%-----------------------------------------------------------------------------
b = 26;
symbols = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

d = d(:);
if d ~= floor(d) | any(d < 0) | any(d > 1/eps)
    error('MATLAB:xlswrite:Dec2BaseInput',...
        'D must be an integer, 0 <= D <= 2^52.');
end

% find the number of columns in new base
n = max(1,round(log2(max(d)+1)/log2(b)));
while any(b.^n <= d)
    n = n + 1;
end

% set b^0 column
s(:,n) = rem(d,b);
while n > 1 && any(d)
    if s(:,n) == 0
        s(:,n) = b;
    end
    if d > b
        % after the carry-over to the b^(n+1) column
        if s(:,n) == b
            % for the b^n digit at b, set b^(n+1) digit to b
            s(:,n-1) = floor(d/b)-1;
        else
            % set the b^(n+1) digit to the new value after the last carry-over.
            s(:,n-1) = rem(floor(d/b),b);
        end
    else
        s(:,n-1) = []; % remove b^(n+1) digit.
    end
    n = n - 1;
end
s = symbols(s);
%------------------------------------------------------------------------------
function d = base27dec(s)
%   BASE27DEC(S) returns the decimal of string S which represents a number in
%   base 27, expressed as 'A'..'Z', 'AA','AB'...'AZ', until 'IV'. Note, there is
%   no zero so strictly we have hybrid base26, base27 number system.
%
%   Examples
%       base27dec('A') returns 1
%       base27dec('Z') returns 26
%       base27dec('IV') returns 256
%-----------------------------------------------------------------------------

d = 0;
b = 26;
n = numel(s);
for i = n:-1:1
    d = d+(s(i)-'A'+1)*(b.^(n-i));
end
%-------------------------------------------------------------------------------
