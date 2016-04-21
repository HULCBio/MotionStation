% INITBB Initialize variables in the demo slbb.m
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $

global AnimBbFigH AnimBbAxisH BbDragging
winName = bdroot(gcs);
fprintf('Initializing ''fismatrix'' in %s...\n', winName);
fismatrix = readfis('slbb.fis');
fprintf('Done with initialization.\n');
