function [info,msg] = imfinfo(filename, format)
%IMFINFO Information about graphics file.
%   INFO = IMFINFO(FILENAME,FMT) returns a structure whose
%   fields contain information about an image in a graphics
%   file.  FILENAME is a string that specifies the name of the
%   graphics file, and FMT is a string that specifies the format
%   of the file.  The file must be in the current directory or in
%   a directory on the MATLAB path.  If IMFINFO cannot find a
%   file named FILENAME, it looks for a file named FILENAME.FMT.
%   
%   The possible values for FMT are contained in the file format
%   registry, which is accessed via the IMFORMATS command.
%
%   If FILENAME is a TIFF, HDF, ICO, GIF, or CUR file containing more
%   than one image, INFO is a structure array with one element for
%   each image in the file.  For example, INFO(3) would contain
%   information about the third image in the file.
%
%   INFO = IMFINFO(FILENAME) attempts to infer the format of the
%   file from its content.
%
%   INFO = IMFINFO(URL,...) reads the image from an Internet URL.
%   The URL must include the protocol type (e.g., "http://").
%
%   The set of fields in INFO depends on the individual file and
%   its format.  However, the first nine fields are always the
%   same.  These common fields are:
%
%   Filename       A string containing the name of the file
%
%   FileModDate    A string containing the modification date of
%                  the file
%
%   FileSize       An integer indicating the size of the file in
%                  bytes
%
%   Format         A string containing the file format, as
%                  specified by FMT; for formats with more than one
%                  possible extension (e.g., JPEG and TIFF files),
%                  the first variant in the registry is returned
%
%   FormatVersion  A string or number specifying the file format
%                  version 
%
%   Width          An integer indicating the width of the image
%                  in pixels
%
%   Height         An integer indicating the height of the image
%                  in pixels
%
%   BitDepth       An integer indicating the number of bits per
%                  pixel 
%
%   ColorType      A string indicating the type of image; either
%                  'truecolor' for a truecolor (RGB) image,
%                  'grayscale' for a grayscale intensity image,
%                  or 'indexed', for an indexed image 
%
%   
%   See also IMREAD, IMWRITE, IMFORMATS.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:58 $

error(nargchk(1, 2, nargin, 'struct'));

info = [];

if (~ischar(filename))
    error('MATLAB:imfinfo:badFilename', 'Filename must be a string.')
end

% Download remote file.
if (strfind(filename, '://'))
  
    url = true;

    if (~usejava('mwt'))
        error('MATLAB:imfinfo:noJVM', ...
              'Reading from a URL requires a Java Virtual Machine.')
    end
    
    try
        filename = urlwrite(filename, tempname);
    catch
        error('MATLAB:imfinfo:urlRead', 'Can''t read URL "%s".', filename);
    end
    
else
  
    url = false;

end


if (nargin < 2)
  
    % With 1 input argument, we must be able to open the file
    % exactly as given.  Try it.
    
    fid = fopen(filename, 'r');
    
    if (fid == -1)
      
        msg = sprintf('Unable to open file "%s" for reading.', filename);
        if (nargout < 2)
            error('MATLAB:imfinfo:fileOpen', '%s', msg);
        else
            return;
        end
        
    else
      
        filename = fopen(fid);  % Get the full pathname if not in pwd.
        fclose(fid);
        
    end
    
    % Determine filetype from file.
    format = imftype(filename);
    
    if (isempty(format))
      
        % Couldn't determine filetype.
        msg = 'Unable to determine file format.';
        if (nargout < 2)
            error('MATLAB:imfinfo:whatFormat', '%s', msg);
        else
            return;
        end
        
    end
    
    % Get format information from the registry.
    fmt_s = imformats(format);
    
else
  
    % The format was passed in.
    
    % Look for the format in the registry.
    fmt_s = imformats(format);
    
    if (isempty(fmt_s))
      
        % Format was not in registry.
        msg = sprintf('Could not find format "%s" in format registry.', format);
        if (nargout < 2)
            error('MATLAB:imfinfo:unknownFormat', '%s', msg);
        else
            return;
        end
        
    end

    % Find the exact name of the file.
    fid = fopen(filename, 'r');

    if (fid == -1)

        % Since the user explicitly specified the format, see if we can find
        % the file using an extension.
    
        found = 0;
        
        for p = 1:length(fmt_s.ext)
          
            fid = fopen([filename '.' fmt_s.ext{p}], 'r');
            
            if (fid ~= -1)
              
                % File was found.  Update filename.
                found = 1;
                
                filename = fopen(fid);
                fclose(fid);
                
                break;
                
            end
            
        end
        
        % Check that some filename+format combination was found.
        if (~found)
          
            msg = sprintf('Unable to open file "%s" for reading.', filename);
            
            if (nargout < 2)
                error('MATLAB:imfinfo:fileOpen', '%s', msg);
            else
                return;
            end
            
        end
        
    else
      
        % The file exists as passed in.  Get full pathname from file.
        filename = fopen(fid);
        fclose(fid);
        
    end
    
end

% Call info function from IMFORMATS on filename
if (~isempty(fmt_s.info))
  
    [info, msg] = feval(fmt_s.info, filename);
    
    if (~isempty(msg))
        if (nargout < 2)
            error('MATLAB:imfinfo:infoSubFunction', '%s', msg);
        else
            return;
        end
    end
    
else
  
    msg = sprintf(['Format %s has no INFO function registered.  See', ...
                   ' "help imformats".'], format);
    
    if (nargout < 2)
        error('MATLAB:imfinfo:noInfoFunction', '%s', msg);
    else
        return;
    end
end

% Delete temporary file from Internet download.
if (url)
    delete_download(filename);
end



%%%
%%% Function delete_download
%%%
function delete_download(filename)

try
    delete(filename);
catch
    warning('MATLAB:imfinfo:removeTempFile', ...
            'Can''t delete temporary file "%s".', filename)
end
