function multibandwrite(data,filename,interleave,varargin)
%MULTIBANDWRITE write multiband data to a file
%
%   MULTIBANDWRITE writes a three dimensional data set to a binary file. All the
%   data may be written to the file with one function call or MULTIBANDWRITE may
%   be called repeatedly to write pieces of the complete data set to the file.
%
%   The following two syntaxes are ways to use MULTIBANDWRITE to write the
%   entire data set to the file with one function call.  The optional
%   parameter/value pairs described at the below can also be used with these
%   syntaxes.
%
%     MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE) writes DATA, the 2 or
%     3-dimensional array of any numeric or logical type, to the binary file
%     FILENAME.  The bands are written to the file in the form specified by
%     INTERLEAVE. The length of the third dimension of DATA is equal to the
%     number of bands.  By default the data is written to the file in the same
%     precision as it is stored in MATLAB (the same as the class of DATA).
%     INTERLEAVE is a string specifying the method of interleaving the bands
%     written to the file.  Valid strings are 'bil', 'bip', 'bsq', representing
%     band-interleaved-by-line, band-interleaved-by-pixel, and band-sequential
%     respectively. INTERLEAVE is irrelevant if DATA is 2-dimensional. If
%     FILENAME already exists, it will be overwritten unless the optional OFFSET
%     parameter has been specified.
%     
%   The complete data set may be written to the file in smaller chunks by
%   making multiple calls to MULTIBANDWRITE using the following syntax.
%
%     MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,START,TOTALSIZE) writes
%     the data to the binary file piece by piece. DATA is a subset of the
%     complete data set.  MULTIBANDWRITE will be called multiple times to write
%     all the data to the file. A complete file will be written during the
%     first function call and populated with fill values outside the subset
%     provided in the first call and subsequent calls will overwrite all or
%     some of the fill values. The parameters FILENAME, INTERLEAVE, OFFSET
%     and TOTALSIZE should remain constant throughout the writing of the
%     file.
%
%      START == [firstrow firstcolumn firstband] is 1-by-3 where firstrow
%      and firstcolumn gives the image pixel location of the upper left
%      pixel in the box and firstband gives the index of the first band to
%      write.  DATA contains some of the data for some of the bands.
%      DATA(I,J,K) contains the data for the pixel at [firstrow + I - 1,
%      firstcolumn + J - 1] in the (firstband + K - 1)-th band.
%
%      TOTALSIZE == [totalrows,totalcolumns,totalbands] gives the full
%      three-dimensional size of the complete data set to be contained in
%      the file.
%
%   Any number and combination these optional parameter/value pairs may be
%   added to the end of any of the above syntaxes.
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,...,PARAM,VALUE,...) 
%
%     Parameter Value Pairs:
%     
%     PRECISION is a string to control the form and size of each element
%     written to the file.  See the help for FWRITE for a list of valid
%     values for PRECISION.  The default precision is the class of the data.
%
%     OFFSET is the number of bytes to skip before the first data element. If
%     the file does not already exist, ASCII null values will be written to fill
%     the space by default. This option is useful when writing a header to the
%     file before or after writing the data. When writing the header after the
%     data is written, the file should be opened with FOPEN using 'r+'
%     permission.
%
%     MACHFMT is a string to control the format in which the data
%     is written to the file. Typical values are 'ieee-le' for little endian
%     and 'ieee-be' for big endian however all values for MACHINEFORMAT as
%     documented in FOPEN are valid.  See FOPEN for a complete list.  The
%     default machine format is the local machine format.
%     
%     FILLVALUE is a number specifying the value for missing data. FILLVALUE
%     may be a single number, specifying the fill value for all missing data
%     or FILLVALUE may be a 1-by-number of bands vector of numbers
%     specifying the fill value for each band.  This value will be used to
%     fill space when data is written in chunks.
%
%   Examples:
%
%   1.  All data is written to the file with one function call.  The
%       bands are interleaved by line.
%        
%         multibandwrite(data,'data.img','bil');
%  
%   2.  MUTLIBANDWRITE is used in a loop to write each band to a file.
%
%       for i=1:totalBands
%           multibandwrite(bandData,'data.img','bip',[1 1 i],...
%                          [totalColumns, totalRows, totalBands]);
%       end
%       
% 3.  Only a subset of each band is available for each call to
%       MULTIBANDWRITE. For example, an entire data set may have 3 bands
%       with 1024-by-1024 pixels each (a 1024-by-1024-by-3
%       matrix). Only 128-by-128 chunks are available to be written to
%       the file with each call to MULTIBANDWRITE. 
%
%      numBands = 3;
%      totalDataSize =  [1024 1024 numBands];
%      for i=1:numBands
%         for k=1:8
%             for j=1:8
%                upperLeft = [(k-1)*128 (j-1)*128 i];
%                multibandwrite(data,'banddata.img','bsq',...
%                               upperLeft,totalDataSize);
%             end
%          end
%       end
%
%   See also MULTIBANDREAD, FWRITE, FREAD 

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:54 $

