function blkStruct = slblocks

%SLBLOCKS Defines the Simulink library block representation
%   for xPC Target.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/03/25 04:11:30 $


blkStruct.Name    = 'xPC Target';
blkStruct.OpenFcn = 'xpclib';
blkStruct.MaskInitialization = '';

Browser(1).Library = 'xpclib';
Browser(1).Name    = 'xPC Target';
Browser(1).IsFlat  = 0;

blkStruct.Browser = Browser;

