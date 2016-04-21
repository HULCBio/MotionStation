function [info,msg] = impcxinfo(filename)
%IMPCXINFO Get information about the image in a PCX file.
%   [INFO,MSG] = IMPCXINFO(FILENAME) returns information about
%   the image contained in a PCX file.  If the attempt fails for
%   some reason (e.g. the file does not exist or is not a PCX
%   file), then INFO is empty and MSG is a string containing a
%   diagnostic message.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:31 $

% This function should not call error.

msg = '';
info = [];

if (~ischar(filename))
    msg = 'FILENAME must be a string';
    return;
end

[fid,m] = fopen(filename, 'r', 'ieee-le');
if (fid == -1)
    info = [];
    msg = m;
    return;
else
    filename = fopen(fid);
    d = dir(filename);
end

% Fix the order of the standard fields
info.Filename = filename;
info.FileModDate = d.date;
info.FileSize = d.bytes;
info.Format = 'pcx';
info.FormatVersion = [];
info.Width = [];
info.Height = [];
info.BitDepth = [];
info.ColorType = [];
info.FormatSignature = [];

if (fseek(fid, 128, 'bof') ~= 0)
    info = [];
    msg = 'Not a PCX file';
    fclose(fid);
    return;
end

fseek(fid, 0, 'bof');

info.FormatSignature = fread(fid, 2, 'uint8');
if (info.FormatSignature(1) ~= 10)
    info = [];
    msg = 'Not a PCX file';
    fclose(fid);
    return;
end
info.FormatVersion = info.FormatSignature(2);
if (~ismember(info.FormatVersion, [0 2 3 4 5]))
    info = [];
    msg = 'Unrecognized or unsupported PCX format version';
    fclose(fid);
    return;
end

encoding = fread(fid, 1, 'uint8');
if (encoding == 1)
    info.Encoding = 'RLE';
else
    info.Encoding = 'unknown';
end

info.BitsPerPixelPerPlane = fread(fid, 1, 'uint8');
info.XStart = fread(fid, 1, 'uint16');
info.YStart = fread(fid, 1, 'uint16');
info.XEnd = fread(fid, 1, 'uint16');
info.YEnd = fread(fid, 1, 'uint16');
info.HorzResolution = fread(fid, 1, 'uint16');
info.VertResolution = fread(fid, 1, 'uint16');
info.EGAPalette = fread(fid, 48, 'uint8');
info.Reserved1 = fread(fid, 1, 'uint8');
info.NumColorPlanes = fread(fid, 1, 'uint8');
info.BytesPerLine = fread(fid, 1, 'uint16');
info.PaletteType = fread(fid, 1, 'uint16');
info.HorzScreenSize = fread(fid, 1, 'uint16');
info.VertScreenSize = fread(fid, 1, 'uint16');

info.Width = info.XEnd - info.XStart + 1;
info.Height = info.YEnd - info.YStart + 1;
info.BitDepth = info.NumColorPlanes * info.BitsPerPixelPerPlane;
if (info.BitDepth == 24)
    info.ColorType = 'truecolor';

else
    % There might not be a colormap at the end of the file.  We
    % don't want to find out in this function because it requires
    % seeking to the end-of-file, which takes too much time for
    % big image files.   In fact, to be absolutely sure we would
    % have to decode the image.  But most PCX files that are
    % 8-bit or less are indexed.
    info.ColorType = 'indexed';
    
end


fclose(fid);
