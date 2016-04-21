%UIGETDIR Standard open directory dialog box
%   DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
%   displays a dialog box for the user to browse through the directory
%   structure and select a directory, and returns the directory name
%   as a string.  A successful return occurs if the directory exists.
%
%   The STARTPATH parameter determines the initial display of directories
%   and files in the dialog box.
%
%   When STARTPATH is empty the dialog box opens in the current directory.
%
%   When STARTPATH is a string representing a valid directory path, the 
%   dialog box opens in the specified directory.
%
%   When STARTPATH is not a valid directory path, the dialog box opens
%   in the base directory.
%
%   Windows:
%   Base directory is the Windows Desktop directory.
%
%   UNIX: 
%   Base directory is the directory from which MATLAB is started.
%   The dialog box displays all filetypes by default. The type 
%   of files that are displayed can be changed by changing the filter 
%   string in the Selected Directory field of the dialog box. If the
%   user selects a file instead of a directory, then the directory
%   containing the file is returned.
%
%   Parameter TITLE is a string containing a title for the dialog box.
%   When TITLE is empty, a default title is assigned to the dialog box.
%
%   Windows:
%   The TITLE string replaces the default caption inside the 
%   dialog box for specifying instuctions to the user.
%
%   UNIX:
%   The TITLE string replaces the default title of the dialog box.
%
%   When no input parameters are specified, the dialog box opens in the
%   current directory with the default dialog title.
%
%   The output parameter DIRECTORYNAME is a string containing the 
%   directory selected in the dialog box. If the user presses the Cancel
%   button it is set to 0.
%
%   Examples:
%
%   directoryname = uigetdir;
%
%   Windows:
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB');
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');
%
%   UNIX:
%   directoryname = uigetdir('/home/matlab/work');
%   directoryname = uigetdir('/home/matlab/work', 'Pick a Directory');
%
%   See also UIGETFILE, UIPUTFILE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/15 03:27:45 $
%   Built-in function.
