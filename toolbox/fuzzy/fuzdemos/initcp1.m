%INITCP1 Initialize variables in the demo slcp1.m
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $

global AnimCpFigH AnimCpAxisH
winName = bdroot(gcs);
fprintf('Initializing ''fismat'' in %s...\n', winName);
fismat = readfis('slcp1.fis');
fprintf('Done with initialization.\n');
