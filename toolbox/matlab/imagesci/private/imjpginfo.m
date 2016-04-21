function [info,msg] = imjpginfo(filename)
%IMJPGINFO Information about a JPEG file.
%   [INFO,MSG] = IMJPGINFO(FILENAME) returns a structure containing
%   information about the JPEG file specified by the string
%   FILENAME.  
%
%   If any error condition is encountered, such as an error opening
%   the file, MSG will contain a string describing the error and
%   INFO will be empty.  Otherwise, MSG will be empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:30 $

% This function should not call error()!  -SLE

info = [];

if (~ischar(filename))
    msg = 'FILENAME must be a string';
    return;
end

% JPEG files are big-endian.  Open the file and look at the first
% 2 bytes.  If they are not [255 216], then we don't have a JFIF
% or raw JPEG file and we can bail out without calling the
% MEX-file.

[fid,m] = fopen(filename, 'r', 'ieee-be');
if (fid == -1)
    info = [];
    msg = m;
    return;
else
    filename = fopen(fid);
    d = dir(filename);
    sig = fread(fid, 2, 'uint8');
    fclose(fid);
    if (~isequal(sig, [255; 216]))
        info = [];
        msg = 'Not a JPEG file';
        return;
    end

    [depth, m] = jpeg_depth(filename);
    
    if (isempty(depth))
        info = [];
        msg = m;
        return;
    end

    if (depth <= 8)
        [info, msg] = imjpg8(filename);
    elseif (depth <= 12)
        [info, msg] = imjpg12(filename);
    else
        [info, msg] = imjpg16(filename);
    end
    
    if (~isempty(info))
      
        info.FileModDate = d.date;
        info.FileSize = d.bytes;
        
        if (info.NumberOfSamples == 1)
            info.ColorType = 'grayscale';
        else
            info.ColorType = 'truecolor';
        end
        
        switch (info.CodingMethod)
        case 0
            method = 'Huffman';
        case 1
            method = 'Arithmetic';
        end
        
        info.CodingMethod = method;
        
        switch (info.CodingProcess)
        case 0
            process = 'Sequential';
        case 1
            process = 'Progressive';
        case 2
            process = 'Lossless';
        end
        
        info.CodingProcess = process;
        
    end
end

