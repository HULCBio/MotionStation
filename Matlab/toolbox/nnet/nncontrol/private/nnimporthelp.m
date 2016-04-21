function nnimporthelp(varargin);
%NNIMPORTHELP Help text for the Import Network window.
%
%  Synopsis
%
%   nnimporthelp(varargin) 
%
%   displays the help text for the Import Network window. 
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:11:19 $

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
         {'The Import Network window allows you to retrieve network objects from';
         'the workspace or from a file. This window can be reached from ';
         'several different controller and plant identification windows.';
         'In some cases, you can retrieve only the neural network plant model. In';
         'other cases, you can retrieve the neural network controller and/or';
         'the neural network plant model.';
         '';
         'Flip through the remaining Topics for a detailed description of how ';
         'to use the Import Network window.'};
      'Selections', ...
         {'There are two possible selections in the Import Network window.';
         '';
         '1) Workspace:';
         '     If you select Workspace, then you will retrieve the networks';
         '     from the workspace.  The workspace contents will be displayed';
         '     (if it contains valid network objects), and you can select any ';
         '     available networks as Controller and/or Plant.';
         '';
         '2) Mat-file:';
         '     With this option selected, you will retrieve the networks from';
         '     a disk file in .mat format.  You can enter the filename, or';
         '     Browse the disk to locate a file.  After you select a file,';
         '     the contents of the file are displayed (if it contains valid';
         '     network objects).  Then you select the appropriate Controller';
         '     or Plant network by clicking the corresponding arrow button.';
         ''};
      'Buttons', ...
         {'There are four buttons in the Import Network Window (in addition';
         'to the arrow buttons):';
         '';
         '1) Browse:';
         '     If you select Mat-file, then this button allows you to browse';
         '     you computer to locate the appropriate file.';
         '';
         '2) OK:';
         '     Loads the selected variables into the Simulink model.';
         '';
         '3) Help:';
         '     Brings up this help window (as you just found out).';
         '';
         '4) Cancel:';
         '     Closes the Import Network window without importing a network.';
         ''}};
            
end, % switch action

helpwin(helptext);

