function blkStruct = slblocks
%SLBLOCKS Defines the block library for the Virtual Reality Toolbox.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.4.4.1 $ $Date: 2003/04/12 23:20:54 $ $Author: batserve $

% Name of the subsystem which will show up in the
% Simulink Toolboxes subsystem.
blkStruct.Name = sprintf('Virtual\nReality\nToolbox');

% The function that is called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'vrlib';

blkStruct.MaskInitialization = '';

blkStruct.MaskDisplay = 'image(imread(''vrblockicon.png''))';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and its title
Browser(1).Library = 'vrlib';
Browser(1).Name    = 'Virtual Reality Toolbox';

blkStruct.Browser = Browser;
% End of slblocks
