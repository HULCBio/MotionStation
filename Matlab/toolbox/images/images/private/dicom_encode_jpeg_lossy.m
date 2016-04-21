function [fragments, frames] = dicom_encode_jpeg_lossy(X)
%DICOM_ENCODE_JPEG_LOSSY   Encode pixel cells using lossy JPEG compression.
%   [FRAGMENTS, LIST] = DICOM_ENCODE_JPEG_LOSSY(X) compresses and encodes
%   the image X using baseline lossy JPEG compression.  FRAGMENTS is a
%   cell array containing the encoded frames (as UINT8 data) from the
%   compressor.  LIST is a vector of indices to the first fragment of
%   each compressed frame of a multiframe image.
%
%   See also DICOM_ENCODE_RLE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/01/26 05:58:29 $


% Use IMWRITE to create a JPEG image.
tempfile = tempname;
imwrite(X, tempfile, 'jpeg');

% Read the image from the temporary file.
fid = fopen(tempfile, 'r');
fragments{1} = fread(fid, inf, 'uint8=>uint8');
fclose(fid);

frames = 1;

% Remove the temporary file.
try
    delete(tempfile)
catch
    dicom_warn(sprintf('Unable to delete temporary file "%s".', tempfile))
end
