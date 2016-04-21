function aviobj = close(aviobj)
%CLOSE Finish writing and close AVI file.   
%   AVIOBJ = CLOSE(AVIOBJ) finishes writing and closes the AVI file
%   associated with AVIOBJ, which is an AVIFILE object obtained from
%   AVIFILE.  
%
%   See also AVIFILE/AVIFILE, AVIFILE/ADDFRAME, and MOVIE2AVI.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:32 $

if ~isa(aviobj,'avifile')
  error('First input must be an AVIFILE object.');
end

error(nargoutchk(1,1,nargout));

if aviobj.MainHeader.TotalFrames == 0
  warning('There are no frames associated with this AVI. File may be invalid.');
end

ColormapSize = 0;
if aviobj.Bitmapheader.biBitCount == 8
  ColormapSize =size(aviobj.Bitmapheader.Colormap,1)* ...
      (size(aviobj.Bitmapheader.Colormap,2));
end

if isunix
  % If frames are 8-bit indexed images, add the colormap size to the strf
  % chunk, RIFF chunk, and strl LIST
  aviobj.Sizes.strfsize =aviobj.Sizes.strfsize + ...
      ColormapSize;
  aviobj.Sizes.riffsize = aviobj.Sizes.riffsize + ColormapSize ...
      +aviobj.Sizes.strnsize + rem(aviobj.Sizes.strnsize,2);
  aviobj.Sizes.hdrllist = aviobj.Sizes.hdrllist + ColormapSize ...
      +aviobj.Sizes.strnsize +  rem(aviobj.Sizes.strnsize,2);
  aviobj.Sizes.strllist = aviobj.Sizes.strllist + ColormapSize ...
      +aviobj.Sizes.strnsize +  rem(aviobj.Sizes.strnsize,2);

  fid = fopen(aviobj.Filename,'wb','l');
  if fid == -1
    error(['Unable to write to ' aviobj.Filename '.']);
  end
  
  % Write RIFF chunk
  WriteChunk('RIFF',aviobj.Sizes.riffsize,fid);

  % Write AVI fourcc
  count = fwriteWithCheck(fid,'AVI ','char');

  % Write hdrl LIST
  WriteList('hdrl',aviobj.Sizes.hdrllist - 8,fid);
  
  % Write avih chunk
  WriteChunk('avih',aviobj.Sizes.avihsize -8,fid);

  % Write main avi header
  WriteAVIH(fid, aviobj.MainHeader);

  % Write strl LIST
  WriteList('strl',aviobj.Sizes.strllist -8,fid);
  
  % Write strh chunk
  WriteChunk('strh',aviobj.Sizes.strhsize-8,fid);
  
  % Write stream header
  WriteSTRH(fid,aviobj.StreamHeader);

  % Write strf chunk
  WriteChunk('strf',aviobj.Sizes.strfsize-8,fid);

  % Write Bitmapheader
  WriteBMPHeader(fid,aviobj.Bitmapheader);

  % Write colormap 
  if aviobj.Bitmapheader.biBitCount == 8
      WriteColormap(fid,aviobj.Bitmapheader.Colormap);
  end

  % Write stream name chunk and data
  WriteChunk('strn',aviobj.Sizes.strnsize-8,fid);
  
  count = fwriteWithCheck(fid,aviobj.StreamName,'char');
  fwriteWithCheck(fid,0,'uchar');
  if ~rem(count,2)
    fwriteWithCheck(fid,0,'uchar');
  end

  % Write movi list
  WriteList('movi',aviobj.Sizes.movilist-8 ,fid);
  moviListLoc = ftell(fid);

  % Open temp data and copy to avi file
  TempDataFile = fopen(aviobj.TempDataFile,'r','l');
  if TempDataFile == -1
    error(['Unable to open temporary file' aviobj.TempDataFile '.']);
  end
  offsets = zeros(1,aviobj.MainHeader.TotalFrames);
  ChunkSizes =  zeros(1,aviobj.MainHeader.TotalFrames);
  for i = 1:aviobj.MainHeader.TotalFrames
    chunkid = fread(TempDataFile,4,'char');
    ChunkSizes(i) = fread(TempDataFile,1,'uint32'); 
    data = fread(TempDataFile,ChunkSizes(i),'*uint8');
    if aviobj.Compression == 0
      [offsets(i), pad]  = WriteUncompressedData(fid, aviobj, data);
    elseif aviobj.Compression == 1
      [offsets(i), pad] = WriteCompressedData(fid, aviobj, data);
    end
  end

  % Write the idx1 chunk and data
  WriteChunk('idx1',aviobj.Sizes.idx1size-8,fid);

  if aviobj.Compression == 1
      idx1.ckid = '00dc';
  else
      idx1.ckid = '00db';
  end
  idx1.Flags = 0;
  for i = 1:aviobj.MainHeader.TotalFrames
    msg = 'Unable to write index chunk.';
    count = fwriteWithCheck(fid,idx1.ckid,'char',msg);
    count = fwriteWithCheck(fid,idx1.Flags,'uint32',msg);
    count = fwriteWithCheck(fid,offsets(i)-moviListLoc-7,'uint32',msg);
    count = fwriteWithCheck(fid,ChunkSizes(i),'uint32',msg);
  end

  fclose(TempDataFile);
  delete(aviobj.TempDataFile);
  fclose(fid);
