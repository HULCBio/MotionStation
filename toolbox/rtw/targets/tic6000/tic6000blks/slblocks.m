function blkStruct = slblocks
%SLBLOCKS Defines Simulink library block representation

% $RCSfile: slblocks.m,v $
% $Revision: 1.1.6.2 $
% $Date: 2004/04/08 21:00:28 $
% Copyright 2001-2003 The MathWorks, Inc.

blkStruct.Name    = ['Embedded Target' sprintf('\n') 'for TI C6000 DSP'];
blkStruct.OpenFcn = 'c6000lib';
blkStruct.MaskInitialization = '';
blkStruct.MaskDisplay = 'disp(''TIC6000'')';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it

Browser(1).Library = 'c6000lib';
Browser(1).Name    = 'Embedded Target for TI C6000 DSP';
Browser(1).IsFlat  = 0;

blkStruct.Browser = Browser;

% [EOF] slblocks.m
