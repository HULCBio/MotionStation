function [info,msg] = imtifinfo(filename)
%IMTIFINFO Information about a TIFF file.
%   [INFO,MSG] = IMTIFINFO(FILENAME) returns a structure containing
%   information about the TIFF file specified by the string
%   FILENAME.  If the TIFF file contains more than one image,
%   INFO will be a structure array; each element of INFO contains
%   information about one image in the TIFF file.
%
%   If any error condition is encountered, such as an error opening
%   the file, MSG will contain a string describing the error and
%   INFO will be empty.  Otherwise, MSG will be empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:35 $

% This function should not call error()!  -SLE

% This function is an M-file that does *not* use a libtiff-based
% MEX-file because the im*info functions are used when trying to
% guess the format of an input file because the user didn't
% specify the format.  We don't want to take the memory hit of
% loading a big MEX-file just to see if we have a TIFF file.

info = [];
msg = '';

if (~ischar(filename))
    msg = 'FILENAME must be a string';
    return;
 end

% TIFF files might be little-endian or big-endian.  Start with
% little-endian.  If we're wrong, we'll catch it down below and
% reopen the file.
[fid,m] = fopen(filename, 'r', 'ieee-le');
if (fid == -1)
    info = [];
    msg = m;
    return;
else
    filename = fopen(fid);
end

% Read directory information about the file
d = dir(filename);

%
% Initialize universal structure fields to fix the order
%
info.Filename = '';
info.FileModDate = '';
info.FileSize = [];
info.Format = '';
info.FormatVersion = [];
info.Width = [];
info.Height = [];
info.BitDepth = [];
info.ColorType = [];
info.FormatSignature = [];

info.ByteOrder = [];

%
% Initialize the baseline tags
%
info.NewSubfileType = [];
info.BitsPerSample = [];
info.Compression = [];
info.PhotometricInterpretation = [];
info.StripOffsets = [];
info.SamplesPerPixel = [];
info.RowsPerStrip = [];
info.StripByteCounts = [];
info.XResolution = [];
info.YResolution = [];
info.ResolutionUnit = [];
info.Colormap = [];
info.PlanarConfiguration = [];
info.TileWidth = [];
info.TileLength = [];
info.TileOffsets = [];
info.TileByteCounts = [];


sig = fread(fid, 4, 'uint8')';
if (~isequal(sig, [73 73 42 0]) && ...
    ~isequal(sig, [77 77 0 42]))
    info = [];
    msg = 'Not a TIFF file';
    fclose(fid);
    return;
end

if (sig(1) == 73)
    byteOrder = 'little-endian';
else
    byteOrder = 'big-endian';
end

if (strcmp(byteOrder, 'big-endian'))
    % Whoops!  Must reopen the file.
    pos = ftell(fid);
    fclose(fid);
    fid = fopen(filename, 'r', 'ieee-be');
    fseek(fid, pos, 'bof');
end
    
nextIFDOffset = fread(fid, 1, 'uint32');
k = 0;  % number of images

