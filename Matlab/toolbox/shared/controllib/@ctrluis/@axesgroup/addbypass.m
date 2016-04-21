function addbypass(this)
%ADDBYPASS  Installs bypass for basic graphics functions.
%
%   Traps calls to TITLE, GRID,... applied to data axes.

%   Author(s): Adam DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:00 $

axgrid = this.Axes2d;
for n=1:prod(size(axgrid))
   setappdata(axgrid(n),'MWBYPASS_grid',  {@localGrid,  this})
   setappdata(axgrid(n),'MWBYPASS_title', {@localTitle, this})
   setappdata(axgrid(n),'MWBYPASS_xlabel',{@localXlabel this n})
   setappdata(axgrid(n),'MWBYPASS_ylabel',{@localYlabel this n})
   setappdata(axgrid(n),'MWBYPASS_axis',{@localAxis this axgrid(n)})
end

%----------------- Local Functions -----------------------

%%%%%%%%%%%%%%
% localTitle %
%%%%%%%%%%%%%%
function htitle = localTitle(this,string,varargin)
this.Title = string;
htitle = hglabel(this,'Title');
if ~isempty(varargin)
   set(htitle,varargin{:});
   % Sync style
   localSyncLabel(htitle,this.TitleStyle)
end


%%%%%%%%%%%%%%%
% localXlabel %
%%%%%%%%%%%%%%%
function hlabel = localXlabel(this,AxesIndex,string,varargin)
hlabel = hglabel(this,'XLabel');

if this.Size(4)==1
   this.XLabel = string;
else
   ax = getaxes(this,'2d');
   [i,j] = ind2sub(size(ax),AxesIndex);
   j = 1+rem(j-1,this.Size(4));
   this.XLabel{j} = string;
end

if ~isempty(varargin)
   set(hlabel,varargin{:});
   localSyncLabel(hlabel,this.XLabelStyle)
end


%%%%%%%%%%%%%%%
% localYlabel %
%%%%%%%%%%%%%%%
function hlabel = localYlabel(this,AxesIndex,string,varargin)
hlabel = hglabel(this,'YLabel');

if this.Size(3)==1
   this.Ylabel = string;
else
   ax = getaxes(this,'2d');
   [i,j] = ind2sub(size(ax),AxesIndex);
   i = 1+rem(i-1,this.Size(3));
   % this.YLabel{i} = string;
   tmp = this.YLabel; tmp{i} = string; this.YLabel = tmp; % REVISIT
end

if ~isempty(varargin)
   set(hlabel,varargin{:});
   localSyncLabel(hlabel,this.YLabelStyle)
end


%%%%%%%%%%%%%
% localGrid %
%%%%%%%%%%%%%
function localGrid(this,opt_grid)
if ((opt_grid == 0) & strcmpi(this.Grid,'on')) | strcmp(opt_grid,'off')
   this.Grid = 'off';
else
   this.Grid = 'on';
end


%%%%%%%%%%%%%
% localAxis %
%%%%%%%%%%%%%
function out = localAxis(this,ax,varargin)
WarnStr = 'This plot type does not support this option for the AXIS command.';
switch length(varargin)
case 0
   % If no input arguments are given, return limits
   out = [get(ax,'XLim') get(ax,'YLim')];
case 1
   if isnumeric(varargin{1})
      % AXIS([XMIN XMAX YMIN YMAX])
      newlims = varargin{1};
      set(ax,'Xlim',newlims(1:2),'YLim',newlims(3:4))
   elseif any(strcmp(varargin{1},{'auto','manual'}))
      % AXIS AUTO or AXIS MANUAL
      this.XLimMode = varargin{1};
      this.YLimMode = varargin{1};
   elseif strcmp(varargin{1},'normal') && prod(this.Size)==1
      % AXIS NORMAL (return to full view)
      this.XLimMode = 'auto';
      this.YLimMode = 'auto';
   elseif strcmp(varargin{1},'equal') && prod(this.Size)==1
      % AXIS EQUAL (supported for, e.g., root locus)
      localAxisEqual(ax)
   else
      warning(WarnStr)
   end
otherwise
   warning(WarnStr)
end   


%%%%%%%%%%%%%%%%%%
% localSyncLabel %
%%%%%%%%%%%%%%%%%%
function localSyncLabel(h,labstyle)
h = handle(h);
labstyle.Color = h.Color;
labstyle.FontAngle = h.FontAngle;
labstyle.FontSize = h.FontSize;
labstyle.FontWeight = h.FontWeight;
labstyle.Interpreter = h.Interpreter;


%%%%%%%%%%%%%%%%%%
% localAxisEqual %
%%%%%%%%%%%%%%%%%%
function localAxisEqual(ax)
units = get(ax,'Units');
if ~strcmpi(units,'pixels')
   set(ax,'Units','pixels');
   p = get(ax,'Position');
   set(ax,'Units',units);
else
   p = get(ax,'Position');
end
Xlim = get(ax,'Xlim');
Ylim = get(ax,'Ylim');
%---Pixel extent
px = p(3);
py = p(4);
%---Data extent
dx = abs(diff(Xlim)); 
dy = abs(diff(Ylim));
%---Effective extent
xf = dx*py;
yf = dy*px;
%---Update limits
if xf>yf
   %---Effective Xlim is larger, adjust Ylim
   dd = xf/px-dy;
   Ylim = [Ylim(1)-dd/2 Ylim(2)+dd/2];
   set(ax,'Ylim',Ylim);
elseif yf>xf
   %---Effective Ylim is larger, adjust Xlim
   dd = yf/py-dx;
   Xlim = [Xlim(1)-dd/2 Xlim(2)+dd/2];
   set(ax,'Xlim',Xlim);
end
