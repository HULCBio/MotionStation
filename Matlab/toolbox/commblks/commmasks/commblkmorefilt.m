function commblkmorefilt(varargin)
% COMMBLKMOREFILT opens the latest sublibrary specified on the mask 
% Syntax: commblkmorefilt('dspmlti');

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/04/10 05:15:29 $

%-- Open library history
liblist = dspliblist;

%-- Preallocated variables
rel = zeros(2,1);
idx = zeros(2,1);

for p=1:length(varargin),
    
    %-- Look for latest release
    names = fieldnames(liblist);
    for k=1:length(names),
        rel(k) = str2num(names{k}(end));
    end
    
    %-- Get sublibraries belonging to latest release
    latestRel = liblist.(['dsp' num2str(max(rel))]);
    pos = strmatch(varargin{p},latestRel);
    
    %-- In case there are more than one sublibraries, get the latest
    for k=1:length(pos),
        idx(k) = str2num(latestRel{pos(k)}(end));
    end
    
    %-- Open the latest sublibrary belonging to the latest Release
    [t, t1]=max(idx);
    open_system(latestRel{pos(t1)});
    
end

    
