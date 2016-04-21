function info = fitsinfo(filename)
%FITSINFO  Information about FITS file
%
%   INFO = FITSINFO(FILENAME) returns a structure whose fields contain
%   information about the contents a FITS (Flexible Image Transport System)
%   file.  FILENAME is a string that specifies the name of the FITS file.
%
%   The INFO structure will contain the following fields:
%
%      Filename      A string containing the name of the file 
%      
%      FileSize      An integer indicating the size of the file in bytes
%      
%      FileModDate   A string containing the modification date of the file
%
%      Contents      A cell array containing a list of extensions in the
%                    file in the order that they occur
%      
%      PrimaryData   A structure containing information about the primary
%                    data in the FITS file
%
%   The PrimaryData structure will contain the following fields:
%
%      DataType      Precision of the data 
%      
%      Size          Array containing sizes of each dimension
%
%      DataSize      Size in bytes of primary data 
%
%      MissingDataValue  Value used to represent undefined data
%
%      Intercept     Value used along with Slope to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         Value used along with Intercept to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        Number of bytes from beginning of file to location of
%                    first data value
%
%      Keywords      A number-of-keywords x 3 cell array which contain all 
%                    the Keywords, Values and Comments of the header in each
%                    column.
%
%
%   A FITS file may have any number of extensions.  One or more of the
%   following fields may also be present in the INFO structure:
%   
%      AsciiTable  An array of structures containing information
%                  about the Ascii Table extensions in this file
%         
%      BinaryTable An array of structures containing information
%                  about any Binary Table extensions in this file
%         
%      Image       An array of structures containing information
%                  about any Image extensions in this file
%       
%      Unknown     An array of structures containing information
%                  about any non standard extensions in this file.
%
%   The AsciiTable structure will contain the following fields:
%
%      Rows         The number of rows in the table
%        
%      RowSize      The number of characters in each row
%      
%      NFields      The number of fields in each row
%      
%      FieldFormat  A 1 x NFields cell containing formats in which each 
%                   field is encoded.  The formats are FORTRAN-77 format codes.
%
%      FieldPrecision A 1 x NFields cell containing precision of the data in
%                     each field
%
%      FieldWidth   A 1 x NFields array containing the number of characters
%                   in each field
%
%      FieldPos     A 1 x NFields array of numbers representing the
%                   starting column for each field
%
%      DataSize     Size in bytes of the data in the ASCII Table
%
%      MissingDataValue  A 1 x NFields array of numbers used to represent
%                        undefined data in each field
%
%      Intercept    A 1 x NFields array of numbers used along with Slope to
%                   calculate actual data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Slope        A 1 x NFields array of numbers used with Intercept to
%                   calculate true data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Offset       Number of bytes from beginning of file to location of
%                   first data value in the table
%		    
%      Keywords     A number-of-keywords x 3 cell array containing all the
%                   Keywords, Values and Comments in the ASCII table header
%          
%   The BinaryTable structure will contain the following fields:
%
%      Rows        The number of rows in the table
%                  
%      RowSize     The number of bytes in each row
%                  
%      NFields     The number of fields in each row
%
%      FieldFormat  A 1 x NFields cell containing the data type of the data
%                   in each field. The data type is represented by a
%                   FITS binary table format code.
%
%      FieldPrecision A 1 x NFields cell containing precision of the data in
%                     each field
%
%      FieldSize    A 1 x NFields array containing the number of values in
%                   the Nth field
%                            
%      DataSize     Size in bytes of data in the Binary Table.  Value
%                   includes any data past the main table
%
%      MissingDataValue  An 1 x NFields array of numbers used to represent
%                        undefined data in each field
%
%      Intercept    A 1 x NFields array of numbers used along with Slope to
%                   calculate actual data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Slope        A 1 x NFields array of numbers used with Intercept to
%                   calculate true data values from the array data values
%                   using the equation: actual_value = Slope*array_value+
%                   Intercept
%		    
%      Offset       Number of bytes from beginning of file to location of
%                   first data value
%
%      ExtensionSize    The size in bytes of any data past the main table
%
%      ExtensionOffset  The number of bytes from the beginning of the file to
%                       the location of the data past the main table
%      
%      Keywords      A number-of-keywords x 3 cell array containing all the
%                    Keywords, Values and Comments in the Binary table header
%
%   The Image structure will contain the following fields:
%   
%      DataType      Precision of the data 
%      
%      Size          Array containing sizes of each dimension
%
%      DataSize      Size in bytes of data in the Image extension
%
%      MissingDataValue  Value used to represent undefined data
%
%      Intercept     Value used along with Slope to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         Value used along with Intercept to calculate true pixel
%                    values from the array pixel values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        Number of bytes from beginning of file to location of
%                    first data value
%
%      Keywords      A number-of-keywords x 3 cell array containing all the
%                    Keywords, Values and Comments in the Image header
%
%   The Unknown structure will contain the following fields:
%
%      DataType      Precision of the data 
%
%      Size          Array containing sizes of each dimension
%
%      DataSize      Size in bytes of data in the extension
%      
%      Intercept     Value used along with Slope to calculate true data
%                    values from the  array data values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         Value used along with Intercept to calculate true data
%                    values from the array data values using the equation: 
%                    actual_value = Slope*array_value + Intercept
%
%      MissingDataValue  Value used to represent undefined data
%
%      Offset        Number of bytes from beginning of file to location of
%                    first data value
%
%      Keywords      A number-of-keywords x 3 cell array containing all the
%                    Keywords, Values and Comments in the extension header
%
%   See also FITSREAD.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:52 $

