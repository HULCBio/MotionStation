function blkStruct = slblocks
%SLBLOCKS Defines the Simulink library block representation
%   for SimPowerSystems.

%   Author: Paul Barnard
%   Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.2 $

blkStruct.Name    = ['SimPowerSystems'];
blkStruct.OpenFcn = 'powerlib';

blkStruct.MaskDisplay = ['plot(0,0,100,100,' ...
      '[90,64,77,77,60,56,51,46,40,34,30,25,13],' ...
      '[57,57,57,80,80,65,94,65,94,65,94,80,80],' ...
      '[90,87,82,77,74,68,64],[43,46,48,48,48,46,43],' ...
      '[48,77,77],[20,20,48],[39,27,13],[36,20,20]);'];

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'powerlib';
Browser(1).Name    = 'SimPowerSystems';
Browser(1).IsFlat  = 0;% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;

% End of slblocks.m
