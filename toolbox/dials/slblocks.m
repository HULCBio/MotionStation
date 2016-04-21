function blkStruct = slblocks
%SLBLOCKS Defines the block library for Dials & Gauges

% Copyright 1998-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/06/17 11:59:13 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';
blkStruct.Name = ['Dials & Gauges'];

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
blkStruct.OpenFcn = 'dnglib;';%.mdl file

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
% No display for now.
% blkStruct.MaskDisplay = '';%drawing command
blkStruct.MaskDisplay = 'image(imread(''dials_blockset_icon.png''))'; 
% End of blocks


% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'dnglibv1';
Browser(1).Name    = 'Dials & Gauges Blockset';
Browser(1).IsFlat  = 0;% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;