error(nargchk(3,12,nargin, 'struct'));
error(nargoutchk(0,0,nargout, 'struct'));

[machfmt,offsetBuffer,precision,...
 fillvalue,chunking,start,totalsize,...
 permission,exists] = parseInputs(data,filename,...
                                  interleave,varargin{:});

% Check consistency of sizes
d = dir(filename);
expectedSize = expectedFileSize(length(offsetBuffer),totalsize,precision);
if exists && chunking
  if ((d.bytes~=length(offsetBuffer)) && ...
        (d.bytes~=expectedSize)) || any(totalsize)<=0
    error('MATLAB:multibandwrite:badTotalsize', ...
          'TOTALSIZE is inconsistent with the existing file size.');
  end
end

fid = fopen(filename,permission,machfmt);
if fid<0
  error('MATLAB:multibandwrite:fileOpen', ...
        'Unable to open %s for writing.',filename);
end

%status = fseek(fid,0,'bof'); FSEEK to bof may not always work. Geck #117077
if exists
  status = fseek(fid,length(offsetBuffer),'bof');
  if status == -1
    fclose(fid);
    error('MATLAB:multibandwrite:seekError', ...
          'Unable to seek to desired offset.');
  end
else
  fwrite(fid,offsetBuffer,'uint8');
end

if (~exists && chunking) || (exists && (d.bytes==length(offsetBuffer)))
  % The first time when writing chunks fill the file with the complete
  % amount of data.
  writeFillData(fid,size(data),totalsize,fillvalue,precision);
end

switch lower(interleave)
 case 'bsq'
  writebsqfile(fid,data,precision,chunking,start,totalsize);
 case 'bil'                                               
  writebilfile(fid,data,precision,chunking,start,totalsize);
 case 'bip'                                               
  writebipfile(fid,data,precision,chunking,start,totalsize);
end
fclose(fid);

%=============================================================
function expectedSize = expectedFileSize(offsetSize,totalsize,precision)
numPixels = prod(totalsize);
[w,outputClass,bitprecision] = getPixelInfo(precision);
if bitprecision
  expectedSize = ceil(offsetSize+numPixels*w/8);
else
  expectedSize = offsetSize+numPixels*w;
end

%=============================================================
function writebipfile(fid,data,precision,chunking,...
                      start,totalsize)

[rows,columns,bands] = size(data);
[w,outputClass,bitprecision,msg] = getPixelInfo(precision);
if ~isempty(msg)
  error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if ~chunking
  for i=1:rows
    for j=1:columns
      for k=1:bands
        fwrite(fid,data(i,j,k),precision);
      end
    end
  end
