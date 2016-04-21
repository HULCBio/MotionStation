function highlightxpctag(gcb)
% HIGHLIGHTXPCTAG   Highlights a Simulink object referencing tagged block.
%   HIGHLIGHTXPCTAG(gcb) is solely meant to be called from the OpenFcn
%   callback of the To xPC Target block and not intended to be called
%   otherwise.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/10 17:51:17 $
     
open_system(get_param(gcb,'appname'))
blck=[get_param(gcb,'appname'),'/',...
   get_param(gcb,'blockpath')];
HL=get_param(blck,'HiliteAncestors');
if strcmp(HL,'none')
    hilite_system(blck,'find')
else
    hilite_system(blck,'none')
end