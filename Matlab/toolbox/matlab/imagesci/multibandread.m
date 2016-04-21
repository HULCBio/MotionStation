function im = multibandread(filename,dataSize,precision,...
                            offset,interleave,byteOrder,varargin)
%MULTIBANDREAD  Read band interleaved data from a binary file
%   X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,
%                    OFFSET,INTERLEAVE,BYTEORDER) 
%   reads band-sequential (BSQ), band-interleaved-by-line (BIL), or
%   band-interleaved-by-pixel (BIP) data from a binary file, FILENAME.  X is
%   a 2-D array if only one band is read, otherwise it is 3-D. X is returned
%   as an array of data type double by default.  Use the PRECISION argument
%   to map the data to a different data type.
%
%   X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,OFFSET,INTERLEAVE,
%                    BYTEORDER,SUBSET,SUBSET,SUBSET)
%   reads a subset of the data in the file. Up to 3 SUBSET parameters may be
%   used to subset independently along the Row, Column, and Band dimensions.
%
%   Parameters:
%
%     FILENAME: A string containing the name of the file to be read.
%
%     SIZE: A 3 element vector of integers consisting of
%     [HEIGHT, WIDTH, N]. HEIGHT is the total number of rows, WIDTH is
%     the total number of elements in each row, and N is the total number
%     of bands. This will be the dimensions of the data if it read in its
%     entirety.
%
%     PRECISION: A string to specify the format of the data to be read. For
%     example, 'uint8', 'double', 'integer*4'. By default X is returned as
%     an array of class double. Use the PRECISION parameter to format the
%     data to a different class.  For example, a precision of 'uint8=>uint8'
%     (or '*uint8') will return the data as a UINT8 array.  'uint8=>single'
%     will read each 8 bit pixel and store it in MATLAB in single
%     precision. See the help for FREAD for a more complete description of
%     PRECISION.
%
%     OFFSET: The zero-based location of the first data element in the file.
%     This value represents number of bytes from the beginning of the file
%     to where the data begins.
%
%     INTERLEAVE: The format in which the data is stored.  This can be
%     either 'bsq','bil', or 'bip' for Band-Seqential,
%     Band-Interleaved-by-Line or Band-Interleaved-by-Pixel respectively.
%
%     BYTEORDER: The byte ordering (machine format) in which the data is
%     stored. This can be 'ieee-le' for little-endian or ieee-be' for
%     big-endian.  All other machine formats described in the help for FOPEN
%     are also valid values for BYTEORDER.
%
%     SUBSET: (optional) A cell array containing either {DIM,INDEX} or
%     {DIM,METHOD,INDEX}. DIM is one of three strings: 'Column', 'Row', or
%     'Band' specifying which dimension to subset along.  METHOD is 'Direct'
%     or 'Range'. If METHOD is omitted, then the default is 'Direct'. If
%     using 'Direct' subsetting, INDEX is a vector specifying the indices to
%     read along the Band dimension.  If METHOD is 'Range', INDEX is a 2 or
%     3 element vector of [START, INCREMENT, STOP] specifying the range and
%     step size to read along the dimension. If INDEX is 2 elements, then
%     INCREMENT is assumed to be one.
%
%   Examples
%   --------
%
%   Read all the data into a 864-by-702-by-3 uint8 matrix
%          im = multibandread('bipdata.img',...
%                            [864,702,3],'uint8=>uint8',0,'bip','ieee-le');
%
%   Read all rows and columns but only bands 3, 4, and 6
%          im = multibandread('bsqdata.img',...
%                            [512,512,6],'uint8',0,'bsq','ieee-le',...
%                            {'Band','Direct',[3 4 6]});
%
%   Read all bands and subset along the rows and columns
%          im = multibandread('bildata.int',...
%                            [350,400,50],'uint16',0,'bil','ieee-le',...
%                            {'Row','Range',[2 2 350]},...
%                            {'Column','Range',[1 4 350]});
%
%   See also FREAD, FOPEN. 
%

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:01 $
%   $Revision.1 $  $Date: 2004/02/01 22:04:01 $

error(nargchk(6,9,nargin, 'struct'))
error(nargchk(0,4,nargout, 'struct'));

%Parse inputs 
info = parseInputs(filename,dataSize,precision,...
                   offset,byteOrder,...
                   varargin{:});

%File existance has been already tested.
info.fid = fopen(filename,'r',info.byteOrder);

switch lower(interleave)
 case 'bil'
  im = readbildata(info);
 case 'bsq'
  im = readbsqdata(info);
 case 'bip'
  im = readbipdata(info);
 otherwise
  error('MATLAB:multibandread:badInterleave', ...
        'INTERLEAVE must be ''bsq'', ''bil'', or ''bip''.');
