% INITCP Initialize variables in the demo slcp.m
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $

global AnimCpFigH AnimCpAxisH
winName = bdroot(gcs);
fprintf('Initializing ''fismatrix'' in %s...\n', winName);
fismatrix = readfis('slcp.fis');
fprintf('Done with initialization.\n');