estr = nargchk(1,1,nargin,'struct');
if (~isempty(estr))
    error(estr)
end

%Open file 
fid = fopen(filename,'r','ieee-be');
if fid==-1
  error('MATLAB:fitsinfo:fileOpen', 'Unable to open file "%s" for reading.', filename);
else
  info(1).Filename = fopen(fid);
end

d = dir(info.Filename);
info.FileModDate = d.date;
info.FileSize = d.bytes;
info.Contents = {};

%Read primary header.  All FITS files have a primary header 
[info.PrimaryData,headertype,datasize,extensions] = readheaderunit(fid,info.FileSize);

%Check for SIMPLE keyword in all standard fits files
if ~strcmp('SIMPLE',info.PrimaryData.Keywords(:,1))
  warning('MATLAB:fitsinfo:nonstandardFile', ...
          'File %s is not a standard FITS file.  \nFITSINFO will attempt to determine the contents.',filename);
else
  info.Contents{1} = 'Primary';
end

% Skip the primary data
skipData(fid,datasize);

asciicount = 1;
binarycount = 1;
imagecount = 1;
unknowncount = 1;
%Read extension information until EOF is reached
if extensions
  while ~atEOF(fid,info.FileSize)
    % Make sure there is an extension.
    % If not, it may be a "Special Record", so skip one block.
    keyword = readCardImage(fid);
    if ~strcmp(lower(keyword),'xtension')
      status = fseek(fid,2880 - 80,0); % Seek one fits block minus
                                       % one card image just read.
      if status == -1
        warning('MATLAB:fitsinfo:seekFailed', ['Seek failed because of' ...
                    ' incorrect header information.\nFile may be invalid' ...
                    ' or corrupt.\nOutput structure may not contain' ...
                    ' complete fileinformation.']);
        fclose(fid);
        return;
      end
        continue;
    else
      % Rewind one card image
      fseek(fid,-80,0);
    end
      
    [extensioninfo,headertype,datasize] = readheaderunit(fid,info.FileSize);
    if isempty(extensioninfo)
      %No extension
      fclose(fid);
      return;
    end
    switch headertype
     case 'ascii'
      info.AsciiTable(asciicount) = extensioninfo;
      info.Contents{end+1} = 'ASCII Table';
      asciicount = asciicount+1;
     case 'binary'
      info.BinaryTable(binarycount) = extensioninfo;
      info.Contents{end+1} = 'Binary Table';
      info.BinaryTable(binarycount).ExtensionOffset = info.BinaryTable(binarycount).Offset+ info.BinaryTable(binarycount).RowSize*info.BinaryTable(binarycount).Rows;
      binarycount = binarycount+1;
     case 'image'
      info.Image(imagecount) = extensioninfo;
      info.Contents{end+1} = 'Image';
      imagecount = imagecount+1;
     case 'unknown'
      info.Unknown(unknowncount) = extensioninfo;
      info.Contents{end+1} = 'Unknown';
      unknowncount = unknowncount+1;
    end % End switch headertype
    skipData(fid,datasize);
  end % End while ~atEOF(....)
