function highlightlinexpctag(gcb)
% HIGHLIGHTLINEXPCTAG   Highlights a Simulink object referencing tagged signals.
%   HIGHLIGHTLINEXPCTAG(gcb) is solely meant to be called from the OpenFcn
%   callback of the From xPC Target block and not intended to be called
%   otherwise.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2003/04/10 18:05:33 $

open_system(get_param(gcb,'appname'))
blckpath=get_param(gcb,'blockpath');

%xxx To do: need to handle signals from 
%    multiple port blocks.
% Here we handle vector signals .../s1
pat='/s|$\d';
idx=regexp(blckpath,pat);
if ~isempty(idx)
    tempstr=blckpath(idx+2:end);
    if ~isempty(str2num(tempstr))
        if isnumeric(str2num(tempstr))
            blckpath=blckpath(1:idx-1);
        end
    end
end

blck=[get_param(gcb,'appname'),'/',blckpath];
ph=get_param(blck,'porthandles');
OutPortH=ph.Outport;
lines=get_param(OutPortH,'line');
HL=get_param(lines,'HiliteAncestors');
if strcmp(HL,'none')
   hilite_system(lines,'different');
else
   hilite_system(lines,'none');
end