else
  switch length(start)
   case 1
    for i=1:size(data,3)
      %Seek to begining of band
      skip(fid,(start(1)-1) + (i-1),precision,bitprecision,w);
      for j=1:rows
        for k=1:columns
          fwrite(fid,data(j,k,i),precision);
          skip(fid,totalsize(1)-1,precision,bitprecision,w,'cof');
        end
      end
    end
   case 2
    %Seek to first row
    skipSize = size(data,3)*totalsize(2)*(start(1)-1);
    %Seek to first column
    skipSize = skipSize + (start(2)-1)*(size(data,3)-1);
    firstPixel = skipSize;
    for i=1:rows
      %%Seek to beginning of row
      skipSize = firstPixel + totalsize(3)*totalsize(2)*(i-1);
      skip(fid,skipSize,precision,bitprecision,w);
      for j=1:columns
        fwrite(fid,data(i,j,:),precision);
      end
    end
   case 3
    %Seek to begining of band
    skipSize = start(3)-1;
    %Seek to first row
    skipSize = skipSize + totalsize(3)*totalsize(2)*(start(1)-1);
    %Seek to first column
    skipSize = skipSize + (start(2)-1)*totalsize(3);
    firstPixel = skipSize;
    for i=1:rows
      %%Seek to beginning of row
      skipSize = firstPixel + totalsize(3)*totalsize(2)*(i-1);
      skip(fid,skipSize,precision,bitprecision,w);
      for j=1:columns
        fwrite(fid,data(i,j,:),precision);
        %Seek to next column
        skip(fid,totalsize(3)-size(data,3),precision,bitprecision,w,'cof');
     end
    end
  end
end

%=============================================================
function writebilfile(fid,data,precision,chunking,...
                      start,totalsize)

rows = size(data, 1);
bands = size(data, 3);
[w,outputClass,bitprecision,msg] = getPixelInfo(precision);
if ~isempty(msg)
  error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if ~chunking
  for i=1:rows
    for j=1:bands
      fwrite(fid,data(i,:,j),precision);
    end
  end
else
  switch length(start)
   case 1
    %Seek to beginning of band
    skipSize = (start(1)-1)*size(data,2);
    for k=1:size(data,1)
      %Seek to beginning of row
      skip(fid,skipSize + (k-1)*size(data,2)*totalsize(3),precision,bitprecision,w);
      fwrite(fid,data(k,:,:),precision);
      % Memory abusive 
      %      if i==1
      %        count = fwrite(fid,data(i,:),precision);
      %        fseek(fid,-count*w,'cof');
      %      else
      %        count = fwrite(fid,permute(data,[2 1 3]),...
      %                       [num2str(size(data,2)) '*' precision],...
      %                       (totalsize(3)-1)*size(data,2)*w);
      %      end
    end
   case 2
    %Skip to column to write
    skipSize = start(2)-1;
    %Skip to row to write
    skipSize = skipSize + (start(1)-1)*totalsize(2)*totalsize(3);
    %Loop over number of rows to write
    for k=1:size(data,1)
      skip(fid,skipSize + (k-1)*totalsize(2)*totalsize(3),precision,bitprecision,w);
      %Write all bands
      fwrite(fid,data(k,:,:),precision);
    end
   case 3
    %Skip to the band to write
    skipSize = (start(3)-1)*totalsize(2);
    %Skip to column to write
    skipSize = skipSize + start(2)-1;
    %Skip to row to write
    skipSize = skipSize + (start(1)-1)*totalsize(2)*totalsize(3);
    %Loop over number of rows to write
    for k=1:size(data,1)
      skip(fid,skipSize + (k-1)*totalsize(2)*totalsize(3),precision,bitprecision,w);
      fwrite(fid,data(k,:,:),precision);
    end
  end
end
    
    
%=============================================================
function writebsqfile(fid,data,precision,chunking,...
                      start,totalsize)

rows = size(data, 1);
bands = size(data, 3);
[w,outputClass,bitprecision,msg] = getPixelInfo(precision);
if ~isempty(msg)
  error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if ~chunking
  for i=1:bands
    for j=1:rows
      fwrite(fid,data(j,:,i),precision);
    end
  end
  % Memory abusive way
  %  fwrite(fid,permute(data,[2 1 3]),precision);
