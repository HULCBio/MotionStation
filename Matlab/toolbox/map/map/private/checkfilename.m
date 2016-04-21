function varargout = checkfilename(varargin)
%CHECKFILENAME Check validity of a filename.
%   FULLFILENAME = CHECKFILENAME(FILENAME, FUNCTION_NAME, ARGUMENT_POSITION) 
%   checks the validity of the FILENAME for reading data and issues 
%   a formatted error if the FILENAME is invalid. FULLFILENAME 
%   is the absolute pathname of the file.  
%
%   FILENAME can be a MATLABPATH relative partial pathname. If the file 
%   is not found in the current working directory, CHECKFILENAME 
%   searches down MATLAB's search path. The FILENAME must exist with
%   read permission. If FILENAME is a URL address, an error is issued.
%
%   FUNCTION_NAME is a string containing the function name to be used
%   in the formatted error message.
%
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.
%
%   FULLFILENAME = CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ...
%                                ARGUMENT_POSITION) 
%   EXT is a cell array of strings, which may be EMPTY, containing 
%   extensions without the '.'  character.  CHECKFILENAME loops, 
%   appending each element of EXT in both upper and lower case, until a 
%   valid filename is found; otherwise it will issue an error.
%
%   [FULLFILENAME, FID] = CHECKFILENAME(FILENAME, ...)
%   CHECKFILENAME leaves the file, FULLFILENAME, opened and returns the 
%   file identifier. 
%
%   [FULLFILENAME, URL] = CHECKFILENAME(FILENAME, ..., ALLOWURL) If
%   ALLOWURL is TRUE, FILENAME may by a URL address. The address must 
%   include the protocol type (e.g., "http://").  In this case,
%   FULLFILENAME is the absolute path to a temporary file copied from the
%   URL location and  URL is TRUE; otherwise, URL is false.  If FILENAME is
%   a URL address, remember to delete FULLFILENAME as it is a temporary
%   copy.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/23 05:54:59 $


allowURL= false;
switch nargin
   case {0,1,2}
        % CHECKFILENAME
        % CHECKFILENAME(FILENAME)
        % CHECKFILENAME(FILENAME, FUNCTION_NAME)
        eid = sprintf('%s:%s:tooFewInputs', getcomp, mfilename);
        error(eid, '%s', 'Error using CHECKFILENAME: too few inputs.');

   case 3
        % CHECKFILENAME(FILENAME, FUNCTION_NAME, ARGUMENT_POSITION)
        filename = varargin{1};
        function_name = varargin{2};
        pos = varargin{3};
        ext = {''};

   case 4
        filename = varargin{1};
        if islogical(varargin{4})
            % CHECKFILENAME(FILENAME, FUNCTION_NAME, ...
            %               ARGUMENT_POSITION, ALLOWURL)
            function_name = varargin{2};
            pos = varargin{3};
            allowURL = varargin{4};
            ext = {''};
        else
            % CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ...)
            %               ARGUMENT_POSITION)
            ext = varargin{2};
            function_name = varargin{3};
            pos = varargin{4};
        end

   case 5
        % CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ,...
        %               ARGUMENT_POSITION, ALLOWURL)
        filename = varargin{1};
        if islogical(varargin{5})
            ext = varargin{2};
            function_name = varargin{3};
            pos = varargin{4};
            allowURL = varargin{5};
        else
            eid = sprintf('%s:%s:invalidInputs', getcomp, mfilename);
            error(eid, '%s', 'Error using CHECKFILENAME: invalid ALLOWURL argument.');
        end

   otherwise
        eid = sprintf('%s:%s:tooManyInputs', getcomp, mfilename);
        error(eid, '%s', 'Error using CHECKFILENAME: too many input arguments.');
end

% Verify the inputs
if ~ischar(function_name)
    eid = sprintf('%s:%s:invalidFunctionName', getcomp, mfilename);
    error(eid, '%s', 'Error using CHECKFILENAME: invalid FUNCTION_NAME argument.');
end

checkinput(filename, {'char'}, {'nonempty'}, function_name, 'FILENAME', pos);

if ~iscell(ext)
    eid = sprintf('%s:%s:invalidExt', getcomp, mfilename);
    error(eid, '%s', 'Error using CHECKFILENAME: invalid EXT argument.');
end

if ~isnumeric(pos)
    eid = sprintf('%s:%s:invalidPosition', getcomp, mfilename);
    error(eid, '%s', 'Error using CHECKFILENAME: invalid ARGUMENT_POSITION argument.');
