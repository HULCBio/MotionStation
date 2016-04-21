function nndataimporthelp(varargin);
%NNDATAIMPORTHELP Help text for the Import Data window.
%
%  Synopsis
%
%   nndataimporthelp(varargin) 
% 
%   displays the help text for the the Import Data window. 
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:11:04 $

ni=nargin;

if ni
   action=varargin{1};
else
   return
end

switch action,
case 'main',
   %---Help for the Import Network window
   helptext={'Overview', ...
         {'The Import Data window allows you to import training data from the';
         'workspace or from a file. The data can be imported in a structure that';
         'contains two fields: the input (struct.U) and the output (struct.Y).';
         'It can also be imported as two arrays, an input array and an output array.';
         '';
         'Flip through the remaining Topics for a detailed description of how ';
         'to use the Import Data window.'};
      'Selections', ...
         {'There are four selections in the Import Data window:';
         '';
         '1) Structures:';
         '     If this is selected, the data will be expected in structure format.';
         '     The input data should be stored in name.U, and the output data';
         '     should be stored in name.Y';
         '';
         '2) Arrays:';
         '     If this is selected, the data will be expected in array format.';
         '     The input data should be stored one array, and the output data';
         '     should be stored in another array.  The two arrays should have';
         '     the same dimensions.';
         '';
         '3) Workspace:';
         '     If you select Workspace, then you will retrieve the data';
         '     from the workspace.  The workspace contents will be displayed';
         '     (if it contains valid structures or arrays), and you can select any ';
         '     available structure (or input and output arrays).';
         '';
         '4) MAT-file:';
         '     With this option selected, you will retrieve the data from';
         '     a disk file in .mat format.  You can enter the filename, or';
         '     Browse the disk to locate a file.  After you select a file,';
         '     the contents of the file are displayed (if it contains valid';
         '     structures or arrays).  Then you select the appropriate structure';
         '     or arrays by clicking the corresponding arrow button.';
         ''};
      'Buttons', ...
         {'There are four buttons in the Import Data Window:';
         '';
         '1) Browse:';
         '     If you select MAT-file, then this button allows you to browse';
         '     you computer to locate the appropriate file.';
         '';
         '2) OK:';
         '     Loads the selected data into the training window.';
         '';
         '3) Help:';
         '     Brings up this help window (as you just found out).';
         '';
         '4) Cancel:';
         '     Closes the Import Data window without importing data.';
         ''}};
            
end, % switch action

helpwin(helptext);

