function info = dbfinfo(fid)
%DBFINFO Read header information from DBF file.
%   FID File identifier for an open DBF file.
%   INFO is a structure with the following fields:
%      Filename       Char array containing the name of the file that was read
%      DBFVersion     Number specifying the file format version
%      FileModDate    A string containing the modification date of the file
%      NumRecords     A number specifying the number of records in the table
%      NumFields      A number specifying the number of fields in the table
%      FieldInfo      A 1-by-numFields structure array with fields:
%         Name        A string containing the field name 
%         Type        A string containing the field type 
%         ConvFunc    A function handle to convert from DBF to MATLAB type
%         Length      A number of bytes in the field
%      HeaderLength   A number specifying length of the file header in bytes
%      RecordLength   A number specifying length of each record in bytes

%   Copyright 1996-2003  The MathWorks, Inc.  
%   $Revision: 1.1.10.2 $  $Date: 2003/08/01 18:23:31 $

[version, date, numRecords, headerLength, recordLength] = readFileInfo(fid);
fieldInfo = getFieldInfo(fid);

info.Filename     = fopen(fid);
info.DBFVersion   = version;
info.FileModDate  = date;
info.NumRecords   = numRecords;
info.NumFields    = length(fieldInfo);
info.FieldInfo    = fieldInfo;
info.HeaderLength = headerLength;
info.RecordLength = recordLength;

%----------------------------------------------------------------------------
function [version, date, numRecords, headerLength, recordLength] = readFileInfo(fid)
% Read from File Header.

fseek(fid,0,'bof');

version = fread(fid,1,'uint8');

year  = fread(fid,1,'uint8') + 1900;
month = fread(fid,1,'uint8');
day   = fread(fid,1,'uint8');

dateVector = datevec(sprintf('%d/%d/%d',month,day,year));
dateForm = 1;% dd-mmm-yyyy
date = datestr(dateVector,dateForm);

numRecords   = fread(fid,1,'uint32');
headerLength = fread(fid,1,'uint16');
recordLength = fread(fid,1,'uint16');

%----------------------------------------------------------------------------
function fieldInfo = getFieldInfo(fid)
% Form FieldInfo by reading Field Descriptor Array.
%
% FieldInfo is a 1-by-numFields structure array with the following fields:
%       Name      A string containing the field name 
%       Type      A string containing the field type 
%       ConvFunc  A function handle to convert from DBF to MATLAB type
%       Length    A number equal to the length of the field in bytes

lengthOfLeadingBlock    = 32;
lengthOfDescriptorBlock = 32;
lengthOfTerminator      =  1;
fieldNameOffset         = 16;  % Within table field descriptor
fieldNameLength         = 11;

% Get number of fields.
fseek(fid,8,'bof');
headerLength = fread(fid,1,'uint16');
numFields = (headerLength - lengthOfLeadingBlock - lengthOfTerminator)...
               / lengthOfDescriptorBlock;

% Read field lengths.
fseek(fid,lengthOfLeadingBlock + fieldNameOffset,'bof');
lengths = fread(fid,[1 numFields],'uint8',lengthOfDescriptorBlock - 1);

% Read the field names.
fseek(fid,lengthOfLeadingBlock,'bof');
data = fread(fid,[fieldNameLength numFields],...
             sprintf('%d*uint8=>char',fieldNameLength),...
             lengthOfDescriptorBlock - fieldNameLength);
data(data == 0) = ' '; % Replace nulls with blanks
names = cellstr(data')';

% Read field types.
fseek(fid,lengthOfLeadingBlock + fieldNameLength,'bof');
dbftypes = fread(fid,[numFields 1],'uint8=>char',lengthOfDescriptorBlock - 1);

% Convert DBF field types to MATLAB types.
typeConv = dbftype2matlab(upper(dbftypes));

% Return a struct array.
fieldInfo = cell2struct(...
    [names;  {typeConv.MATLABType}; {typeConv.ConvFunc}; num2cell(lengths)],...
    {'Name', 'Type',                'ConvFunc',          'Length'},1)';

%----------------------------------------------------------------------------
function typeConv = dbftype2matlab(dbftypes)
% Construct struct array with MATLAB types & conversion function handles.

typeLUT = ...
    {'N', 'double', @str2double2cell;...   % DBF numeric
     'F', 'double', @str2double2cell;...   % DBF float
     'C', 'char',   @cellstr;...           % DBF character
     'D', 'char',   @cellstr};             % DBF date

unsupported = struct('MATLABType', 'unsupported', ...
                     'ConvFunc',   @cellstr);
                     
% Unsupported types: Logical,Memo,N/ANameVariable,Binary,General,Picture

numFields = length(dbftypes);
if numFields ~= 0
  typeConv(numFields) = struct('MATLABType',[],'ConvFunc',[]);
end
for k = 1:numFields
    idx = strmatch(dbftypes(k),typeLUT(:,1));
    if ~isempty(idx)
        typeConv(k).MATLABType = typeLUT{idx,2};
        typeConv(k).ConvFunc   = typeLUT{idx,3};
    else
        typeConv(k) = unsupported;
    end
end

%----------------------------------------------------------------------------
function out = str2double2cell(in)
% Translate IN, an M-by-N array of class char, to an M-by-1 column vector
% OUT, of class double.  IN may be blank- or null-padded. If IN(k,:) does
% not represent a valid scalar value, then OUT(k) has value NaN.
out = num2cell(str2double(cellstr(in)));
