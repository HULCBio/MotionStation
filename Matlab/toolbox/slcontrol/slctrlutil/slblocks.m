function blkStruct = slblocks
% SLBLOCKS  Defines the Simulink library block representation
%           for Simulink Control Design

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:37:27 $

blkStruct.Name    = sprintf('Simulink\nControl\nDesign');
blkStruct.OpenFcn = 'slctrlblks';
blkStruct.MaskInitialization = '';
blkStruct.MaskDisplay = '';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it.
Browser(1).Library = 'slctrlblks';
Browser(1).Name    = 'Simulink Control Design';
Browser(1).IsFlat  = 0; % Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;

% End of slblocks.m
