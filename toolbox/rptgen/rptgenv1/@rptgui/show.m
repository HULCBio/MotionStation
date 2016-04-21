function show(g)
%SHOW displays all setfile figures and the clipboard

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:03 $

allFigs=findall(allchild(0),'type','figure',...
   'tag','RPTGEN_SETFILE_FIGURE');
clipFig=findall(allchild(0),'type','figure',...
   'tag','RPTGEN_COMPONENT_CLIPBOARD');


set([allFigs;clipFig],'visible','on');