end

try
    [fullfilename, fid] = do_checkfilename(getcomp, filename, ext, ... 
                                           function_name, pos, allowURL);
catch
    rethrow(lasterror);
end

switch nargout
   case {0,1}
        % CHECKFILENAME(...)
        % FULLFILENAME = CHECKFILENAME(...)
        if ~isempty(fid) 
           fclose(fid);
        end
        varargout{1} = fullfilename; 
        if allowURL
           eid = sprintf('%s:%s:tooFewOutputs', getcomp, mfilename);
           error(eid, '%s', 'Error using CHECKFILENAME: too few outputs.');
        end

   case 2
        % [FULLFILENAME, FID] = CHECKFILENAME(...)
        % [FULLFILENAME, URL] = CHECKFILENAME(..., ALLOWURL)
        varargout{1} = fullfilename; 
        if (nargin > 3) 
           if islogical(varargin{4})  | (nargin == 5)
              varargout{2} = isempty(fid);
              if ~isempty(fid) 
                 fclose(fid);
              end
            else
              varargout{2} = fid;
            end
        else
           varargout{2} = fid;
        end

   otherwise
        if ~isempty(fid) 
           fclose(fid);
        end
        eid = sprintf('%s:%s:tooManyOutputs', getcomp, mfilename);
        error(eid, '%s', 'Error using CHECKFILENAME: too many output arguments.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fullfilename, fid] = do_checkfilename(comp, filename, ext, ...
                                            function_name, pos, allowURL)

fid = [];

% If the filename contains a URL string,
%  then download the remote file
%  and test access by writing to a tempname
if (strfind(filename, '://')) 
  
    if ~usejava('jvm')
        %msg = 'Reading from a URL requires a Java Virtual Machine.';
        msg = sprintf('Function %s requires a Java Virtual Machine to read a URL.', ...
                      upper(function_name));
        eid = sprintf('%s:%s:invalidJVM', comp, function_name);
        throwerr(eid,'%s',msg);
    end

    if ~allowURL
        msg = sprintf('File ''%s'' is a URL address.', filename);
        eid = sprintf('%s:%s:invalidFilename', comp, function_name);
        throwerr(eid,'%s',msg);
    end
    
    urltempname = tempname;
    try
        fullfilename = urlwrite(filename, urltempname);
        return;
    catch
        msg = sprintf('Function %s was unable to read URL ''%s''.', ...
                      upper(function_name), filename);
        eid = sprintf('%s:%s:invalidURL', comp, function_name);
        % The PC will not create urltempname
        %  but Unix will, so delete it
        if ~ispc
            delete(urltempname);
        end
        throwerr(eid,'%s',msg);
    end

end

% Try to open the filename with read permission
fid = fopen(filename, 'r');
if (fid == -1)

    % The file cannot be opened with read permission
    %  Try to append various extensions and try again
    found = 0;
    extension = [lower(ext) upper(ext)];
        
    for p = 1:numel(extension)

        extname = [filename '.' extension{p}];
        fid = fopen(extname, 'r');
        if (fid ~= -1) 
           % File was found.  
           %  Break "for" loop with updated extname
           found = 1;
           break;
        end

    end
        
    % Check that some filename+extension combination was found.
    if (~found)

       % Filename could not be opened with 'r' permission
       %  but could exist with write mode or as an M-file
       if isequal(exist(filename,'file'),2)

           % Check to verify NOT an M-File
           if ~(isequal(exist([filename '.m'],'file'),2) || ...
                isequal(exist([filename '.M'],'file'),2))
               % File exists without read mode
               msg = sprintf(...
                'Function %s was unable to open file ''%s'' for reading.', ...
                upper(function_name), filename);
               eid = sprintf('%s:%s:invalidFileMode', comp, function_name);
               throwerr(eid,'%s',msg);
            end

        end
        % File does not exist
        msg = sprintf('Function %s was unable to find file ''%s''.', ...
                      upper(function_name), filename);
        eid = sprintf('%s:%s:invalidFilename', comp, function_name);
        throwerr(eid,'%s',msg);

    else
        % extname was opened with 'r' permission
        filename = extname;
    end
end

% Return the full pathname if not in pwd.
fullfilename = fopen(fid);  
if isequal(exist(fullfile(pwd,fullfilename),'file'),2)
    fullfilename = fullfile(pwd, fullfilename);
end