end

%Close file
fclose(info.fid);

%==============================================================================
function im = readbipdata(info)
% READBIPDATA Read Band Interleaved by Pixel data

%Preallocate image output array 
im(length(info.rowIndex), ...
   length(info.colIndex), ...
   length(info.bandIndex)) = feval(info.outputClass,0);

if isempty(info.subset) || isequal(info.subset,'b') 
  % No subsetting or subsetting along band dimension only
  plane = 1;
  for i=info.bandIndex
    skip(info,info.offset,(i-1)*info.eltsize);
    [data,count] = fread(info.fid,info.height*info.width,...
                         ['1*' info.precision],...
                         (info.nbandsTotal-1)*info.eltsize);
    if count~=info.height*info.width;
      readError(info.fid);
    end
    im(:,:,plane) = reshape(data,size(im(:,:,plane)));
    plane = plane + 1;
  end
  im = permute(im,[2 1 3]);
elseif  (length(info.subset)==2 && ...
         ~isempty(findstr('r',info.subset)) && ...
         ~isempty(findstr('c',info.subset)))
  % Subset along both row and column dimensions only
  
  % Use meshgrid to get x,y coordinates of each pixel to "drill through".
  % This is the cartesian cross product
  [x,y] = meshgrid(info.rowIndex,info.colIndex);
  
  % The [x(:),y(:)] subscripted indices are describing the location of the
  % pixel in MATLAB (column major).  Therefore, use y(:),x(:) because data
  % in file is stored in row major order. 
  directIndex = sub2ind([info.width, info.height],y(:),x(:));
  
  for i=1:length(directIndex)
    [r,c] = ind2sub([size(im,1) size(im,2)],i);
    skip(info,info.offset,(directIndex(i)-1)*info.nbandsTotal*info.eltsize);
    [im(r,c,:) count] = fread(info.fid,info.nbandsTotal,info.precision);
    if count~=info.nbandsTotal
      readError(info.fid);
    end
  end
elseif isequal(info.subset,'r')
  b = 1;
  for i=info.bandIndex
    pos = (i-1)*info.eltsize;
    r = 1;
    for j=info.rowIndex
      skip(info,info.offset,pos+(j-1)*info.width*info.nbandsTotal*info.eltsize);
      [data,count] = fread(info.fid,info.width,['1*' info.precision],...
                           (info.nbandsTotal-1)*info.eltsize);
      if count~=info.width
        readError(info.fid);
      end
      im(r,:,b) = reshape(data,size(im(j,:,i)));
      r = r + 1;
    end
    b = b + 1;
  end
elseif length(info.subset) > 1 || isequal(info.subset,'c')
  b = 1;
  for i=info.bandIndex
    pos = (i-1)*info.eltsize;
    r = 1;
    for j=info.rowIndex
      pos = pos + (j-1)*info.width*info.nbandsTotal*info.eltsize;
      c = 1;
      for k =info.colIndex
        skip(info,info.offset,pos+(k-1)*info.nbandsTotal*info.eltsize);
        [im(r,c,b),count] = fread(info.fid,1,info.precision);
        if count~=1
          readError(info.fid);
        end
        c = c + 1;
      end
      r = r + 1;
    end
    b = b + 1;
  end
end
%===================================================================================
function im = readbildata(info)
%READBILDATA Read Band Interleaved by Line data

%Preallocate image output array
im(length(info.rowIndex), ...
   length(info.colIndex), ...
   length(info.bandIndex)) = feval(info.outputClass,0);

plane = 1;
if isempty(info.subset) || isequal(info.subset,'b')
  for i=info.bandIndex
    skip(info,info.offset,(i-1)*info.width*info.eltsize);
    [data,count] = fread(info.fid,info.width*info.height,...
                         [num2str(info.width) '*' info.precision],...
                         info.width*(info.nbandsTotal-1)*info.eltsize);
    if count~=info.height*info.width;
      readError(info.fid);
    end
    im(:,:,plane) = reshape(data, size(im(:,:,plane)));
    plane = plane+1;
  end
  im = permute(im,[2 1 3]);
elseif isequal(info.subset,'r')
  r = 1;
  for i=info.rowIndex
    skip(info,info.offset,(i-1)*info.width*info.nbandsTotal*info.eltsize);
   [data,count] = fread(info.fid,info.width*info.nbandsTotal, info.precision);
   if count~=info.width*info.nbandsTotal
     readError(info.fid);
   end
   im(r,:,:) = reshape(data,size(im(r,:,:)));
    r = r + 1;
  end