else
  switch length(start)
   case 1
    %Seek to beginning of first band to write
    skip(fid,(start-1)*prod(totalsize(1:2)),precision,bitprecision,w);
    for i=1:bands
      for j=1:rows
        fwrite(fid,data(j,:,i),precision);
      end
    end
    % Memory abusive way
    % fwrite(fid,permute(data,[2 1 3]),precision);
   case 2
    for k=1:size(data,3)
      %Skip to beginning of the band to write
      skipSize = (k-1)*prod(totalsize(1:2));
      %Skip to beginning of the first column to write
      skipSize = skipSize + (start(2)-1);  
      %Loop over number of row (because row major order in file)
      for i=1:size(data,1)
        %Skip to beginning of the row to write
        skip(fid,skipSize + (start(1)+i-2)*totalsize(2),precision,bitprecision,w);
        fwrite(fid,data(i,:,k),precision);
      end
    end
   case 3
    for k=1:size(data,3)
      %Skip to beginning of the band to write
      skipSize = (start(3)+k-2)*prod(totalsize(1:2));
      %Skip to beginning of the first column to write
      skipSize = skipSize + (start(2)-1);  
      %Loop over number of row (because row major order in file)
      for i=1:size(data,1)
        %Skip to beginning of the row to write
        skip(fid,skipSize + (start(1)+i-2)*totalsize(2),precision,bitprecision,w);
        fwrite(fid,data(i,:,k),precision);
      end
    end
  end
end

%=============================================================
function writeFillData(fid,datasize,totalsize,fillvalue,precision)

currentPos = ftell(fid);

if length(datasize)==length(totalsize) && all(datasize==totalsize)
  chunking = false;
else
  chunking = true;
end

% Create same number of fill values as amount of data user entered.
[w,outputClass,bitprecision,msg] = getPixelInfo(precision);
if ~isempty(msg)
  error('MATLAB:multibandwrite:getPixelInfo', msg);
end

if length(fillvalue)==1
  % Fill value is the same for all bands
  fillBuffer(prod(datasize)) = feval(outputClass,fillvalue);
  % Calculate number of times to loop
  loop      = fix(prod(totalsize)/prod(datasize));
  remainder = rem(prod(totalsize),prod(datasize));
  % Write fill values
    for i=1:loop
    fwrite(fid,fillBuffer,precision);
  end
  % Write remainder
  if remainder
    fwrite(fid,fillBuffer(1:remainder),precision);
  end
else
  % Fill value is different for each band
  % Use 1 full band as a reasonable size buffer
  for i=1:totalsize(3)
    fillBuffer(totalsize(1),totalsize(2)) = feval(outputClass,fillvalue(i));
    start = [1 1 i];
    switch lower(interleave)
     case 'bsq'
      writebsqfile(fid,fillBuffer,precision,chunking,start,totalsize);
     case 'bil'        
      writebilfile(fid,fillBuffer,precision,chunking,start,totalsize);
     case 'bip'        
      writebipfile(fid,fillBuffer,precision,chunking,start,totalsize);
    end
  end
end
fseek(fid,currentPos,'bof');
return;

%=============================================================================
function [w,outputClass,bitprecision,msg] = getPixelInfo(precision)
% Returns width of each pixel.  Width is in bytes unless precision is 
% ubitN or bitN in which case width is in bits.  
% FTELL does not return correct values for bit precisions

msg = '';  
bitprecision = false;  
if isempty(strfind(precision,'bit'))
    tempfile = tempname;
    tf = fopen(tempfile,'wn');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for writing.',tempfile);
    else
        try
            fwrite(tf,1,precision);
        catch
            fclose(tf);
            delete(tempfile);
            rethrow(lasterror);
        end
        fclose(tf);
    end
    
    tf = fopen(tempfile,'r');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for reading.',tempfile);
    else
        p = ftell(tf);
        tmp = fread(tf, 1, ['*' precision]);
        w = ftell(tf)-p;
        fclose(tf);
        outputClass = class(tmp);
    end
    try
        delete(tempfile);
    catch
        warning('MATLAB:multibandwrite:tempFileDelete', ...
                'Unable to delete temporary file %s.', tempfile);
    end