else
  avi('close',aviobj.FileHandle);
end %End of UNIX specific code
aviobj.CurrentState = 'Closed';
return;


% ------------------------------------------------------------------------
% Subfunctions
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
function WriteAVIH(fid,mainavih)
% WRITE_AVIH 
%  Write the main avi header to the AVI file.  

msg = 'Unable to write main AVI header.';
count = fwriteWithCheck(fid,mainavih.Fps,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.MaxBytesPerSec,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Reserved,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Flags,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.TotalFrames,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.InitialFrames,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Streams,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.SuggestedBufferSize,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Width,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Height,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Scale,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Rate,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Start,'uint32',msg);
count = fwriteWithCheck(fid,mainavih.Length,'uint32',msg);
return;

% ------------------------------------------------------------------------
function WriteSTRH(fid,strh)
% WRITE_STRH
%  Write the stream header to the AVI file.

msg = 'Unable to write stream header,';
count  = fwriteWithCheck(fid,strh.fccType,'char',msg);
if strcmp(strh.fccHandler,'DIB ')
  count = fwriteWithCheck(fid,0,'uint32',msg);
else
  count = fwriteWithCheck(fid,strh.fccHandler,'char',msg);
end
count = fwriteWithCheck(fid,strh.Flags,'uint32',msg);
count = fwriteWithCheck(fid,strh.Reserved,'uint32',msg);
count = fwriteWithCheck(fid,strh.InitialFrames,'uint32',msg);
count = fwriteWithCheck(fid,strh.Scale,'uint32',msg);
count = fwriteWithCheck(fid,strh.Rate,'uint32',msg);
count = fwriteWithCheck(fid,strh.Start,'uint32',msg);
count = fwriteWithCheck(fid,strh.Length,'uint32',msg);
count = fwriteWithCheck(fid,strh.SuggestedBufferSize,'uint32',msg);
count = fwriteWithCheck(fid,strh.Quality,'uint32',msg);
count = fwriteWithCheck(fid,strh.SampleSize,'uint32',msg);
return;

% ------------------------------------------------------------------------
function WriteBMPHeader(fid,bmph)
% WRITE_BMPHEADER
%  Write the bitmap header to the AVI file.

msg = 'Unable to write bitmap header';
count = fwriteWithCheck(fid,bmph.biSize,'uint32',msg);
count = fwriteWithCheck(fid,bmph.biWidth,'int32',msg);
count = fwriteWithCheck(fid,bmph.biHeight,'int32',msg);
count = fwriteWithCheck(fid,bmph.biPlanes ,'uint16',msg);
count = fwriteWithCheck(fid,bmph.biBitCount,'uint16',msg);
if strcmp(bmph.biCompression,'DIB ')
  fourcc = 0;
else
  fourcc = makeFourcc(bmph.biCompression);
end
count = fwriteWithCheck(fid,fourcc,'int32',msg);
count = fwriteWithCheck(fid,bmph.biSizeImage,'int32',msg);
count = fwriteWithCheck(fid,bmph.biXPelsPerMeter,'int32',msg);
count = fwriteWithCheck(fid,bmph.biYPelsPerMeter,'int32',msg);
count = fwriteWithCheck(fid,bmph.biClrUsed,'int32',msg);
count = fwriteWithCheck(fid,bmph.biClrImportant,'int32',msg);
return