elseif length(info.subset) > 1 || isequal(info.subset,'c')
  b = 1;
  for i=info.bandIndex
    % Read one pixel at a time
    r = 1;
    for j=info.rowIndex
      % Go to beginning of band and to beginning of row 
      pos = ((i-1)+(j-1)*info.nbandsTotal)*(info.eltsize*info.width);
      c = 1;
      for k=info.colIndex
        % Seek to column to read
        skip(info,info.offset,pos+(k-1)*info.eltsize)
        [im(r,c,b),count] = fread(info.fid,1,info.precision);
        if count~=1
          readError(info.fid);
        end
        c = c + 1;
      end
      r = r + 1;
    end
    b = b + 1;
  end
end
return
%===================================================================================
function im = readbsqdata(info)
%READBSQDATA Read Band Sequential data

%Preallocate image output array
im(length(info.rowIndex), ...
   length(info.colIndex), ...
   length(info.bandIndex)) = feval(info.outputClass,0);

fseek(info.fid,info.offset,'bof');
 
plane = 1;
if isempty(info.subset)
  % Read all data
  [im,count] = fread(info.fid,info.width*info.height*info.nbandsTotal,info.precision);
  if count~=info.width*info.height*info.nbandsTotal
    readError(info.fid);
  end
  im = reshape(im,info.width,info.height,info.nbandsToRead);
  im = permute(im,[2 1 3]);
elseif isequal(info.subset,'b')
  % Subseting only along band dimension
  for i=info.bandIndex
    skip(info,info.offset,(i-1)*info.height*info.width*info.eltsize);
    [data,count] = fread(info.fid,info.height*info.width,info.precision);
    if count~=info.height*info.width
      readError(info.fid);
    end
    im(:,:,plane) = reshape(data,size(im(:,:,plane)));
    plane = plane+1;    
  end
  im = permute(im,[2 1 3]);
elseif isequal(info.subset,'r')
  % Subset only along row dimension
  r = 1;
  for i=info.rowIndex
    skip(info,info.offset,(i-1)*info.width*info.eltsize);
    % no permute needed
    [data,count] = fread(info.fid,info.width*info.nbandsTotal,...
                         [num2str(info.width) '*' info.precision],...
                         (info.height-1)*info.width*info.eltsize);
    if count~=info.width*info.nbandsTotal
      readError(info.fid);
    end
    im(r,:,:) = reshape(data,size(im(r,:,:)));
    r = r + 1;
  end
elseif isequal(info.subset,'c')
  % Subset only along column dimension
  c = 1;
  for i=info.colIndex
    skip(info,info.offset,(i-1)*info.eltsize);
    % no permute needed
    [data,count] = fread(info.fid,info.height*info.nbandsTotal,...
                         ['1*' info.precision],(info.width-1)*info.eltsize);
    if count~=info.height*info.nbandsTotal
      readError(info.fid);
    end
    im(:,c,:) = reshape(data,size(im(:,c,:)));
    c = c + 1;
  end
elseif length(info.subset) > 1
    
    %Subsetting along more than one dimension
    for i = 1:length(info.bandIndex)
        
        for j = 1:length(info.rowIndex)
            
            pos = (info.bandIndex(i) - 1) * info.height * info.width * ...
                  info.eltsize + (info.rowIndex(j) -1) * info.width * ...
                  info.eltsize;
            
            for k = 1:length(info.colIndex)

                skip(info, ...
                     info.offset, ...
                     pos + (info.colIndex(k) - 1) * info.eltsize);

                [im(j, k, i), count] = fread(info.fid, 1, info.precision);

                if (count ~= 1)
                    readError(info.fid);
                end
                
            end
            
        end
        
    end
end


%===================================================================================
function info =  parseInputs(filename,...
                             size,...
                             precision, ...
                             offset,...
                             byteOrder,...
                             varargin)

% Open file. Determine pixel width and output class
fid = fopen(filename,'r',byteOrder);
if fid == -1
  error('MATLAB:multibandread:fileOpen', ...
        'Unable to open %s for reading.',filename);
end
[info.eltsize, info.outputClass] = getPixelInfo(fid,precision);
fclose(fid);

if length(size) == 3
  info.height      = size(1);
  info.width       = size(2);
  info.nbandsTotal = size(3);
else
  error('MATLAB:multibandread:badSize', ...
        'SIZE must be a 3 element vector of integers containing [HEIGHT, WIDTH, N]');
end

