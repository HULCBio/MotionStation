function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

% Copyright 1994-2002 The MathWorks, Inc. 
% $Revision: 1.12 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';
blkStruct.Name = sprintf('%s\n%s','Fuzzy Logic','Toolbox');

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
blkStruct.OpenFcn = 'fuzblock';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
% No display for now.
% blkStruct.MaskDisplay = '';
blkStruct.IsFlat  = 0;% Is this library "flat" (i.e. no subsystems)?

% End of blocks


