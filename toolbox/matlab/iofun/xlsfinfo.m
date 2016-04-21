function [message, description] = xlsfinfo(filename)
%XLSFINFO Determine if file contains Microsoft Excel spreadsheet.
%   [A, DESCR] = XLSFINFO('FILENAME')
%
%   A contains the message 'Microsoft Excel Spreadsheet' if FILENAME points to a
%   readable Excel spreadsheet, but is empty otherwise.
%
%   DESCR contains either the names of non-empty worksheets in the workbook
%   FILENAME, when readable, or an error message otherwise.
%
%   NOTE 1: This function does not work with the compiler.
%   NOTE 2: When an Excel ActiveX server cannot be started, functionality is
%           limited in that some Excel files may not be readable.
%
%   See also XLSREAD, XLSWRITE, TEXTREAD, CSVREAD, CSVWRITE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.3 $  $Date: 2004/04/10 23:29:48 $
%==============================================================================
% Validate filename data type
if nargin < 1
    error('MATLAB:xlsfinfo:Nargin',...
        'Filename must be specified.');
end
if ~isstr(filename)
    error('MATLAB:xlsfinfo:InputClass','Filename must be a string.');
end

% Validate filename is not empty
if isempty(filename)
    error('MATLAB:xlsfinfo:FileName',...
        'Filename must not be empty.');
end

% handle requested Excel workbook filename
try
    [filename, isExcelFile] = validpath(filename,'.xls');
catch
    rethrow(lasterror);
end
%-----------------------------------------------------------------------------
% Attempt to start Excel as ActiveX server process on local host
% try to start ActiveX server
try
    Excel = actxserver('excel.application');
catch
    if ispc
        warning('MATLAB:xlsfinfo:ActiveX',...
            ['Could not start Excel server. ' ...
            'See documentation for resulting limitations.'])
    end
    try
        [message,description] = xlsfinfo_old(filename);
    catch
        rethrow(lasterror);
    end
    return
end
%-----------------------------------------------------------------------------
% Open Excel workbook.
if isExcelFile
    workbook = Excel.workbooks.Open(filename);

    % walk through sheets in workbook and pick non-empty worksheets.
    message = 'Microsoft Excel Spreadsheet';
    indexes = logical([]);
    % Initialise worksheets object.
    workSheets = Excel.sheets;
    for i = 1:workSheets.Count
        sheet = get(workSheets,'item',i);
        description{i} = sheet.Name;
        try
            if ~isempty(sheet.UsedRange.value)
                indexes(i) = true;
            else
                indexes(i) = false;
            end
        catch
            % current sheet is not a worksheet.
            indexes(i) = false;
        end
    end
    description = description(indexes);
else % not an excel file
    message = '';
    description = ['Unreadable XLS file: ' lasterr];
end

try
    workbook.Close(false); % close workbook without saving any changes.
    delete(Excel); % delete COM server
end
return
%==============================================================================
function [m, descr] = xlsfinfo_old(filename)

biffvector = [];

try
    biffvector = biffread(filename);
catch
    waserror = true;
end

if ~isempty(biffvector)
    try
        m = 'Microsoft Excel Spreadsheet';
        [a,descr] = biffparse(biffvector);
        descr = descr';
        waserror = false;
    catch
        waserror = true;
    end
end

if waserror || isempty(biffvector)
    m = '';
    descr = ['Unreadable XLS file: ' lasterr];
end
%--------------------------------------------------------------------------
%----