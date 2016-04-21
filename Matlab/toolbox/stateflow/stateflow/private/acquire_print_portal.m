function portal = acquire_print_portal
%ACQUIRE_PRINT_PORTAL
%   PORTAL = ACQUIRE_PRINT_PORTAL; 
%   Finds or creates the Stateflow Print Portal.
%

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:55:56 $

portal = sf('find','all','portal.sfPrintPortal', 1);

if isempty(portal), 
    portal = sf('new', 'portal');
    sf('set', portal, '.sfPrintPortal', 1);
else                
    portal = portal(1);
end;