while (nextIFDOffset ~= 0)
    status = fseek(fid, nextIFDOffset, 'bof');
    if (status ~= 0)
        % The seek to find the next IFD just failed.  This is probably
        % because of a nonconforming TIFF file that didn't store the
        % offset to the next IDF correctly at the end of the last IFD.
        % The best we can do here is assume there aren't any more IFD's.
        break;
    end
    
    k = k + 1;
    info(k).Filename = filename;
    info(k).FileModDate = d.date;
    info(k).FileSize = d.bytes;
    info(k).Format = 'tif';
    info(k).FormatSignature = sig;
    info(k).ByteOrder = byteOrder;
    
    tagCount = fread(fid, 1, 'uint16');
    tagPos = ftell(fid);
    
    %
    % Default tag values
    %
    info(k).Compression = 'Uncompressed';
    info(k).Orientation = 1;
    info(k).ResolutionUnit = 'Inch';
    info(k).SamplesPerPixel = 1;
    info(k).BitsPerSample = ones(1, info(k).SamplesPerPixel);
    info(k).FillOrder = 1;
    info(k).GrayResponseUnit = 0.01;
    info(k).MaxSampleValue = [];  % can't be set yet; see end of for-loop
    info(k).MinSampleValue = 0;
    info(k).NewSubfileType = 0;
    info(k).PlanarConfiguration = 'Chunky';
    info(k).RowsPerStrip = pow2(32)-1;
    info(k).Thresholding = 1;
    
    %
    % Process the tags
    %
    for p = 1:tagCount
        fseek(fid, tagPos, 'bof');
        tagID = fread(fid, 1, 'uint16');
        
        switch tagID
            
        case 254
            % NewSubfileType
            fseek(fid, 6, 'cof');
            info(k).NewSubFileType = fread(fid, 1, 'uint32');
            
        case 256
            % ImageWidth
            type = fread(fid, 1, 'uint16');
            fseek(fid, 4, 'cof');
            if (type == 3)
                info(k).Width = fread(fid, 1, 'uint16');
            else
                info(k).Width = fread(fid,  1, 'uint32');
            end
            
        case 257
            % ImageLength
            type = fread(fid, 1, 'uint16');
            fseek(fid, 4, 'cof');
            if (type == 3)
                info(k).Height = fread(fid, 1, 'uint16');
            else
                info(k).Height = fread(fid, 1, 'uint32');
            end
            
        case 258
            % BitsPerSample
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 2)
                info(k).BitsPerSample = fread(fid, count, 'uint16')';
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).BitsPerSample = fread(fid, count, 'uint16')';
            end
            
        case 259
            % Compression
            fseek(fid, 6, 'cof');
            value = fread(fid, 1, 'uint16');
            switch value
            case 1
                info(k).Compression = 'Uncompressed';
            case 2
                info(k).Compression = 'CCITT 1D';
            case 3
                info(k).Compression = 'Group 3 Fax';
            case 4
                info(k).Compression = 'Group 4 Fax';
            case 5
                info(k).Compression = 'LZW';
            case 6
                info(k).Compression = 'JPEG';
            case 32773
                info(k).Compression = 'PackBits';
            otherwise
                info(k).Compression = 'Unknown';
            end
                
            
        case 262
            % PhotometricInterpretation
            fseek(fid, 6, 'cof');
            value = fread(fid, 1, 'uint16');
            switch (value)
            case 0
                info(k).PhotometricInterpretation = 'WhiteIsZero';
            case 1
                info(k).PhotometricInterpretation = 'BlackIsZero';
            case 2
                info(k).PhotometricInterpretation = 'RGB';
            case 3
                info(k).PhotometricInterpretation = 'RGB Palette';
            case 4
                info(k).PhotometricInterpretation = 'Transparency mask';
            case 5
                info(k).PhotometricInterpretation = 'CMYK';
            case 6
                info(k).PhotometricInterpretation = 'YCbCr';
            case 8
                info(k).PhotometricInterpretation = 'CIELab';
            case 9
                info(k).PhotometricInterpretation = 'ICCLab';
            otherwise
                info(k).PhotometricInterpretation = 'Unknown';
            end
            
        case 263
            % Thresholding
            fseek(fid, 6, 'cof');
            info(k).Thresholding = fread(fid, 1, 'uint16');
        
        case 264
            % CellWidth
            fseek(fid, 6, 'cof');
            info(k).CellWidth = fread(fid, 1, 'uint16');
        
        case 265
            % CellLength
            fseek(fid, 6, 'cof');
            info(k).CellLength = fread(fid, 1, 'uint16');
            
        case 266
            % FillOrder
            fseek(fid, 6, 'cof');
            info(k).FillOrder = fread(fid, 1, 'uint16');
            
        case 270
            % ImageDescription
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).ImageDescription = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).ImageDescription = char(fread(fid, count, 'uint8')');
            end

            % don't use null-terminated strings in MATLAB
            if (info(k).ImageDescription(end) == 0)
                info(k).ImageDescription(end) = [];
            end
            
        case 271
            % Make
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).Make = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).Make = char(fread(fid, count, 'uint8')');
            end
            
        
        case 272
            % Model
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).Model = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).Model = char(fread(fid, count, 'uint8')');
            end
        
        case 273
            % StripOffsets
            type = fread(fid, 1, 'uint16');
            count = fread(fid, 1, 'uint32');
            if (type == 3)
                if (count <= 2)
                    info(k).StripOffsets = fread(fid, count, 'uint16');
                else
                    offset = fread(fid, 1, 'uint32');
                    fseek(fid, offset, 'bof');
                    info(k).StripOffsets = fread(fid, count, 'uint16');
                end
            else
                if (count <= 1)
                    info(k).StripOffsets = fread(fid, count, 'uint32');
                else
                    offset = fread(fid, 1, 'uint32');
                    fseek(fid, offset, 'bof');
                    info(k).StripOffsets = fread(fid, count, 'uint32');
                end
            end
            
        case 274
            % Orientation
            fseek(fid, 6, 'cof');
            info(k).Orientation = fread(fid, 1, 'uint16');
        
        case 277
            % SamplesPerPixel
            fseek(fid, 6, 'cof');
            info(k).SamplesPerPixel = fread(fid, 1, 'uint16');
        
        case 278
            % RowsPerStrip
            type = fread(fid, 1, 'uint16');
            fseek(fid, 4, 'cof');
            if (type == 3)
                info(k).RowsPerStrip = fread(fid, 1, 'uint16');
            else
                info(k).RowsPerStrip = fread(fid, 1, 'uint32');
            end
            
        case 279
            % StripByteCounts
            type = fread(fid, 1, 'uint16');
            count = fread(fid, 1, 'uint32');
            if (type == 3)
                if (count <= 2)
                    info(k).StripByteCounts = fread(fid, count, 'uint16');
                else
                    offset = fread(fid, 1, 'uint32');
                    fseek(fid, offset, 'bof');
                    info(k).StripByteCounts = fread(fid, count, 'uint16');
                end
            else
                if (count <= 1)
                    info(k).StripByteCounts = fread(fid, count, 'uint32');
                else
                    offset = fread(fid, 1, 'uint32');
                    fseek(fid, offset, 'bof');
                    info(k).StripByteCounts = fread(fid, count, 'uint32');
                end
            end
        
        case 280
            % MinSampleValue
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 2)
                info(k).MinSampleValue = fread(fid, count, 'uint16');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).MinSampleValue = fread(fid, count, 'uint16');
            end
        
        case 281
            % MaxSampleValue
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 2)
                info(k).MaxSampleValue = fread(fid, count, 'uint16');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).MaxSampleValue = fread(fid, count, 'uint16');
            end
        
        case 282
            % XResolution
            fseek(fid, 6, 'cof');
            offset = fread(fid, 1, 'uint32');
            fseek(fid, offset, 'bof');
            num = fread(fid, 1, 'uint32');
            den = fread(fid, 1, 'uint32');
            info(k).XResolution = num/den;
            
        case 283
            % YResolution
            fseek(fid, 6, 'cof');
            offset = fread(fid, 1, 'uint32');
            fseek(fid, offset, 'bof');
            num = fread(fid, 1, 'uint32');
            den = fread(fid, 1, 'uint32');
            info(k).YResolution = num/den;
        
        case 284
            % PlanarConfiguration
            fseek(fid, 6, 'cof');
            value = fread(fid, 1, 'uint16');
            if (value == 1)
                info(k).PlanarConfiguration = 'Chunky';
            else
                info(k).PlanarConfiguration = 'Planar';
            end
        
        case 288
            % FreeOffsets
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 1)
                info(k).FreeOffsets = fread(fid, 1, 'uint32');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).FreeOffsets = fread(fid, count, 'uint32');
            end
            
        case 289
            % FreeByteCounts
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 1)
                info(k).FreeByteCounts = fread(fid, 1, 'uint32');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).FreeByteCounts = fread(fid, count, 'uint32');
            end
            
        case 290
            % GrayResponseUnit
            fseek(fid, 6, 'cof');
            value = fread(fid, 1, 'uint16');
            switch (value)
            case 1
                info(k).GrayResponseUnit = 0.1;
            case 2
                info(k).GrayResponseUnit = 0.01;
            case 3
                info(k).GrayResponseUnit = 0.001;
            case 4
                info(k).GrayResponseUnit = 0.0001;
            case 5
                info(k).GrayResponseUnit = 0.00001;
            end
        
        case 291
            % GrayResponseCurve
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 2)
                info(k).GrayResponseCurve = fread(fid, count, 'uint16');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).GrayResponseCurve = fread(fid, count, 'uint16');
            end
        
        case 296
            % ResolutionUnit
            fseek(fid, 6, 'cof');
            value = fread(fid, 1, 'uint16');
            switch (value)
            case 1
                info(k).ResolutionUnit = 'None';
            case 2
                info(k).ResolutionUnit = 'Inch';
            case 3
                info(k).ResolutionUnit = 'Centimeter';
            end
            
        case 305
            % Software
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).Software = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).Software = char(fread(fid, count, 'uint8')');
            end
            
        case 306
            % DateTime
            fseek(fid, 6, 'cof');
            offset = fread(fid, 1, 'uint32');
            fseek(fid, offset, 'bof');
            info(k).DateTime = char(fread(fid, 20, 'uint8')');
        
        case 315
            % Artist
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).Artist = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).Artist = char(fread(fid, count, 'uint8')');
            end
        
        case 316
            % HostComputer
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).HostComputer = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).HostComputer = char(fread(fid, count, 'uint8')');
            end
        
        case 320
            % ColorMap
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            offset = fread(fid, 1, 'uint32');
            fseek(fid, offset, 'bof');
            map = fread(fid, count, 'uint16');
            num = count / 3;
            info(k).Colormap = reshape(map, num, 3) / 65535;
            
        case 322
            % TileWidth
            type = fread(fid, 1, 'uint16');
            fseek(fid, 4, 'cof');
            if (type == 3)
                info(k).TileWidth = fread(fid, 1, 'uint16');
            else
                info(k).TileWidth = fread(fid, 1, 'uint32');
            end
            
        case 323
            % TileLength
            type = fread(fid, 1, 'uint16');
            fseek(fid, 4, 'cof');
            if (type == 3)
                info(k).TileLength = fread(fid, 1, 'uint16');
            else
                info(k).TileLength = fread(fid, 1, 'uint32');
            end
            
        case 324
            % TileOffsets
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 1)
                info(k).TileOffsets = fread(fid, count, 'uint32');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).TileOffsets = fread(fid, count, 'uint32');
            end
            
        case 325
            % TileByteCounts
            type = fread(fid, 1, 'uint16');
            count = fread(fid, 1, 'uint32');
            if (type == 3)
                if (count <= 2)
                    info(k).TileByteCounts = fread(fid, count, 'uint16');
                else
                    offset = fread(fid, 1, 'uint32');
                    fseek(fid, offset, 'bof');
                    info(k).TileByteCounts = fread(fid, count, 'uint16');
                end
            else
                if (count <= 1)
                    info(k).TileByteCounts = fread(fid, count, 'uint32');
                else
                    offset = fread(fid, 1, 'uint32');
                    fseek(fid, offset, 'bof');
                    info(k).TileByteCounts = fread(fid, count, 'uint32');
                end
            end
            
        case 338
            % ExtraSamples
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 2)
                info(k).ExtraSamples = fread(fid, count, 'uint16');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).ExtraSamples = fread(fid, count, 'uint16');
            end
            
        case 339
            % SampleFormat
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 2)
                data = fread(fid, count, 'uint16');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                data = fread(fid, count, 'uint16');
            end
            SampleFormat = num2cell(data);
            for q = 1:count
                switch (data(q))
                case 1
                    SampleFormat{q} = 'Unsigned integer';
                case 2
                    SampleFormat{q} = 'Two''s complement signed integer';
                case 3
                    SampleFormat{q} = 'IEEE floating point';
                case 4
                    SampleFormat{q} = 'Undefined';
                end
            end
            if (count == 1)
                SampleFormat = SampleFormat{1};
            end
            info(k).SampleFormat = SampleFormat;
              
        case 33432
            fseek(fid, 2, 'cof');
            count = fread(fid, 1, 'uint32');
            if (count <= 4)
                info(k).Copyright = char(fread(fid, count, 'uint8')');
            else
                offset = fread(fid, 1, 'uint32');
                fseek(fid, offset, 'bof');
                info(k).Copyright = char(fread(fid, count, 'uint8')');
            end
            
        case 34675
            fseek(fid, 6, 'cof');
            info(k).ICCProfileOffset = fread(fid, 1, 'uint32');
            
        end  %%%% switch
        
        tagPos = tagPos + 12;
        
    end  %%%% for

    %
    % Set more defaults; these depend on other tag values and so
    % couldn't be set above.
    %
    if (isempty(info(k).MaxSampleValue))
        info(k).MaxSampleValue = pow2(info(k).BitsPerSample) - 1;
    end
    
    info(k).BitDepth = sum(info(k).BitsPerSample);
    if (~isempty(info(k).Colormap))
        info(k).ColorType = 'indexed';
    elseif (strcmp(info(k).PhotometricInterpretation, 'WhiteIsZero'))
        info(k).ColorType = 'grayscale';
    elseif (strcmp(info(k).PhotometricInterpretation, 'BlackIsZero'))
        info(k).ColorType = 'grayscale';
    elseif (strcmp(info(k).PhotometricInterpretation, 'RGB'))
        info(k).ColorType = 'truecolor';
    else
        info(k).ColorType = 'unknown';
    end
    
    fseek(fid, tagPos, 'bof');
    nextIFDOffset = fread(fid, 1, 'uint32');
    
end  %%%% while

numImages = k;
if (numImages == 0)
    info = [];
    msg = 'No images found in TIFF file';
    fclose(fid);
    return;
end

fclose(fid);
