function varargout=guide(varargin)
%GUIDE  Open the GUI Design Envrionment.
%   GUIDE initiates the GUI Design Environment tools that allow
%   FIG-files to be edited interactively.  Calling GUIDE by itself will
%   open a new untitled FIG-file. GUIDE(filename) opens the FIG-file
%   named 'filename' if it is on the MATLAB path. GUIDE(fullpath) opens
%   the FIG-file at 'fullpath' even if it is not on the MATLAB path.
%
%   GUIDE(HandleList) creates new FIG-files for each figure(s) containing
%   handles in the HandleList and copies the contents of the figure(s)
%   into the FIG-files.  
%     
%   See also INSPECT.

%   GUIDE(..., '-test') allows internal MathWorks automated tests to run.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.55.4.2 $ $Date: 2004/04/10 23:33:42 $

import com.mathworks.ide.layout.*;

% error out if there is insufficient java support on this platform
error(javachk('MWT', 'GUIDE'));

locNargin = nargin;
if nargin 
    if (isequal(varargin{end}, '-test')) 
        setappdata(0, 'MathWorks_GUIDE_testmode',1); 
        locNargin = locNargin - 1; 
    elseif (isequal(varargin{end}, '-testsave')) 
        setappdata(0, 'MathWorks_GUIDE_testmode',2); 
        locNargin = locNargin - 1; 
    else 
        if isappdata(0,'MathWorks_GUIDE_testmode') 
            rmappdata(0,'MathWorks_GUIDE_testmode'); 
        end 
    end 
else
    if isappdata(0,'MathWorks_GUIDE_testmode')
        rmappdata(0,'MathWorks_GUIDE_testmode');
    end
end

error(nargchk(0,1,locNargin));
ERRMSG = sprintf('Call GUIDE with no args, an existing FIG-file name, or a list of figure handles.');

% This chunk of code initializes filename to:
%  - an empty string  (blank gui)
%  - a valid filename (open it)
%  - zero             (cancel)
if getappdata(0, 'MathWorks_GUIDE_testmode')
    if (locNargin & isstr(varargin{1}))
        filename = varargin{1};
    else
        filename = '';
    end
elseif locNargin == 0  
    % guidetemplate will return an empty string or a legit filename on
    % success.
    % If the result is zero, the user hit cancel.
    filename = guidetemplate;
    if isequal(filename,0)
        if nargout
            varargout{1} = [];
        end
        return;
    elseif ishandle(filename)
        varargin{1} = filename;
    end
elseif isstr(varargin{1})
    % open specified filename
    filename = varargin{1};
else
    % set filename to zero for testing later
    filename = 0;
end

% We want to pass a filename with a fully specified path to the java code.
% Be prepared to handle two other cases
%
% 1) a file name specified w/o a .fig extension
%   (just append it)
% 2) a file name specified w/o a path
%   (prepend the path by using WHICH to find the file in the current
%    directory or on the path)
%
% After prepending the path and/or apending the extension, use EXIST to
% confirm that it is a legitimate file.

% handle the special case of guide(0) which was legal in R11
if isempty(filename) | (locNargin & isequal(varargin{1}, 0))
    % Open an untitled layout editor.
    result = LayoutEditor.newLayoutEditor;
elseif isstr(filename)
    [path,file,ext] = fileparts(filename);

    % Append the .fig extension if necessary
    if isempty(ext), ext = '.fig'; end

    if ~strcmp(ext, '.fig')
        error(ERRMSG);
    end

    % Try to open a fig file.
    filename = fullfile(path, [file ext]);

    % Prepend the path if necessary
    if isempty(path)
        filename = which(filename);
    end

    % Make sure it exists before opening the layout editor
    if ~exist(filename)
        error(ERRMSG);
    end
    
    result = LayoutEditor.openLayoutEditor(filename);
else
    % Try to clone figures based on given handles.
    % shape input argument into a row vector
    figs = varargin{1}; figs = figs(:)';

    % verify that they are all figure handles
    if any(~ishandle(figs)) |...
            length(figs) ~= length(strmatch('figure',get(figs,'type'),'exact'))
        error(ERRMSG);
    end

    result = {};
    for fig = figs
        result{end+1} = LayoutEditor.openLayoutEditor(fig);
    end

    % XXX what is the definition of "result"?
    result = result{1};
end

if nargout
    varargout{1} = result;
end
