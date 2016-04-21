function nnexporthelp(varargin);
%NNEXPORTHELP Help text for the Export Network window.
%
%  Synopsis
%
%   nnexporthelp(varargin)
%
%   displays the help text for the Export Network window. 
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:11:07 $

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
         {'The Export Network window allows you to save network objects to the';
         'workspace, to a file, or to a Simulink model. This window can be reached';
         'from several different controller and plant identification windows.';
         'In some cases, you can save only the neural network plant model. In';
         'other cases, you can save the neural network controller and/or';
         'the neural network plant model.';
         '';
         'Flip through the remaining Topics for a detailed description of how ';
         'to use the Export Network window.'};
      'Selections', ...
         {'There are four possible selections in the Export Network window.';
         'They may not all be available.';
         '';
         '1) All Variables:';
         '     If you select All Variables, then you will save all of the';
         '     variables in the controller block.';
         '';
         '2) Neural Network Controller Weights:';
         '     With this option selected, you save the controller network weights';
         '     If the network object format is used (see below), then you can';
         '     choose the name of the network object.';
         '';
         '3) Neural Network Plant Weights:';
         '     With this option selected, you save the neural network plant weights';
         '     If the network object format is used (see below), then you can';
         '     choose the name of the network object.';
         '';
         '4) Use Neural Network Object Definition:';
         '     When this is selected, the networks will be saved in the form of';
         '     network objects.  If this is not selected, then all of the ';
         '     weight matrices and bias vectors in the network will be stored';
         '     separately.';
         ''};
      'Buttons', ...
         {'There are five buttons in the Export Network Window:';
         '';
         '1) Export to Disk:';
         '     The selected variables are saved to a disk file.  You are';
         '     prompted for a directory and a filename in a standard browsing';
         '     window.';
         '';
         '2) Export to Workspace:';
         '     The selected variables are saved to the workspace.';
         '';
         '3) Export to Simulink:';
         '     The selected networks are saved into a Simulink model.';
         '     For this option, the network object format must be selected';
         '     (see Selections).';
         '';
         '4) Help:';
         '     Brings up this help window (as you just found out).';
         '';
         '5) Cancel:';
         '     Closes the Export Network window without exporting a network.';
         ''}};
            
end, % switch action

helpwin(helptext);

