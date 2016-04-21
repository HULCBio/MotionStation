function blkStruct = slblocks
%SLBLOCKS Defines the block library for Real-Time Workshop

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.9.2.2 $
%   $Date: 2004/04/15 00:25:09 $

% Name of the subsystem which will show up in the
% Simulink Blocksets and Toolboxes subsystem.
blkStruct.Name = sprintf('Real-Time\nWorkshop');

% The function that will be called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'rtwlib';

blkStruct.MaskInitialization = '';

% The argument to be set as the Mask Display for the subsystem.
% You may comment this line out if no specific mask is desired.
blkStruct.MaskDisplay = ['plot([1:.1:5],', ...
                         'sin(2*pi*[1:.1:5])./[1:.1:5]./[1:.1:5]);' ...
                         'text(2.3,.5,''rtwlib'')'];

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'rtwlib';
Browser(1).Name    = 'Real-Time Workshop';
Browser(1).IsFlat  = 0;

blkStruct.Browser = Browser;
% End of slblocks
