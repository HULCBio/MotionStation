function blkStruct = slblocks
%SLBLOCKS Defines the block library for Real-Time Workshop

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/05/18 02:05:05 $  $Author: sanjai $

% Name of the subsystem which will show up in the
% Simulink Blocksets and Toolboxes subsystem.
blkStruct.Name = sprintf('Real-Time\nWindows\nTarget');

% The function that will be called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'rtwinlib';

blkStruct.MaskInitialization = '';

% The argument to be set as the Mask Display for the subsystem.
% You may comment this line out if no specific mask is desired.
blkStruct.MaskDisplay = ['plot([1:.1:5],', ...
                         'sin(2*pi*[1:.1:5])./[1:.1:5]./[1:.1:5]);' ...
                         'text(2.3,.5,''rtwinlib'')'];

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'rtwinlib';
Browser(1).Name    = 'Real-Time Windows Target';
Browser(1).IsFlat  = 1;% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;
% End of slblocks
