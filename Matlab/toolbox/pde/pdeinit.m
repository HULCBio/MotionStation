function [hfig,hax] = pdeinit
%PDEINIT Start PDETOOL from scripts.

%   Magnus Ringh 7-01-94, MR 11-07-94.
%   Copyright 1994-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/02/09 17:03:16 $

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
if ~isempty(pde_fig),
  pdetool('new');
else
  pdetool;
end
pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
ax = findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
set(pde_fig,'CurrentAxes',ax)
no = nargout;
if no>0
  hfig = pde_fig;
end
if no>1
  hax = ax;
end

