function format = imftype(filename)
%IMFTYPE Determine image file format.
%   FORMAT = IMFTYPE(FILENAME) attempts to determine the image
%   file format for the file FILENAME.  If IMFTYPE is successful,
%   FORMAT will be returned as the first string in the ext field
%   of the format registry (e.g., 'jpg', 'png', etc.)
%
%   FORMAT will be an empty string if IMFTYPE cannot determine
%   the file format.
%   
%   See also IMREAD, IMWRITE, IMFINFO, IMFROMATS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:25 $

error(nargchk(1, 1, nargin, 'struct'));

% Optimization:  look for a filename extension as a clue for the
% first format to try.

idx = find(filename == '.');
if (~isempty(idx))
    extension = lower(filename(idx(end)+1:end));
else
    extension = '';
end

% Try to get useful imformation from the extension.

if (~isempty(extension))
    
    % Look up the extension in the file format registry.
    fmt_s = imformats(extension);
    
    if (~isempty(fmt_s))
    
        if (~isempty(fmt_s.isa))

            % Call the ISA function for this format.
            tf = feval(fmt_s.isa, filename);
            
            if (tf)
              
                % The file is of that format.  Return the ext field.
                format = fmt_s.ext{1};
                return;
                
            end
        end
    end
end

% No useful information was found from the extension. 

msg = '';

% Get all formats from the registry.
fmt_s = imformats;

% Look through each of the possible formats.
for p = 1:length(fmt_s)
  
    % Call each ISA function until the format is found.
    if (~isempty(fmt_s(p).isa))

        tf = feval(fmt_s(p).isa, filename);
        
        if (tf)
          
            % The file is of that format.  Return the ext field.
            format = fmt_s(p).ext{1};
            return
            
        end
        
    else
      
        msg = ['At least one format does not have an ISA function', ...
               ' registered.  See "help imformats".']; 
        
    end
end

% The file was not of a recognized type.

% Issue the warning, if there is one.
if (~isempty(msg))
    warning('MATLAB:imftype:missingIsaFunction', '%s', msg)
end

% Return empty value
format = '';