end % End if extensions
%Close file
fclose(fid);
%END FITSINFO
  
function [info,headertype,datasize,extend] = readheaderunit(fid,fileSize)
%Read a header unit from a FITS file. File curser is placed at the end of
%the header (an integral number of 2880 bytes).
%
% INFO header information
% HEADERTYPE Type of data this is describing
% DATASIZE Size of data following this header
% extend  True if there may be extensions

extensions = 0;
extend = 0;
headertype = '';
info = [];

%Read first card image.  Each card is 80 bytes.
[keyword,value,comment] = readCardImage(fid);

switch lower(keyword)
 case 'simple'
  headertype = 'primary';
  info = struct('DataType',[],'Size',[],'DataSize',[],'MissingDataValue',[],'Intercept',[],'Slope',[],'Offset',[],'Keywords',{});
 case 'xtension'
  %  switch lower(deblank(fliplr(deblank(fliplr(value)))))
  switch lower(value(~isspace(value)))
   case 'table'
    headertype = 'ascii'; 
    info = struct('Rows',[],'RowSize',[],'NFields',[],'FieldFormat',{},'FieldPrecision','','FieldWidth',[],'FieldPos',[],'DataSize',[],'MissingDataValue',{},'Intercept',[],'Slope',[],'Offset',[],'Keywords',{});
   case 'bintable'
    headertype = 'binary';
    info = struct('Rows',[],'RowSize',[],'NFields',[],'FieldFormat',{},'FieldPrecision','','FieldSize',[],'DataSize',[],'MissingDataValue',{},'Intercept',[],'Slope',[],'Offset',[],'ExtensionSize',[],'ExtensionOffset',[],'Keywords',{});
   case 'image'
    headertype = 'image';
    info = struct('DataType',[],'Size',[],'DataSize',[],'Offset',[],'MissingDataValue',{},'Intercept',[],'Slope',[],'Keywords',{});
   otherwise
    headertype = 'unknown';
    info = struct('DataType',[],'Size',[],'DataSize',[],'PCOUNT',[],'GCOUNT',[],'Offset',[],'MissingDataValue',[],'Intercept',[],'Slope',[],'Keywords',{});
  end
end

i = 1;
info(i).Keywords{i,1} = keyword;
info(i).Keywords{i,2} = value;
info(i).Keywords{i,3} = comment;
while ~atEOF(fid,fileSize)
  i=i+1;
  card = fread(fid,80,'uchar=>char')';
  try
    [keyword,value,comment] = parsecard(card);
  catch
    fclose(fid);
    error('MATLAB:fitsinfo:cardFormat', 'Unexpected FITS card image format. FITS file may be invalid or corrupt.');
  end
  switch headertype
   case 'primary'
    [info,endFound,extensions] = knownprimarykeywords(info,keyword,value);
   case 'ascii'
    [info,endFound] = knowntablekeywords(info,keyword,value);
   case 'binary'
    [info,endFound] = knownbintablekeywords(info,keyword,value);
   case 'image'
    [info,endFound] = knownimagekeywords(info,keyword,value);
   otherwise
    [info,endFound] = knowngenerickeywords(info,keyword,value);
  end
  
  info.Keywords{i,1} = keyword;
  info.Keywords{i,2} = value;
  info.Keywords{i,3} = comment;
  if endFound
    break;
  end
  if extensions
    extend = 1;
  end
