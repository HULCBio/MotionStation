function blkStruct = slblocks
%SLBLOCKS Defines the block library for the Report Generator

% Copyright 1997-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/15 00:17:57 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';
blkStruct.Name = ['Report' char(10) 'Generator'];

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
blkStruct.OpenFcn = 'rptgenlib;';%.mdl file

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
blkStruct.MaskDisplay = ['plot([.8 0 0 1 1 .8 .8 1],[1 1 0 0 .8 1 .8 .8]);',...
        'text(.5,.6,''Report'',''horizontalalignment'',''center'');'];
% End of blocks

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'rptgenlib';
Browser(1).Name    = 'Report Generator';
Browser(1).IsFlat  = 1;

blkStruct.Browser = Browser;
