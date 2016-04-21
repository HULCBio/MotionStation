function writexwd(M,CM,fname)
%WRITEXWD  Write a XWD (X window dump) file to disk.
%   WRITEXWD(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.

%   Drea Thomas, 7-20-93.
%   Revised Steven L. Eddins, June 1996.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:05:00 $

if ((ndims(M) == 3) && (size(M,3) == 3))
    error('MATLAB:writexwd:rgbNotSupported', ...
          'RGB output not supported for XWD files');
end
if (ndims(M) > 2)
    error('MATLAB:writexwd:imageMustBe2D', ...
          'Input array must be 2-D');
end

if (isempty(CM))
    error('MATLAB:writexwd:missingColormap', ...
          'Colormap not specified');
end

%open the file with big endian format
fid = fopen(fname,'w','b');
if fid == -1
  error('MATLAB:writexwd:fileOpen', ...
        ['Unable to open ''',fname,''' for writing.']);
end

[a,b] = size(M);
c = size(CM, 1);
header = [ 101+length(fname)  % Length of header
          7                   % file_version
          2                   % Image format 2 == ZPixmap
          8                   % Image depth
          b                   % Image width
          a                   % Image height
          0                   % Image x ofset
          1                   % MSB first (byte order)
          8                   % Bitmap unit
          1                   % MSB first (bit order)
          8                   % Bitmap scanline pad
          8                   % Bits per pixel
          b                   % Bytes per scanline
          3                   % Visual class (pseudocolor)
          0                   % Z red mask (not used)
          0                   % Z green mask (not used)
          0                   % Z blue mask (not used)
          8                   % Bits per logical pixel
          c                   % Length of colormap
          c                   % Number of colors
          b                   % Window width
          a                   % Window height
          0                   % Window upper left X coordinate
          0                   % Window upper left Y coordinate
          0 ];                % Window border width

fwrite(fid,header,'int32');
fwrite(fid,fname);
fwrite(fid,0);
fwrite(fid,[zeros(c,1) (0:(c-1))',CM*65535,zeros(c,1)]','uint16');
if (isa(M, 'uint8'))
  fwrite(fid,M','uint8');
  fclose(fid);
else
  fwrite(fid,M'-1);
  fclose(fid);
end