else
    % If it is a bit precision, parse the precision string to determine w.
    bitprecision = true;
    precision(isspace(precision))=[];
    if strncmp(precision,'*',1)
        precision(1)=[];
    end
    i = strfind(precision,'=>')-1;
    if isempty(i)
        i=length(precision);
    end
    w = sscanf(precision(~isletter(precision(1:i))), '%d');
    if isempty(w)
        error('MATLAB:multibandwrite:badPrecision', 'Unrecognized PRECISION, ''%s''.',precision);
    end
    tempfile = tempname;
    tf = fopen(tempfile,'wn');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for writing.',tempfile);
    else
        fwrite(tf,ones(1,8),precision);
        fclose(tf);
    end
    
    tf = fopen(tempfile,'r');
    if tf<0
        msg = sprintf('Unable to open temporary file %s for reading.',tempfile);
    else
        p = ftell(tf);
        tmp = fread(tf, 1, ['*' precision]);
        w = ftell(tf)-p;
        fclose(tf);
        outputClass = class(tmp);
    end
    try
        delete(tempfile);
    catch
        warning('MATLAB:multibandwrite:tempFileDelete', ...
                'Unable to delete temporary file %s.', tempfile);
    end
end
return;

%=============================================================

function skip(fid,skipSize,precision,bitprecision,eltsize,origin)
% Seek to a position in the file.
% If precision is a bit precision then skipSize is in bits.

if nargin==6
  origin = origin;
else
  origin = 'bof';
end
  
if bitprecision
  if strcmp(origin,'bof')
    frewind(fid);
  end
  % FSEEK 0 bytes before and after FREAD because file is being written to and
  % read from without being re-opened.
  fseek(fid,0,'cof');
  fread(fid,skipSize/eltsize,precision);
  fseek(fid,0,'cof');
else
  fseek(fid,skipSize*eltsize,origin);
end
return;

%=============================================================
function [machfmt,offsetBuffer,precision,...
          fillvalue,chunking,start,...
          totalsize,permission,exists] = parseInputs(data,filename,...
                                                  interleave,varargin)

if ~isnumeric(data) && ~islogical(data)
  error('MATLAB:multibandwrite:badData', ...
        'DATA must be a numeric or logical array.');
end

if ndims(data) > 3
  error('MATLAB:multibandwrite:badData', ...
        'DATA must have no more than three dimensions.');
end

if ~ischar(filename)
  error('MATLAB:multibandwrite:badFilename', ...
        'FILENAME must be a string.');
end

if isempty(strmatch(lower(interleave),{'bil','bsq','bip'}))
  error('MATLAB:multibandwrite:badInterleave', ...
        'INTERLEAVE must be ''bil'', ''bip'', or ''bip''');
end

% Default precision == class of DATA
precision = class(data);
% Default to native machine format
machfmt   = 'n';
% Deafult fillvalue of zero
fillvalue = 0;
chunking  = false;
start     = [];
totalsize = [];
% Default to an offset of zero
% What if fillvalue is out of range?
offsetBuffer = uint8([]);

if islogical(data)
  precision = 'ubit1';
end

if ( (nargin > 3)&& isnumeric(varargin{1}) ) || ...
        ( (nargin > 5) && isnumeric(varargin{1}) )    
    chunking = true;
end

% Optional parameter/value pairs
if (nargin > 3) && ischar(varargin{1})
    idx = 1;
    if rem(length(varargin),2)
        error('MATLAB:multibandwrite:badParamPair', ...
              'The property/value inputs must always occur as pairs.')
    end
elseif (nargin > 5) && isnumeric(varargin{1}) && ischar(varargin{3})
    idx = 3;
    if rem(length(varargin)-2,2)
        error('MATLAB:multibandwrite:badParamPair', ...
              'The property/value inputs must always occur as pairs.')
    end
end
params = {'fillvalue','precision','machfmt','offset'};
if ((nargin > 3) && ischar(varargin{1})) || ...
        ( (nargin > 5) && isnumeric(varargin{1}) && ischar(varargin{3}))
  for i=idx:2:(length(varargin))
    m = strmatch(lower(varargin{i}),params);
    switch length(m)
     case 1
      if m==1
        fillvalue = varargin{i+1};
        %Check FILLVALUE
        if ~((ndims(fillvalue)==2 && ...
              (size(fillvalue,1)==1 || size(fillvalue,2)==1) ))
              error('MATLAB:multibandwrite:badFillvalue', ...
                    'FILLVALUE must be a row or column vector of numbers no longer than the total number of bands.')
        end
      elseif m==2
        precision = varargin{i+1};
      elseif m==3
        machfmt = varargin{i+1};
      elseif m==4
        if any(varargin{i + 1} < 0) || ~isnumeric(varargin{i+1})
          error('MATLAB:multibandwrite:badOffset', ...
                'OFFSET must be number zero or greater.');
        end
        % Decimal zero is the ASCII null character
        offsetBuffer(1:varargin{i+1}) = 0;
      end
     case 0
      error('MATLAB:multibandwrite:badParamPair', ...
            'Unrecognized parameter name ''%s''.', params{i});
     otherwise % more than one match
      error('MATLAB:multibandwrite:badParamPair', ...
            'Ambiguous parameter name ''%s''.', params{i});
    end % switch
  end