end

if atEOF(fid,fileSize)
  if ~endFound
    warning('MATLAB:fitsinfo:earlyEOF', 'End of file found before the end of the header was reached.\nFile may be an invalid FITS file or corrupt.\nOutput structure may not contain complete file information.');
  end
end

info.DataSize = 0;
switch headertype
 case 'primary'
  if ~isempty(info.Size)
    info.DataSize = prod(info.Size)*precision2bitdepth(info.DataType)/8;
  end
 case 'image'
  info.DataSize = prod(info.Size)*precision2bitdepth(info.DataType)/8;
 case 'ascii'	  
  info.DataSize = info.RowSize*info.Rows;
 case 'binary'	  
  info.DataSize = info.RowSize*info.Rows;
 case 'unknown'	  
  if ~isempty(info.Size)
    info.DataSize = (precision2bitdepth(info.DataType)*info.GCOUNT*(info.PCOUNT + prod(info.Size)))/8;
  end
end

%datasize needs to be output seperately because of the possible extension data
%for binary data
if strcmp(headertype,'binary')
  datasize = info.DataSize+info.ExtensionSize;
else
  datasize = info.DataSize;
end

%Move file position to integral number of 2880 bytes
curr_pos = ftell(fid);
if rem(curr_pos,2880) == 0
    bytes_to_seek = 0;
else
    bytes_to_seek = 2880 - rem(curr_pos,2880);
end 
status = fseek(fid,bytes_to_seek,0);
info.Offset = ftell(fid);
if status == -1
  warning('MATLAB:fitsinfo:seekFailed', 'Seek failed because of incorrect header information.\nFile may be an invalid FITS file or corrupt.\nOutput structure may not contain complete file information.');
end
%End READHEADERUNIT

function [keyword,value,comment] = readCardImage(fid)
[card, readcount] = fread(fid,80,'uchar=>char');
card = card';
if feof(fid)
  return;
elseif readcount ~= 80
  fclose(fid);
  error('MATLAB:fitsinfo:cardbytes', 'FITS card image was not 80 bytes. FITS file may be invalid or corrupt.');
end

try
  [keyword,value,comment] = parsecard(card);
catch
  fclose(fid);
  error('MATLAB:fitsinfo:cardFormat', 'Unexpected FITS card image format. FITS file may be invalid or corrupt.');
end
%End READCARDIMAGE

function [keyword, value, comment] = parsecard(card)
%Extract the keyword, value and comment from a FITS card image

%From Appendix A of FITS standard
%FITS value card image :=
%keyword field value indicator [space...] [value] [space...] [comment]
%
%"The keyword shall be a left justified, 8-character, blank-filled, ASCII
% string with no embedded blanks."
keyword = card(1:8);
keyword = keyword(~isspace(keyword));
card = card(9:end);

%Seperate Value / Comment
% "If a comment is present, it must be preceded by a slash"...
slashidx = findstr('/',card);
%Find quotes, but first remove double single quotes.
idx = findstr(card,'''''');
tempcard = card;
for i=1:length(idx)
  tempcard(idx(i):idx(i)+1) = '';
