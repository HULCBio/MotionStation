function nndataexporthelp(varargin);
%NNDATAEXPORTHELP Help text for the Export Data window.
%
%  Synopsis
%
%   nndataexporthelp(varargin) 
%
%   displays the help text for the the Export Data window. 
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:11:01 $

ni=nargin;

if ni
   action=varargin{1};
else
   return
end

switch action,
case 'main',
   %---Help for the Export Network window
   helptext={'Overview', ...
         {'The Export Data window allows you to save training data to the';
         'workspace or to a file. The data is saved in a structure that';
         'contains two fields: the input (struct.U) and the output (struct.Y).';
         '';
         'Flip through the remaining Topics for a detailed description of how ';
         'to use the Export Data window.'};
      'Selections', ...
         {'There is one selection in the Export Data window:';
         '';
         '1) Data Structure Name:';
         '     Enter the name that you wish to assign to the data structure.';
         '     The input data will be stored in name.U, and the output data';
         '     will be stored in name.Y';
         ''};
      'Buttons', ...
         {'There are four buttons in the Export Data Window:';
         '';
         '1) Export to Disk:';
         '     The data structure is saved to a disk file.  You are';
         '     prompted for a directory and a filename in a standard browsing';
         '     window.';
         '';
         '2) Export to Workspace:';
         '     The data structure is saved to the workspace.';
         '';
         '3) Help:';
         '     Brings up this help window (as you just found out).';
         '';
         '4) Cancel:';
         '     Closes the Export Data window without exporting the data.';
         ''}};
            
end, % switch action

helpwin(helptext);

