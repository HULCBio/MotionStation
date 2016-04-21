function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $

blkStruct.Name = sprintf('Comm\nBlockset');
blkStruct.OpenFcn = 'commlib';
blkStruct.MaskInitialization = '';

x = exp(j*[-45:-8:-215, -45]/180*pi);
x1 = x * 20 + 20 + j*35;
x2 = -x*10 + 60 +j*75;

p_str = ['plot(',...
          mat2str(real(x1),2), ',', mat2str(imag(x1),2), ',', ...
         '[0 15 ', mat2str(real(x1(10:13)),2),' 0],[0 0 ', mat2str(imag(x1(10:13)),2),' 0],', ...
         mat2str(real(x2),2), ',', mat2str(imag(x2),2), ',', ...
         '[19 40 35 52 40 49 60],[34 55 65 50 70 64 75],', ...
         '[74.5 70 65 74],[84.5 80 85 94],',...
         '[66 65 70.5 71], [86 99 97 91],',...
         '[75 74 79 80 75], [81 94 92 79 81],',...
         '[74.5 73], [87 87],',...
         '-10, 0, 100, 100);'];

blkStruct.MaskDisplay = p_str;

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it

Browser(1).Library = 'commlibv2';
Browser(1).Name    = 'Communications Blockset';

blkStruct.Browser = Browser;

% Define information about Signal Generators
Generator(1).Library = 'commgen2';
Generator(1).Name    = 'Communications Blockset';
blkStruct.Generator = Generator;

% Define information about Signal Viewers
Viewer(1).Library = 'commviewers2';
Viewer(1).Name    = 'Communications Blockset';
blkStruct.Viewer = Viewer;

% End of slblocks.m

