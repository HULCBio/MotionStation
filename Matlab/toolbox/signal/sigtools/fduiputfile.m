function [f,p] = fduiputfile(initFile,dlgboxTitle,extension)   
% FDUIPUTFILE Save file dialog box that adds an extension.
%   FDUIPUTFILE(INITFILE,TITLE,EXT) Calls UIPUTFILE with INITFILE and TITLE
%   as inputs.  EXT will be concatenated if no extension is returned with
%   the filename.  This is also a workaround for uiputfile which works
%   differently on the PC and UNIX.
%
% Inputs: 
%    initFile - determines the initial display of files in the dialog box.
%    dlgboxTitle - String containing the title of the dialog box.
%    extension - string containing the default extension, i.e. '.mat'.
%
% Ouputs: 
%    f - file name with extension .mat.
%    p - path to file.

%   Author(s): R. Losada, P. Pacheco, P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:45 $ 

error(nargchk(3,3,nargin));

[f,p] = uiputfile(initFile,dlgboxTitle);

if ~isequal(f,0),
    
    % uiputfile DOES NOT automatically add 
    % extensions to file names
    if isempty(findstr(f,'.'))
        % No '.' extension, so add extension to file name
        f = [f '.' extension];
    elseif strcmp(f(end),'.')
        % Do not allow no extension
        f = [f extension];
    end   
end

% [EOF]
