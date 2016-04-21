function blkStruct = slblocks
%SLBLOCKS Defines the block library for SLOPTIM Blockset.

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:53 $
%   Copyright 1990-2003 The MathWorks, Inc.

% Name of the subsystem which will show up in the
% SIMULINK Blocksets and Toolboxes subsystem.
blkStruct.Name = sprintf('Simulink\nResponse\nOptimization');

% The function that will be called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'srolib';

% The argument to be set as the Mask Display for the subsystem.
% You may comment this line out if no specific mask is desired.
blkStruct.MaskDisplay = 'plot([0:10],[-.5 1.5 .6 1.3 .8 1.1 .95 1.02 .99 1 1])';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'srolib';
Browser(1).Name    = 'Simulink Response Optimization';
Browser(1).IsFlat  = 0;% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;


% [End] of slblocks.m
