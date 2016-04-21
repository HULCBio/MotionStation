function winopen(filename)
%WINOPEN Open a file or directory using Microsoft Windows.
%   WINOPEN FILENAME opens the file or directory FILENAME using the
%   appropriate Microsoft Windows shell command, based on the file type and
%   extension.
%   This function behaves as if the you had double-clicked on the file
%   or directory inside of the Windows Explorer.
%
%   Examples:
%
%     If you have Microsoft Word installed, then
%     winopen('c:\myinfo.doc')
%     opens that file in Microsoft Word if the file exists, and errors if
%     it doesn't.
%
%     winopen('c:\')
%     opens a new Windows Explorer window, showing the contents of your C
%     drive.
%   
%   See also OPEN, DOS, WEB.
  
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2002/10/05 09:59:54 $

if ~ispc
    error('MATLAB:winopen:pcOnly', ...
        'The WINOPEN function is available only on Microsoft Windows.');
end

if ~exist(filename)
    error('MATLAB:winopen:noSuchFile', 'The specified file does not exist.');
end

pathstr = '';
if ~isdir(filename)
    [pathstr, name, extension] = fileparts(filename);
    filename = [name extension];
end
win_open_mex(pathstr, filename);