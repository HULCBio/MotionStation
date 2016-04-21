function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/10 23:19:15 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';
blkStruct.Name = ['System Identification' sprintf('\n') 'Toolbox'];

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
blkStruct.OpenFcn = 'slident';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
% No display for now.
% blkStruct.MaskDisplay = '';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'slident';
Browser(1).Name    = 'System Identification Toolbox';
Browser(1).IsFlat  = 1;

% End of blocks


