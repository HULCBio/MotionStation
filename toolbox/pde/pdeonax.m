function onax=pdeonax(ax)
%PDEONAX Checks if current pointer position is inside PDE Toolbox axes area
%       Returns 1 if inside axes area, 0 otherwise.
%
%       PDEONAX(AX) checks if inside the axes with handle AX.
%       PDEONAX checks if inside PDE Toolbox axes.

%       Magnus Ringh 9-21-94, MR 11-23-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:37 $

if nargin==0,
  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
end
if ~isempty(ax)
  xlim=get(ax,'XLim');
  ylim=get(ax,'YLim');
  pv=get(ax,'CurrentPoint');
  onax = (pv(1,1) >=  xlim(1) & pv(1,1) <= xlim(2) &...
      pv(1,2) >= ylim(1) & pv(1,2) <= ylim(2));
else
  error('PDE:pdeonax:PDEtbxInactive', 'PDE Toolbox not active.');
end

