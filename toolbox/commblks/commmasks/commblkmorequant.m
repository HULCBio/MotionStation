function commblkmorequant(quantLibName)
% COMMBLKMOREQUANT opens the latest sublibrary specified in the function
% argument 
% Syntax: commblkmorequant('dspquant');

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:57 $

%-- Open library history
liblist = dspliblist;

%-- Look for the latest release
names = fieldnames(liblist);
rel = str2num(names{length(names)}(end));

%-- Get sublibrary belonging to the latest release
latestRel = liblist.(['dsp' num2str(rel)]);
pos = strmatch(quantLibName, latestRel);

% Open the sublibrary
open_system(latestRel{pos});


