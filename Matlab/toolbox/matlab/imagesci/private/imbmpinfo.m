function [info,msg] = imbmpinfo(filename)
%IMBMPINFO Get information about the image in a BMP file.
%   [INFO,MSG] = IMBMPINFO(FILENAME) returns information about
%   the image contained in a BMP file.  If the attempt fails for
%   some reason (e.g. the file does not exist or is not a BMP
%   file), then INFO is empty and MSG is a string containing a
%   diagnostic message.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:23 $

%   Required reading before editing this file: Encyclopedia of
%   Graphics File Formats, 2nd ed., pp. 572-591, pp. 630-650.

% This function should not call error()!  -SLE

if (~ischar(filename))
    msg = 'FILENAME must be a string';
    return;
end

[fid,m] = fopen(filename, 'r', 'ieee-le');  % BMP files are little-endian
if (fid == -1)
    info = [];
    msg = m;
    return;
end

info = initializeInfoStruct(fid);


% Determine how to read the bitmap.
info.FormatSignature = getSignature(fid);

if (isempty(info.FormatSignature))
    info = [];
    msg = 'Empty file';
    fclose(fid);
    return;
end

[bmpVersion, msg] = getVersion(fid, info.FormatSignature);

if (~isempty(msg))
    info = [];
    fclose(fid);
    return
end


% Read the bitmap's info.
[info, msg] = readBMPInfo(fid, bmpVersion, info);

if (~isempty(msg))
    info = [];
    fclose(fid);
    return
end


% Clean up and do post-processing.
fclose(fid);
[info, msg] = postProcess(info);



function info = initializeInfoStruct(fid)
%INITIALIZEINFOSTRUCT  Create and initialize the info struct, fixing fields.

filename = fopen(fid);  % Get the full path name if not in pwd
d = dir(filename);      % Read directory information

%
% Initialize universal structure fields to fix the order
%
info.Filename = filename;
info.FileModDate = d.date;
info.FileSize = d.bytes;
info.Format = 'bmp';
info.FormatVersion = [];
info.Width = [];
info.Height = [];
info.BitDepth = [];
info.ColorType = [];
info.FormatSignature = [];

%
% Initialize BMP-specific structure fields to fix the order
%
info.NumColormapEntries = [];
info.Colormap = [];
info.RedMask = [];
info.GreenMask = [];
info.BlueMask = [];



function signature = getSignature(fid)
%GETSIGNATURE  Get the file's format signature.
  