% ------------------------------------------------------------------------
function WriteChunk(chunktype,chunksize,fid)
% WRITECHUNK 
%  Write a chunk to an AVI file.  A chunk consists of a 4 character chunk ID
%  and a 32 bit chunk size.  This does not write the acutal chunk data.

msg = 'Unable to write chunk information';
count = fwriteWithCheck(fid,chunktype,'char',msg);
count = fwriteWithCheck(fid,chunksize,'uint32',msg);
return;


% ------------------------------------------------------------------------
function WriteList(listtype,listsize,fid);
% WRITELIST 
%  Write a LIST to an AVI file.  A LIST contains the following information.
%        
%       'LIST'     4 bytes
%       size      4 bytes (32 bit integer)
%       'ckid'    4 bytes

msg = sprintf('Unable to write %s list.',listtype);
count = fwriteWithCheck(fid,'LIST','char',msg);
count = fwriteWithCheck(fid,listsize,'uint32',msg);
count = fwriteWithCheck(fid,listtype,'char',msg);
return;

% ------------------------------------------------------------------------
function [count] = WriteBMP(X,fid)
% WRITEBMP%   Write an uncompressed bitmap X to the AVI file.
msg = 'Unable to write bitmap data to AVI file.';
count = fwriteWithCheck(fid,X,'uint8',msg);
return;

% ------------------------------------------------------------------------
function WriteColormap(fid,map)
%  WRITE_COLORMAP 
%    Write the colormap to the AVI file.  
msg = 'Unable to write Colormap to AVI file.';
fwriteWithCheck(fid,map(:),'uint8',msg);
return;

% ------------------------------------------------------------------------
function [offset, count] = WriteUncompressedData(fid,aviobj,data) 
% 
%   Write an uncompressed bitmap to the AVI file.  OFFSET is the position in
%   the AVI of the start of the frame.  This is needed for the idx1 chunk.
%   COUNT is the number of bytes successfully written.

if aviobj.Bitmapheader.biBitCount == 8
  dims = 1;
elseif aviobj.Bitmapheader.biBitCount == 24
  dims = 3;
end

% Compute memory requirements for frame storage
NumFrameElements = prod(size(data));

count = fwriteWithCheck(fid,'00db','char');
count = fwriteWithCheck(fid,NumFrameElements,'uint32');

% Remember and return the offset for idx1 chunk information
offset = ftell(fid); 
[count] = WriteBMP(data,fid);
% If data size is odd, write a pad byte
pad = rem(count,2);
if pad
  count = fwriteWithCheck(fid,0,'uint8');
end
return;

% ------------------------------------------------------------------------
function [offset, pad] =  WriteCompressedData(fid,aviobj,data) 
% 
%   Write a compressed bitmap to the AVI file. OFFSET is the position in
%   the AVI of the start of the frame.  This is needed for the idx1 chunk.
%   PAD is 1 if the data size is odd, 0 otherwise.

count = fwriteWithCheck(fid,'00dc','char');
count = fwriteWithCheck(fid,length(data),'uint32');
offset = ftell(fid); % Remember for idx1 chunk information
count = fwriteWithCheck(fid,data,'uint8');
% If data size is odd, write a pad byte
pad = rem(count,2);
if pad
  fwriteWithCheck(fid,0,'uint8');
end
return;

% ------------------------------------------------------------------------
function fourcc = MakeFourcc(code)
% Make a four character code out of four characters
% This is documented in the MSDN for the mmioFOURCC routine.
code = double(code);
fourcc = bitor( bitor( bitor(code(1),bitshift(code(2),8)) , ...
			  bitshift(code(3),16)),bitshift(code(4),24));
% ------------------------------------------------------------------------
function count = fwriteWithCheck(fid,data, precision,msg)
count = fwrite(fid,data,precision);
if count ~= prod(size(data))
  if isempty(msg)
    error(['Error writing data to ' fopen(fid) '.']);
  else
    error(msg);
  end
end
return





