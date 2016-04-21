function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.16.2.2 $  $Date: 2004/04/15 01:01:51 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'Signal Processing Blockset';

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';

blkStruct.MaskDisplay = 'disp(''SF'')';
blkStruct.OpenFcn = 'sflib';
blkStruct.Name = 'Stateflow';

if exist('sflib') == 4,
	Browser(1).Library = 'sflib';
  Browser(1).Name    = 'Stateflow';
  Browser(1).IsFlat  = 1;
	blkStruct.Browser = Browser;
end;

% End of slblocks



