function out = clipboard(whatToDo, stuff)
%CLIPBOARD Copy and paste strings to and from system clipboard.
%
% CLIPBOARD('copy', STUFF) Sets the clipboard contents to STUFF.  If STUFF
% is not a char array, MAT2STR is used to convert it to a string.
%
% STR = CLIPBOARD('paste') Returns the current contents of the clipboard as
% a string or '' if the current clipboard cannot be converted to a string.
%
% DATA = CLIPBOARD('pastespecial') Returns the current contents of the
% clipboard as an array using UIIMPORT.
%
% Requires an active X display on Unix and Java elsewhere.
% 
% See also LOAD, FILEFORMATS, UIIMPORT

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.14.4.1 $  $Date: 2002/10/24 02:13:19 $

usesXClipboard = isunix && ~strcmpi(computer, 'mac');

if usesXClipboard & isempty(get(0,'DefaultFigureXDisplay'))
    error('There is no X display set.')
end

if ~usesXClipboard & ~usejava('awt') 
    error('Java is not currently enabled.  See JAVA for more information.');
end

error(nargchk(1,2,nargin));
error(nargchk(0,1,nargout));

if strcmpi(whatToDo, 'copy')
    if nargin == 1
        error('2 args required for copy')
    end

    if isempty(stuff)
        return;
    end
    
    
    if ischar(stuff)
        if size(stuff, 1) > 1
            % This is a buffered array of vertically cat'd "strings."
            % In this case, we have no idea of how to "glue" the
            % "strings" together.  (Do we cat them with ASCII 10's?
            % 13/10 pairs?  Per platform?  Just combine them with no
            % return-style character between them?  Or what?
            % Since whatever we do is likely to be wrong, let's not try
            % to guess.
            error('MATLAB:clipboard:MultiLineString', ...
                ['The second argument to the CLIPBOARD function cannot ' ...
                 'be a multi-line character array.'])
        end
    else
        % this should error out if something is hokey
        stuff = mat2str(stuff);
    end

    if usesXClipboard
        % use system_dependent
        system_dependent('xsetselection',stuff);
    else
        % create ClipboardHandler object
        cpobj = com.mathworks.page.utils.ClipboardHandler;

        % do the copy
        cpobj.copy(stuff);
    end
elseif strcmpi(whatToDo, 'paste')
    if usesXClipboard
        % use system_dependent
        out = system_dependent('xgetselection');
    else
        % create ClipboardHandler object
        cpobj = com.mathworks.page.utils.ClipboardHandler;
    
        % do the paste
        out = char(cpobj.paste);
    
        % check for error (possibly false errors???)
        if strcmp(out, '!ERR#')
            % exit quietly and let caller manage empty result
            % error('Unable to convert clipboard contents to string.');
            out = '';
        end
    end
elseif strcmpi(whatToDo, 'pastespecial')
    % given output arg, get results from uiimport and hand off
    % otherwise, let uiimport think it was called from the caller's wksp
    if nargout
        out = uiimport('-pastespecial');
    else
        evalin('caller', 'uiimport(''-pastespecial'');');
    end
else
    error('Usage: CLIPBOARD(''copy'',stuffToCopy) or OUT = CLIPBOARD(''paste'')')
end    
