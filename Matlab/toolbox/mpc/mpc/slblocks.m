function blkStruct = slblocks
%SLBLOCKS Defines the MPC Simulink library.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.10.5 $ $Date: 2004/04/10 23:35:34 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';
%           blkStruct.Name = ['MPC' sprintf('\n') 'Toolbox'];
blkStruct.Name = 'MPC Block';

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
%           blkStruct.OpenFcn = 'ExampleTF=tf([1 0],[1 1]);cstblocks;';%.mdl file
blkStruct.OpenFcn = 'mpclib';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
%           blkStruct.MaskDisplay = 'disp(''LTI'')';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'mpclib';
Browser(1).Name    = 'Model Predictive Control Toolbox';
 
blkStruct.Browser = Browser;
