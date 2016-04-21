function [x,y]=pdesnap(ax,pv,flag)
%PDESNAP Returns new x,y coordinates "snapped" to the closest grid point.
%   [X,Y]=PDESNAP(AX,PV,FLAG) 'snaps' the current position PV to the
%   closest grid point in the axes with handle AX, if FLAG is set
%   (the default).

%       Magnus Ringh 5-26-94, MR 11-11-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:12:00 $

if nargin<3, flag=1; end
xticks=get(ax,'XTick');
yticks=get(ax,'YTick');
xlim=get(ax,'XLim');
ylim=get(ax,'YLim');
if isempty(xticks) || isempty(yticks) || flag==0,
  x=pv(1,1); y=pv(1,2);
else
  x=xticks(find(min(abs(xticks-pv(1,1)))==abs(xticks-pv(1,1))));
  x=x(1);
  y=yticks(find(min(abs(yticks-pv(1,2)))==abs(yticks-pv(1,2))));
  y=y(1);
end
x=sort([xlim x]); x=x(2);
y=sort([ylim y]); y=y(2);