info.offset       = offset;
info.byteOrder    = byteOrder;
% Fix if shortcut notation was used for precision
info.precision = fixPrecisionString(precision);
if isempty(strfind(precision,'bit'))
  info.bitPrecision = 0;
else
  info.bitPrecision = 1;
end

if ~isnumeric(offset) || (offset < 0)
  error('MATLAB:multibandread:badOffset', ...
        'OFFSET must be a number greater than zero.')
end

% 'subset' is a string with 0-3 characters (r, c, b). The string
% represents which dimension is being subset
info.subset = '';
info.rowIndex = 1:info.width;
info.colIndex = 1:info.height;
info.bandIndex= 1:info.nbandsTotal;

methods    = {'direct', 'range'};
dimensions = {'row', 'column', 'band'};
if numel(varargin) > 0
  for i=1:length(varargin)
    if length(varargin{i})==2
      %Default to 'Direct'
      method = 'direct';
      n = 2;
    else
      match = strmatch(lower(varargin{i}{2}),methods);
      if ~isempty(match)
        method = methods{match};
      else
        error('MATLAB:multibandread:badSubset', ...
              'Unrecogized subset string ''%s'' for METHOD.',varargin{i}{2});
      end
      n = 3;
    end
    match = strmatch(lower(varargin{i}{1}),dimensions);
    if ~isempty(match)
      dim = dimensions{match};
    else
      error('MATLAB:multibandread:badSubset', ...
            'Unrecogized subset string ''%s'' for DIM.',varargin{i}{1});
    end
    info.subset(i) = dimensions{match}(1); %build a string 'rcb'
    switch dim
     case 'row'
      if strcmp(method,'direct')
        info.rowIndex = varargin{i}{n};
      else
        switch length(varargin{i}{n})
         case 2
          info.rowIndex = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2));
         case 3
          info.rowIndex = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2),varargin{i}{n}(3));
         otherwise
          error('MATLAB:multibandread:badSubset', ...
                'Value for ''Range'' in the SUBSET parameter must be a 2 or 3 element vector.')
        end
      end
     case 'column'
      if strcmp(method,'direct')
        info.colIndex = varargin{i}{n};
      else
        switch length(varargin{i}{n})
         case 2
          info.colIndex = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2));
         case 3
          info.colIndex = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2),varargin{i}{n}(3));
         otherwise
          error('MATLAB:multibandread:badSubset', ...
                'Value for ''Range'' in the SUBSET parameter must be a 2 or 3 element vector')
        end
      end
     case 'band'
      if strcmp(method,'direct')
        info.bandIndex = varargin{i}{n};
      else
        switch length(varargin{i}{n})
         case 2
          info.bandIndex = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2));
         case 3
          info.bandIndex = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2),varargin{i}{n}(3));
         otherwise
          error('MATLAB:multibandread:badSubset', ...
                'Value for ''Range'' in the  SUBSET parameter must be a 2 or 3 element vector')
        end
      end
    end
  end
end
info.nbandsToRead = length(info.bandIndex); 
return;

%=============================================================================
function s = fixPrecisionString(p)
p = p(~isspace(p));
s=p;
if strcmp(p(1),'*')
  p(1) = [];
  s = [p '=>' p];
end


%=============================================================================
function [w,outputClass] = getPixelInfo(fid,precision)
% Returns width of each pixel.  Width is in bytes unless precision is 
% ubitN or bitN in which case width is in bits.  
% FTELL does not return correct values for bit precisions

p = ftell(fid);
tmp = fread(fid, 1, precision);
w = ftell(fid)-p;
outputClass = class(tmp);

% If it is a bit precision, parse the precision string to determine w.
if ~isempty(strfind(precision,'bit'))
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
    error('MATLAB:multibandread:badPrecision', ...
          'Unrecognized PRECISION, ''%s''.',precision);
  end
end
return;

%==============================================================================
function skip(info,offset,skipSize)
% Seek to a position in the file.
% If precision is a bit precision then skipSize is in bits. offset is
% always in bytes.
% SKIP always seeks from the beginning of the file.
if info.bitPrecision
  frewind(info.fid);
  fseek(info.fid,offset,'bof');
  fread(info.fid,skipSize/info.eltsize,info.precision);
else
  fseek(info.fid,offset+skipSize,'bof');
end

%==============================================================================
function readError(fid)
if feof(fid)
  fclose(fid);
  error('MATLAB:multibandread:unexpectedEOF', ...
        'Error reading data.  End of file reached unexpectedly.');
else
  fclose(fid);
  error('MATLAB:multibandread:readProblem', ...
        'Error reading data. Unknown error.');
end
return;
