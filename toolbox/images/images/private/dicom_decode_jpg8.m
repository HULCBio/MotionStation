function pixel_cells = dicom_decode_jpg8(comp_fragment)
%DICOM_DECODE_JPG8  Decode a JPEG compressed bytestream.
%   PIXEL_CELLS = DICOM_DECODE_JPG8(COMP_FRAGMENT) decompresses the 8-bit
%   to 16-bit lossy or lossless JPEG compressed fragment COMP_FRAGMENT and
%   returns the decompressed PIXEL_CELLS.  PIXEL_CELLS is an m-by-n
%   rectangular array of image data returned by IMREAD and contains a
%   complete, correctly shaped and oriented image.
%
%   PIXEL_CELLS is a UINT8 array is the JPEG file contains 8 or fewer bytes
%   per sample.  Otherwise PIXEL_CELLS is a UINT16 array.  PIXEL_CELLS will
%   need to be cast to a signed type if the DICOM file's Pixel Representation
%   is 1.
%
%   See also: IMREAD, IMFINFO.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:10:31 $

% Open a temporary file for the JPEG data.
tmp_file = tempname;
fid = fopen(tmp_file, 'w');

if (fid < 3)
    eid = sprintf('Images:%s:CouldNotOpenFile',mfilename); 
    error(eid,'Couldn''t open temporary file (%s) for writing.', tmp_file)
end

% Write the JPEG bytestream to the file.
count = fwrite(fid, comp_fragment, 'uint8');

if (count ~= length(comp_fragment))
    wid = sprintf('Images:%s:dataTruncatedWhenWritingToTempFile',mfilename);
    warning(wid,'%s','Data was truncated when writing to temporary file.')
end

% Close the temporary file.
fclose(fid);

% Reread the file.
try
    pixel_cells = imread(tmp_file, 'jpeg');
catch
    delete(tmp_file);
    [lastmsg,lastid] = lasterr;
    error(lastid,'%s',lastmsg)
end

% Remove the temporary file.
try
    delete(tmp_file);
catch
    wid = sprintf('Images:%s:CouldNotDeleteTempFile',mfilename);
    warning(wid,'Couldn''t delete temporary file (%s).', tmp_file)
end
