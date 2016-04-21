function [xstr,ystr]=pdet2str(axes, extrax,extray)
%PDET2STR Tick marks to string converter.
%       Usage: [XSTR,YSTR]=PDET2STR(AXES,EXTRAX,EXTRAY)
%
%       Converts linearly spaced axis ticks into such as 0, 0.1, 0.2, ...,  1.0
%       into a MATLAB string '0:0.1:1' for an axes with handle AXES.
%       if not linearly spaced, empty matrices are returned.
%       Optional input arguments EXTRAS is an array of extra, added ticks
%       that should be discarded when converting the ticks.

%       Magnus Ringh 11-14-94, MR 8-8-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:12:03 $

if ~strcmp(get(axes,'Type'),'axes'),
  error('PDE:pdet2str:InputNotAxisHandle', 'Input argument is not an axes handle.')
end
if nargout<2,
  error('PDE:pdet2str:nargout', 'Too few output arguments.');
end

xtick=get(axes,'XTick');
ytick=get(axes,'YTick');
if nargin>1,
  if ischar(extrax),
    tmpx=matqparse(extrax);
    extrax=[];
    for i=1:size(tmpx,1),
      extrax=[extrax eval(tmpx(i,:))];
    end
  end
  for i=1:length(extrax),
    xtick=xtick(xtick~=extrax(i));
  end
end
if nargin>2,
  if ischar(extray),
    tmpy=matqparse(extray);
    extray=[];
    for i=1:size(tmpy,1),
      extray=[extray eval(tmpy(i,:))];
    end
  end
  for i=1:length(extray),
    ytick=ytick(ytick~=extray(i));
  end
end

xmax=max(xtick); xmin=min(xtick);
ymax=max(ytick); ymin=min(ytick);
xrange=abs(xmax-xmin);
yrange=abs(ymax-ymin);
xdiff=diff(xtick);
ydiff=diff(ytick);
if isempty(xdiff)
  xstr=[];
else
  ix=find(abs(xdiff-xdiff(1))<2E6*eps*xrange);
  if round((xmax-xmin)/xdiff(1))==length(ix),
    xstr=[num2str(xmin), ':', num2str(xdiff(1)), ':', num2str(xmax)];
  else
    xstr=[];
  end
end
if isempty(ydiff)
  ystr=[];
else
  iy=find(abs(ydiff-ydiff(1))<2E6*eps*yrange);
  if round((ymax-ymin)/ydiff(1))==length(iy),
    ystr=[num2str(ymin), ':', num2str(ydiff(1)), ':', num2str(ymax)];
  else
    ystr=[];
  end
end

