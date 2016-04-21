%INITCPP1  Initialize variables in the demo slcpp1.m
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $

global AnimCppFigH AnimCppAxisH
winName = bdroot(gcs);
fprintf('Initializing ''fismat'' in %s...\n', winName);
fismat = readfis('slcpp1.fis');
fprintf('Done with initialization.\n');