end
quoteidx = findstr('''',tempcard);
if isempty(slashidx)
  value = card;
  comment = '';
else
  if length(quoteidx)>1 
    %Value is a quoted char string, might need to fix value / comment
    if slashidx(1) > quoteidx(1) && slashidx(1) < quoteidx(2)
      %Slash was part of the value, find 1st slash after the last quote
      slashidx = slashidx(slashidx>quoteidx(2));
      if isempty(slashidx)
	%No comment
	value = card;
	comment = '';
      else
	value = card(1:(slashidx(1)-1));
	comment = card(slashidx(1):end);
      end
    else
      value = card(1:(slashidx(1)-1));
      comment = card(slashidx(1):end);
    end
  else
    value = card(1:(slashidx(1)-1));
    comment = card(slashidx(1):end);
  end
end

if ~isempty(comment) && length(comment)>=2
  %Get rid of / character, not part of the value or comment.
  %Trailing blanks are not mentioned in the standard so leave them alone
  comment = comment(2:end); 
end

%Value
if strcmp(value(1:2),'= ')
  %Keyword is a value keyword
  %Remove value indicator
  value = value(3:end);
  %Remove leading blanks from value
  %  value = fliplr(deblank(fliplr(value)));
  value = sscanf(value,' %s');
  %For performance reasons, do this now
%  numericValue = str2num(value);
  if strcmp(value(1),'''')
    %Quoted character string. Begin and end quotes are not part of
    %the character string.  Trailing spaces are not significant.
    value = deblank(value);
    if strcmp(value(end),'''')
      value = value(2:(end-1));
    else
      %Strange, no closing quote, keep reading though.
    end
    %Replace double single quotes with single quote
    value(findstr(value,'''''')) = '';
  elseif ~isempty(findstr(value(1),'('))
    %Complex number in form of (spaces intentional): ( real , imag )
    % '(' may occur anywhere in the value
    %Character strings in value keywords are always quoted so if a '(' is
    %found then the value is definitely a complex value.
    if  isempty(findstr(value(1),')'))
      warning('MATLAB:fitsinfo:missingParen', 'No closing '')'' found for complex number.  Expected ( r , i ).\nAtempting to read data as complex number.');
    end
    %Remove all spaces
    value(value==' ') = '';
    [a count]  = sscanf(value,'(%f,%f)');
    if count ~= 2
      value = [];
    else
      value = complex(a(1),a(2));
    end
  elseif ~isempty(sscanf(value, '%f'))
    %Numeric value.  Integers and floating point numbers are treated the same
    value = sscanf(value, '%f');
  elseif strcmp(value(value~=' '),'T') || strcmp(value(value~=' '),'F')
    %Logical value. Remove spaces.
    value = value(value~=' ');
  else
    warning('MATLAB:fitsinfo:unknownFormat', 'Unable to determine format of the value.  Will return\nvalue as a string.');
  end
else
  %Comment keyword.
  %Return value as ascii text. Remove trailing blanks.
  value = deblank(value);
  return;  
end
%End PARSECARD

function [info,endFound,extensions] = knownprimarykeywords(info,keyword,value)
endFound = 0;
extensions = 0;
switch lower(keyword)
 case 'bitpix'
  info(1).DataType =  bitdepth2precision(value);
 case 'naxis'
  info(1).Intercept = 0;
  info(1).Slope = 1;
 case 'extend'
  if strcmp(value,'T')
    extensions = 1;
  end
 case 'bzero'
  info(1).Intercept = value;
 case 'bscale'
  info(1).Slope = value;
 case 'blank'
  info(1).MissingDataValue = value;
 case 'end'
  endFound = 1;
 otherwise
  %Take care of NAXISN keywords
  if findstr('naxis',lower(keyword))
    dim = sscanf(keyword(6:end),'%f');
    info(1).Size(dim) = value;
    if length(info(1).Size)==1
      info(1).Size(2) = 1;
    end
  end    
end    
%END KNOWNPRIMARYKEYWORDS

function [info,endFound] = knowntablekeywords(info,keyword,value)
endFound = 0;
switch lower(keyword)
 case 'end'
  endFound = 1;
 case 'naxis1'
  info.RowSize = value;
 case 'naxis2'
  info.Rows = value;
 case 'tfields'
  info.NFields = value;
  info.Slope = ones(1,value);
  info.Intercept = zeros(1,value);
  info.MissingDataValue = cell(1,value);
 otherwise
  %Take care of indexed keywords
  if findstr('tform',lower(keyword))
    % Format is a FORTRAN F-77 code. The code is a characer followed by w.d,
    % the width(w) and implicit decimal place (d).
    % Valid format values in ascii table extensions
    %
    %  A - Character
    %  I - Decimal integer
    %  F - Single precision real 
    %  E - Single precision real, exponential notation
    %  D - Double precision real, exponential notation
    idx = sscanf(keyword(6:end),'%s');
    switch(sscanf(value,' %c',1))
     case 'A'
      format = 'Char';
     case 'I'
      format = 'Integer';
     case {'E','F'}
      format = 'Single';
     case 'D'
      format = 'Double';
     otherwise
      format = 'Unknown';
    end
    
    idxNum = sscanf(idx, '%f');
    
    info.FieldFormat{idxNum} = value;
    info.FieldPrecision{idxNum} = format;
    width = sscanf(value,' %*c%f');
    info.FieldWidth(idxNum) = width;
  elseif findstr('tbcol',lower(keyword))
    idx = sscanf(keyword(6:end),'%s');
    info.FieldPos(sscanf(idx, '%f')) = value;
  elseif findstr('tscal',lower(keyword));
    tscale_idx = sscanf(keyword(6:end),'%i');
    info.Slope(tscale_idx) = value;
  elseif findstr('tzero',lower(keyword));
    tzero_idx = sscanf(keyword(6:end),'%i');
    info.Intercept(tzero_idx) = value;
  elseif findstr('tnull',lower(keyword));
    tnull_idx = sscanf(keyword(6:end),'%i');
    info.MissingDataValue{tnull_idx} = value;
  end
end    
%END KNOWNTABLEKEYWORDS

function [info,endFound] = knownbintablekeywords(info,keyword,value)
endFound = 0;
switch lower(keyword)
 case 'end'
  endFound = 1;
 case 'naxis1'
  info.RowSize = value;
 case 'naxis2'
  info.Rows = value;
 case 'tfields'
  info.NFields = value;
  info.Slope = ones(1,value);
  info.Intercept = zeros(1,value);
  info.MissingDataValue = cell(1,value);
 case 'pcount'
  info.ExtensionSize = value;
 otherwise
   if findstr('tscal',lower(keyword));
    tscale_idx = sscanf(keyword(6:end),'%i');
    info.Slope(tscale_idx) = value;
   elseif findstr('tzero',lower(keyword));
    tzero_idx = sscanf(keyword(6:end),'%i');
    info.Intercept(tzero_idx) = value;
   elseif findstr('tnull',lower(keyword));
     tnull_idx = sscanf(keyword(6:end),'%i');
     info.MissingDataValue{tnull_idx} = value;
   elseif findstr('tform',lower(keyword))
    idx = sscanf(keyword(6:end),'%s');
    repeat = sscanf(value,'%f',1);
    if isempty(repeat)
      repeat = 1;
    end
    format = sscanf(value,' %*i%c',1);
    if isempty(format)
      format = sscanf(value,' %c',1);
    end
    % The value for tformN is a format defined in the FITS standard.  The
    % form is rTa, where r is the repeat, T is the precision and a is a
    % number undefined by the standard. 
    %
    % Binary Table Format valid T (precision) characters and # bytes
    %
    %  L - Logical             1
    %  X - Bit                 *
    %  B - Unsigned Byte       1
    %  I - 16-bit integer      2
    %  J - 32-bit integer      4
    %  A - Character           1
    %  E - Single              4
    %  D - Double              8
    %  C - Complex Single      8
    %  M - Complex Double      16
    %  P - Array Descriptor    8
    switch format
     case 'L'
      format = 'char';
     case 'X'
      format = ['bit' num2str(repeat+8-rem(repeat,8))];
      if repeat~=0
	repeat = 1;
      end
     case 'B'
      format = 'uint8';
     case 'I'
      format = 'int16';
     case 'J'
      format = 'int32';
     case 'A'
      format = 'char';
     case 'E'
      format = 'single';
     case 'D'
      format = 'double';
     case 'C'
      format = 'single complex';
     case 'M'
      format = 'double complex';
     case 'P'
      format = 'int32';
      if repeat~=0
	repeat = 2;
      end
    end
    
    idxNum = sscanf(idx, '%f');
    
    info.FieldFormat{idxNum} = value;
    info.FieldPrecision{idxNum} = format;
    info.FieldSize(idxNum) = repeat;
  end    
end    
%END KNOWNBINTABLEKEYWORDS

function [info,endFound] = knownimagekeywords(info,keyword,value)
endFound = 0;
switch lower(keyword)
 case 'end'
  endFound = 1;
 case 'bitpix'
  info.DataType =  bitdepth2precision(value);
 case 'naxis'
  info.Intercept = 0;
  info.Slope = 1;
 case 'blank'
  info.MissingDataValue= value;
 case 'bzero'
  info.Intercept = value;
 case 'bscale'
  info.Slope = value;
 otherwise
  %NAXISN keywords
  if findstr('naxis',lower(keyword))
    dim = sscanf(keyword(6:end),'%f');
    info(1).Size(dim) = value;
  end    
end    
%END KNOWNIMAGEKEYWORDS

function [info,endFound] = knowngenerickeywords(info,keyword,value)
endFound = 0;
switch lower(keyword)
 case 'bitpix'
  info.DataType =  bitdepth2precision(value);
 case 'naxis'
  info.Intercept = 0;
  info.Slope = 1;
% case 'extend'         % This code doesn't appear to do anything,
%  extensions = 1;      % but I'm keeping it here just 'cuz.
 case 'bzero'
  info.Intercept = value;
 case 'bscale'
  info.Slope = value;
 case 'blank'
  info.MissingDataValue = value;
 case 'pcount'
  info.PCOUNT = value;
 case 'gcount'
  info.GCOUNT = value;
 case 'end'
  endFound = 1;
 otherwise
  %Take care of NAXISN keywords
  if findstr('naxis',lower(keyword))
    dim = sscanf(keyword(6:end),'%f');
    info.Size(dim) = value;
  end    
end    
%END KNOWNGENERICKEYWORDS

function precision = bitdepth2precision(value)
switch value
 case 8
  precision = 'uint8';
 case 16 
  precision = 'int16';
 case 32
  precision = 'int32';
 case -32
  precision = 'single';
 case -64
  precision = 'double';
end
%END BITDEPTH2PRECISION

function bitdepth = precision2bitdepth(precision)
switch precision
 case 'uint8'
  bitdepth = 8;
 case 'int16' 
  bitdepth = 16;
 case 'int32'
  bitdepth = 32;
 case 'single'
  bitdepth = 32;
 case 'double'
  bitdepth = 64;
end
%END PRECISION2BITDEPTH

function v = atEOF(fid,fileSize)
% Sometimes FEOF does not recognize that the file identifier is at the end of
% the file.  So, the end of the file has been reached if FEOF returns true or if
% the file identifyer is at the end of the file.
v = (feof(fid) == 1) || (ftell(fid) == fileSize);

function skipData(fid,datasize)
%Data must be multiple of 2880 bytes
if datasize ~= 0
  if rem(datasize,2880) == 0
    bytes_to_seek = datasize;
  else
    bytes_to_seek = 2880 - rem(datasize,2880) + datasize;
  end
  status = fseek(fid,bytes_to_seek,0);
  if status == -1
    fclose(fid);
    error('MATLAB:fitsinfo:seekFailed', 'Seek failed because of incorrect header information.\nFile may be invalid or corrupt.  Output structure may not contain complete file information.');
  end
end