fseek(fid, 0, 'bof');
signature = char(fread(fid, 2, 'uint8')');



function [bmpVersion, msg] = getVersion(fid, FormatSignature)
%GETVERSION  Determine the version of the BMP file.
  
%
% Use the algorithm from Encyclopedia of Graphics File Formats,
% 2ed, pp. 584-585
%

msg = '';

switch FormatSignature
case 'BM'
  
    % We have a single-image BMP file. It may be 
    % a Windows or an OS/2 file.

    fseek(fid, 14, 'bof');
    headersize = fread(fid, 1, 'uint32');

    if (isempty(headersize))
        bmpVersion = '';
        msg = 'Truncated header';
        return;
    end

    switch headersize
    case 12
        bmpVersion = 'win 2';
        
    case 40
        bmpVersion = 'win 3';
        
    case 108
        bmpVersion = 'win 4';
        
    case 124
        bmpVersion = 'win 5';
        
    otherwise
        
        if ((headersize > 12) && (headersize <= 64))
            bmpVersion = 'OS2 2';
        else
            bmpVersion = '';
            msg = 'Corrupted header';
        end
        
    end
    
case 'BA'

    bmpVersion = '';
    msg = 'Unsupported format; may be an OS/2 bitmap array';
    
otherwise

    bmpVersion = '';
    msg = 'Not a BMP file';
    
end



function [info, msg] = readBMPInfo(fid, bmpVersion, info)
%READBMPINFO  Read the metadata from the bitmap headers.
  
fseek(fid, 0, 'bof');

switch bmpVersion
case 'win 2'
    [info, msg] = readWin2xInfo(fid, info);
    
case 'win 3'
    [info, msg] = readWin3xInfo(fid, info);
        
case 'win 4'
    [info, msg] = readWin4xInfo(fid, info);
    
case 'win 5'
    [info, msg] = readWin5xInfo(fid, info);
   
case 'OS2 2'
    [info, msg] = readOS2v2Info(fid, info);
 
otherwise
    msg = 'Problem identifying format version';
    
end



function info = readBMPFileHeader(fid, info)
%READBMPFILEHEADER  Read the BMPFileHeader structure.
  
fseek(fid, 2, 'cof');  % FileType (usually 'BM')
info.FileSize = fread(fid, 1, 'uint32');
fseek(fid, 4, 'cof');  % skip 2 reserved 16-bit words
info.ImageDataOffset = fread(fid, 1, 'uint32');



function [info, msg] = readWin2xBitmapHeader(fid, info)
%READWIN2XBITMAPHEADER  Read the Win2xBitmapHeader structure.
  
msg = '';

% Version 2.x headers have UINT16-sized height and width.
info.BitmapHeaderSize = fread(fid, 1, 'uint32');
info.Width = fread(fid, 1, 'uint16');
info.Height = fread(fid, 1, 'uint16');
info.NumPlanes = fread(fid, 1, 'uint16');
info.BitDepth = fread(fid, 1, 'uint16');

if (isempty(info.Width) || isempty(info.Height))
  msg = 'Truncated header';
end

        

function [info, msg] = readWin3xBitmapHeader(fid, info)
%READWIN3XBITMAPHEADER  Read the Win3xBitmapHeader structure.

% Version 3.x and later headers have UINT32-sized height and width.
info.BitmapHeaderSize = fread(fid, 1, 'uint32');
info.Width = fread(fid, 1, 'int32');
info.Height = fread(fid, 1, 'int32');
info.NumPlanes = fread(fid, 1, 'uint16');
info.BitDepth = fread(fid, 1, 'uint16');

if (isempty(info.Width) || isempty(info.Height))
    msg = 'Truncated header';
    return
end

% CompressionType will get decoded later after we really know
% what type of bitmap we have.  It's a chicken and an egg problem.
info.CompressionType = fread(fid, 1, 'uint32');
[info.CompressionType, msg] = decodeCompression(info.CompressionType, ...
                                                   info.FormatVersion);

if (~isempty(msg))
    return
end

info.BitmapSize = fread(fid, 1, 'uint32');
info.HorzResolution = fread(fid, 1, 'int32');
info.VertResolution = fread(fid, 1, 'int32');
info.NumColorsUsed = fread(fid, 1, 'uint32');
info.NumImportantColors = fread(fid, 1, 'uint32');



function [info, msg] = readWin4xBitmapHeader(fid, info)
%READWIN4XBITMAPHEADER  Read the Win4xBitmapHeader structure.

[info, msg] = readWin3xBitmapHeader(fid, info);

if (~isempty(msg))
    return
end

info.RedMask = fread(fid, 1, 'uint32');
info.GreenMask = fread(fid, 1, 'uint32');
info.BlueMask = fread(fid, 1,  'uint32');
info.AlphaMask = fread(fid, 1, 'uint32');
info.ColorspaceType = decodeColorspaceType(fread(fid, 1, 'uint32'));
info.RedX = fread(fid, 1, 'int32');
info.RedY = fread(fid, 1, 'int32');
info.RedZ = fread(fid, 1, 'int32');
info.GreenX = fread(fid, 1, 'int32');
info.GreenY = fread(fid, 1, 'int32');
info.GreenZ = fread(fid, 1, 'int32');
info.BlueX = fread(fid, 1, 'int32');
info.BlueY = fread(fid, 1, 'int32');
info.BlueZ = fread(fid, 1, 'int32');
info.GammaRed = fread(fid, 1, 'uint32');
info.GammaGreen = fread(fid, 1, 'uint32');
info.GammaBlue = fread(fid, 1, 'uint32');

if (isequal(info.CompressionType, 'bitfields'))
    info.NumColormapEntries = 0;
    info.Colormap = [];
end



function [info, msg] = readWin5xBitmapHeader(fid, info)
%READWIN5XBITMAPHEADER  Read the Win5xBitmapHeader structure.

[info, msg] = readWin4xBitmapHeader(fid, info);

if (~isempty(msg))
    return
end

info.Intent = decodeIntent(fread(fid, 1, 'uint32'));
info.ProfileDataOffset = fread(fid, 1, 'uint32');
info.ProfileSize = fread(fid, 1, 'uint32');

fseek(fid, 4, 'cof'); % skip 4-byte reserved DWORD.



function [compressionType, msg] = decodeCompression(compNum, verName)
%DECODECOMPRESSION  Find the compression type given the header value.
  
msg = '';

switch compNum
case 0
    compressionType = 'none';
            
case 1
    compressionType = '8-bit RLE';
            
case 2
    compressionType = '4-bit RLE';
            
case 3
    if (isequal(verName, 'Version 3'))
        compressionType = 'bitfields';
    else
        % OS/2 2.x
        compressionType = 'Huffman 1D';
    end
            
case 4
   % Only valid for OS/2 2.x
   compressionType = '24-bit RLE';
            
otherwise
   compressionType = '';
   msg = 'Unrecognized compression type';
   
end



function [info, msg] = readVersion2xColormap(fid, info)
%READVERSION2XCOLORMAP  Read colormap entries for version 2.x bitmaps.
  
info.NumColormapEntries = floor((info.ImageDataOffset - ftell(fid))/3);

if (info.NumColormapEntries > 0)
        
    [map,count] = fread(fid, info.NumColormapEntries*3, 'uint8');
    if (count ~= info.NumColormapEntries*3)
        msg = 'Truncated colormap data';
        return;
    else
        msg = '';
    end

    map = reshape(map, 3, info.NumColormapEntries);
    info.Colormap = double(flipud(map)')/255;

else
    
    msg = '';
    
end



function [info, msg] = readVersion3xColormap(fid, info)
%READVERSION3XCOLORMAP  Read colormap entries for version 3.x bitmaps.

info.NumColormapEntries = floor((info.ImageDataOffset - ftell(fid))/4);

if (info.NumColormapEntries > 0)

    [map,count] = fread(fid, info.NumColormapEntries*4, 'uint8');
    if (count ~= info.NumColormapEntries*4)
        msg = 'Truncated colormap data';
        return;
    else
        msg = '';
    end

    map = reshape(map, 4, info.NumColormapEntries);
    info.Colormap = double(flipud(map(1:3,:))')/255;

else
    
    msg = '';
    
end



function info = readVersion3xMasks(fid, info)
%READVERSION3XMASKS  Read color masks for version 3 (NT) bitmaps.
  
info.NumColormapEntries = 0;
info.Colormap = [];

info.RedMask = fread(fid, 1, 'uint32');
info.GreenMask = fread(fid, 1, 'uint32');
info.BlueMask = fread(fid, 1, 'uint32');



function [info, msg] = readWin2xInfo(fid, info)
%READWIN2XINFO  Read the metadata from a Win 2.x BMP.
  
info = readBMPFileHeader(fid, info);
[info, msg] = readWin2xBitmapHeader(fid, info);
info.CompressionType = 'none';

if (~isempty(msg))
    return
end

if ((info.Width < 0) || (info.Height < 0))
    info.FormatVersion = 'Version 1 (IBM OS/2 1.x)';
    fseek(fid, -4, 'cof');
    info.Width = fread(fid, 1, 'uint16');
    info.Height = fread(fid, 1, 'uint16');
else
    info.FormatVersion = 'Version 2 (Microsoft Windows 2.x)';
end

[info, msg] = readVersion2xColormap(fid, info);



function [info, msg] = readWin3xInfo(fid, info)
%READWIN3XINFO  Read the metadata from a Win 3.x/NT BMP.
  
info.FormatVersion = 'Version 3';
info = readBMPFileHeader(fid, info);
[info, msg] = readWin3xBitmapHeader(fid, info);
    
if (~isempty(msg))
    return
end

if (isequal(info.CompressionType, 'bitfields'))
    info.FormatVersion = 'Version 3 (Microsoft Windows NT)';
else
    info.FormatVersion = 'Version 3 (Microsoft Windows 3.x)';
end

if ((isequal(info.CompressionType, 'Version 3 (Microsoft Windows NT)')) && ...
    ((info.BitDepth == 16) || (info.BitDepth == 32)) && ...
    (~isequal(info.CompressionType,'bitfields')))
  
    msg= 'BMP Version 3 (Microsoft Windows NT) file appears to be corrupt';
    return;
    
end
    
if (isequal(info.CompressionType, 'bitfields'))
    info = readVersion3xMasks(fid, info);
    msg = '';
else
    [info, msg] = readVersion3xColormap(fid, info);
end



function [info, msg] = readWin4xInfo(fid, info)
%READWIN4XINFO  Read the metadata from a Win 95 BMP.
  
info.FormatVersion = 'Version 4 (Microsoft Windows 95)';
info = readBMPFileHeader(fid, info);
[info, msg] = readWin4xBitmapHeader(fid, info);

if (~isempty(msg))
    return
end

if (((info.BitDepth == 16) || (info.BitDepth == 32)) && ...
    (~strcmp(info.CompressionType,'bitfields')))
    msg= 'BMP Version 4 (Microsoft Windows 95) file appears to be corrupt';
    return;
end

info = readVersion3xColormap(fid, info);



function [info, msg] = readWin5xInfo(fid, info)
%READWIN5XINFO  Read the metadata from a Win 2000 BMP.
  
info.FormatVersion = 'Version 5 (Microsoft Windows 2000)';
info = readBMPFileHeader(fid, info);
[info, msg] = readWin5xBitmapHeader(fid, info);

if (~isempty(msg))
    return
end

info = readVersion3xColormap(fid, info);



function [info, msg] = readOS2v2Info(fid, info)
%READOS2V2INFO  Read the metadata from an OS/2 v.2 BMP.
  
msg = '';

info.BitmapSize = fread(fid, 1, 'uint32');
info.HorzResolution = fread(fid, 1, 'uint32');
info.VertResolution = fread(fid, 1, 'uint32');
info.NumColorsUsed = fread(fid, 1, 'uint32');
info.NumImportantColors = fread(fid, 1, 'uint32');
units = fread(fid, 1, 'uint16');
if (isempty(units))
    msg = 'Truncated header';
    return;
end
if (units == 0)
    info.Units = 'pixels/meter';
else
    info.Units = 'unknown';
end
fseek(fid, 2, 'cof');  % skip 2-byte pad
info.Recording = fread(fid, 1, 'uint16');

halftoning = fread(fid, 1, 'uint16');
if (isempty(halftoning))
    msg = 'Truncated header';
    return;
end

switch halftoning
case 0
    info.HalftoningAlgorithm = 'none';
        
case 1
    info.HalftoningAlgorithm = 'error diffusion';

case 2
    info.HalftoningAlgorithm = 'PANDA';
        
case 3
    info.HalftoningAlgorithm = 'super-circle';
    
otherwise
    info.HalftoningAlgorithm = 'unknown';
    
end

info.HalftoneField1 = fread(fid, 1, 'uint32');
info.HalftoneField2 = fread(fid, 1, 'uint32');

encoding = fread(fid, 1, 'uint32');
if (isempty(encoding))
    msg = 'Truncated header';
    return;
end

if (encoding == 0)
    info.ColorEncoding = 'RGB';
else
    info.ColorEncoding = 'unknown';
end

info.ApplicationIdentifier = fread(fid, 1, 'uint32');

info.NumColormapEntries = floor((info.ImageDataOffset - ftell(fid))/4);
if (info.NumColormapEntries > 0)
    map = fread(fid, info.NumColormapEntries*4, 'uint8');
    map = reshape(map, 4, info.NumColormapEntries);
    info.Colormap = double(flipud(map(1:3,:))')/255;
end



function [info, msg] = postProcess(info)
%POSTPROCESS  Perform some post processing and validity checking.
  
msg = '';

if (isempty(info.NumColormapEntries))
    info.NumColormapEntries = 0;
end

if (info.NumColormapEntries > 0)
    info.ColorType = 'indexed';
else
    if (info.BitDepth <= 8)
        info.ColorType = 'grayscale';
    else
        info.ColorType = 'truecolor';
    end
end

if (info.Width < 0)
    info = [];
    msg = 'Corrupt BMP file: bad image dimensions';
    return;
end



function cstype_str = decodeColorspaceType(cstype_num)
%DECODECOLORSPACETYPE  Determine the colorspace type from a constant.

switch (cstype_num)
case 0
    cstype_str = 'Calibrated RGB';

case 1934772034
    cstype_str = 'sRGB';
    
case 1466527264
    cstype_str = 'Windows default';
    
case 1279872587
    cstype_str = 'Linked profile';
    
case 1296188740
    cstype_str = 'Embedded profile';
   
otherwise
    cstype_str = 'Unknown';
end



function intent_str = decodeIntent(intent_num)
%DECODEINTENT  Determine the rendering intent from a constant.

switch (intent_num)
case 0
    intent_str = 'None';
    
case 1
    intent_str = 'Graphic: Saturation';
    
case 2
    intent_str = 'Proof: Relative Colorimetric';

case 4
    intent_str = 'Picture: Perceptual';
    
case 8
    intent_str = 'Match: Absolute Colorimetric';
    
end



function profile = readProfileField(fid, offset, profileData, profileSize)
%READPROFILEFIELD  Read the profile name from the file.

% Go to the beginning of the profile name.  Keep track of start point.
original_pos = ftell(fid);
fseek(fid, offset, 'bof');
fseek(fid, profileData, 'cof');

% Read the "null-terminated file name of the profile."
profile = fread(fid, profileSize, 'char=>char')';

% Remove any trailing nulls.
profile(profile == 0) = '';
