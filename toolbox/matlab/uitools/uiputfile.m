%UIPUTFILE Standard save file dialog box.
%   [FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
%   displays a dialog box for the user to fill in and returns the
%   filename and path strings and the index of the selected filter.
%   A successful return occurs if a valid filename is specified. If a
%   exisiting filename is specified or selected, a warning message is
%   displayed. The user may select Yes to use the filename or No to 
%   return to the dialog to select another filename.
%
%   The FILTERSPEC parameter determines the initial display of files in 
%   the dialog box.  For example '*.m' lists all the MATLAB M-files.  If
%   FILTERSPEC is a cell array, the first column is used as the list of
%   extensions, and the second column is used as the list of descriptions.
%
%   When FILTERSPEC is a string or a cell array, "All files" is appended 
%   to the list.
%
%   When FILTERSPEC is empty the default list of file types is used.
%   
%   When FILTERSPEC is a filename, it is used as the default filename and
%   the file's extension is used as the default filter.
%
%   Parameter TITLE is a string containing the title of the dialog
%   box.
%
%   The output variable FILENAME is a string containing the name of the file
%   selected in the dialog box.  If the user presses Cancel, it is set to 0.
%
%   The output variable PATH is a string containing the name of the path
%   selected in the dialog box.  If the user presses Cancel, it is set to 0.
%
%   The output variable FILTERINDEX returns the index of the filter selected
%   in the dialog box. The indexing starts at 1. If the user presses Cancel,
%   it is set to 0.
%
%   [FILENAME, PATHNAME, FILTERINDEX] = UIPUTTFILE(FILTERSPEC, TITLE, FILE)
%   FILE is a string containing the name to use as the default selection.
% 
%   [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%   places the dialog box at screen position [X,Y] in pixel units.
%   This option is supported on UNIX platforms only.
%   
%   [FILENAME, PATHNAME] = UIGETFILE(..., X, Y)
%   places the dialog box at screen position [X,Y] in pixel units.
%   This option is supported on UNIX platforms only. 
%   THIS SYNTAX IS OBSOLETE AND WILL BE REMOVED. PLEASE USE THE FOLLOWING
%   SYNTAX INSTEAD:
%       [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%
%
%   Examples:
%
%   [filename, pathname] = uiputfile('matlab.mat', 'Save Workspace as');
%
%   [filename, pathname] = uiputfile('*.mat', 'Save Workspace as');
%
%   [filename, pathname, filterindex] = uiputfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'M-files (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Save as');
%
%   [filename, pathname, filterindex] = uiputfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Save as', 'Untitled.mat');
%
%   Note, multiple extensions with no descriptions must be separated by semi-
%   colons.
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Save as');
%
%   Associate multiple extensions with one description like this:
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Save as');
%
%   This code checks if the user pressed cancel on the dialog.
%
%   [filename, pathname] = uiputfile('*.m', 'Pick an M-file');
%   if isequal(filename,0) | isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
%   See also UIGETFILE, UIGETDIR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.20.4.2 $  $Date: 2004/04/10 23:34:36 $
%   Built-in function.