end

% Permissions for opening the file. If file exists, but no offset or chunking,
% overwrite.  If file exists but there is an offset or the file is being
% written in chunks, don't overwrite.
if isempty(dir(filename))
  % File does not exist.
  exists = 0;
  permission = 'w';
elseif ~chunking && isempty(offsetBuffer)
  % File exists, but overwrite.
  exists = 1;
  permission = 'w';
else  
  % File exists, don't overwrite.
  exists = 1;
  permission = 'r+';
end

if chunking
  % Length of START should always be 3.  The other 2 cases are unexposed
  % possible future synaxes.  However, performance is gained by detecting
  % Case 1 and Case 2 and exectuting the faster code. Leave the switch
  % case so that expanding the syntax of MULTIBANDWRITE is easy.
  start = varargin{1};
  switch length(start)
   %case 1
   %  totalsize = [size(data,1) size(data,2) varargin{2}];
   %case 2
   % totalsize = [varargin{2}(1) varargin{2}(2) size(data,3)];
   case 3
    totalsize = varargin{2};
    if ~isequal(length(totalsize),3) || any(totalsize <= 0)
      error('MATLAB:multibandwrite:badTotalsize', ...
            'TOTALSIZE must be a 3 element vector of positive numbers specifying [totalrows,totalcolumns,totalbands].');
    end
    % Modify start to enhance performance to make use of Case 1 and Case 2.
    % Otherwise case 3 will always be used in the write***file functions.
    if (size(data,1) == totalsize(1)) && (size(data,2) == totalsize(2))
      % Case 1
      start = start(3);
    elseif size(data,3) == totalsize(3)
      % Case 2
      start = [start(1) start(2)];
    else
      % Case 3
      start = start;
    end
   otherwise
    error('MATLAB:multibandwrite:badStart', ...
          'START must be a 3 element vector of positive numbers specifying [firstrow firstcolumn firstband].');
  end
  if any(start<=0)
      error('MATLAB:multibandwrite:badStart', ...
            'START must be a 3 element vector of positive numbers specifying [firstrow firstcolumn firstband].');
  end

  % Check FILLVALUE
  if length(fillvalue)>totalsize(3)
    error('MATLAB:multibandwrite:badFillvalue', ...
          'FILLVALUE must be a row or column vector of numbers no longer than the total number of bands.')
  end
end

return;

% Possible future Syntaxes
%
%
%   CASE 1 Chunking data by 1-D band intervals. 
%
%      START == [firstB] is 1-by-1 and gives the index of the first band to
%      write.  DATA contains all of the pixels for some of the bands.
%      DATA(:,:,K) contains all of the pixel values for the (firstB + K -
%      1)-th band.
%    
%      TOTALSIZE == [totalNumBands] is 1-by-1 and gives the total number
%      of bands that will be written to the file.
%
%      The full three-dimensional size of the data in the file is
%      size(DATA,1)-by-size(DATA,2)-by-TOTALSIZE.
%
%   CASE 2 Chunking data by 2-D pixel boxes.  
%
%      START == [firstR firstC] is 1-by-2 and gives the image pixel location
%      of the upper left pixel in the box.  DATA contains some of the pixels
%      for all of the bands.  DATA(I,J,:) contains all of the bands for the
%      pixel at [firstR + I - 1, firstC + J - 1].
%
%      TOTALSIZE == [totalrows,totalcolumns] specifying the total number of
%      rows and total number of columns in each band. 
%
%      The full three-dimensional size of the data in the file is
%      TOTALSIZE(1)-by-TOTALSIZE(2)-by-size(DATA,3).
