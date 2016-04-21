function [fileType, openAction, loadAction, description] = finfo(filename, ext)
% FINFO Identify file type against standard file handlers on path
%
%       [TYPE, OPENCMD, LOADCMD, DESCR] = finfo(FILENAME)
%
%       TYPE - contains type for FILENAME or Unknown.
%
%       OPENCMD - contains command to OPEN or EDIT the FILENAME or empty if
%                 no handler is found or FILENAME is not readable.
%
%       LOADCMD - contains command to LOAD data from FILENAME or empty if
%                 no handler is found or FILENAME is not readable.
%
%       DESCR   - contains description of FILENAME or error message if
%                 FILENAME is not readable.
%
% See OPEN, LOAD

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.19.4.4 $  $Date: 2004/03/24 03:05:34 $

if exist(filename,'file') == 0
    error(['File ' filename ' not found.'])
end

% get file extension
if nargin == 1 || isempty(ext)
    [ext, description] = getExtension(filename);
else
    description = '';
end
ext = lower(ext);

% rip leading . from ext
if ~isempty(findstr(ext,'.'))
    ext = strtok(ext,'.');
end

% special case for .text files (textread will give false positive)
if strcmp(ext,'text')
    ext = '';
end

% check if open and load handlers exist
openAction = '';
loadAction = '';

% this setup will not allow users to override the default EXTread behavior
if ~isempty(ext)
    % known data formats go to uiimport and importdata
    if ~isempty(strmatch(lower(ext), ...
                                 {'avi', ...                       % movie files
                                 'au' , 'snd', 'wav', ...         % audio files
                                 'csv', 'dat', 'dlm', 'tab', ...  % text files
                                 'xls', 'wk1', ...                % worksheet files
                                 'im'}, ...                       % image files (see getExtension below)
                         'exact'))
        openAction = 'uiimport';
        loadAction = 'importdata';
    else
    % unknown data format, try to find handler on the path
        openAction = which(['open' ext]);
        loadAction = which([ext 'read']);
    end
end

if ~isempty(openAction) || ~isempty(loadAction)
    fileType = lower(ext);
else
    fileType = 'unknown';
end

% rip path stuff off commands
if ~isempty(openAction)
    [p,openAction,e] = fileparts(openAction);
end
if ~isempty(loadAction)
    [p,loadAction,e] = fileparts(loadAction);
end

% make nice description and validate file format
if nargout == 4 && isempty(description) % only fetch descr if necessary
    if ~isempty(ext) && ~isempty(which([ext 'finfo']))
        [status, description] = feval([ext 'finfo'], filename);
        if isempty(status)
            % the file finfo util sez this is a bogus file.
            % return valid file type but empty actions
            openAction = '';
            loadAction = '';
            % generate failure message, used by IMPORTDATA
            description = 'FileInterpretError'; 
            return
        end
    else
        % no finfo for this file, give back contents
        fid = fopen(filename);
        if fid > 0
            description = fread(fid,1024*1024,'*char')';
            fclose(fid);
        else
            description = 'File not found';
        end
    end
end

function [ext, description] = getExtension(filename)
%  try to get imfinfo (if file is image, use "im")
[s, msg]  = imfinfo(filename);
if ~isempty(msg)
    % reset lasterr and use real ext from file
    [p,f,ext]=fileparts(filename);
    description = '';
    return;
end

ext = 'im';
if length(s) > 1
    description = sprintf('%s file with %d images.\n\nImporting first image only.\n\nUse IMREAD to read images 2 through %d.', upper(s(1).Format), length(s), length(s));
else
    description = sprintf('%d bit %s %s image%s', s.BitDepth, s.ColorType, ...
                          upper(s.Format));
end

