function [GridHandles, TextHandles] = nyqchart(ax,varargin)
%NYQCHART  Generates Nyquist grid (M and N circles).
%
%   [GRIDHANDLES,TEXTHANDLES] = NYQCHART(AX)  plots the Nyquist grid
%   in the axes AX.  NYQCHART uses the current axis limits.
%
%   [GRIDHANDLES,TEXTHANDLES] = NYQCHART(AX,OPTIONS) specifies additional
%   grid options.  OPTION is a structure with fields:
%     * MagnitudeUnits  : 'abs' or dB'
%     * FrequencyUnits: 'rad/sec' or 'Hz' (default = rad/sec)
%     * Zlevel        : real scalar (default = 0)
%
%   See also NYQUIST.

%   Authors: Adam W. DiVergilio, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:14:49 $

% Defaults
Options = gridopts('nyquist');

% Incorporate user-specified options
if nargin>1 && isa(varargin{1},'struct')
   s = varargin{1};
   for f=fieldnames(s)'
      Options.(f{1}) = s.(f{1});
   end
end
FrequencyUnits = Options.FrequencyUnits;
Zlevel  = Options.Zlevel;

% Graphics parameters
Color   = get(ax,'XColor');
TColor  = localTextColor(ax);
FSize   = get(ax,'FontSize');
FWeight = get(ax,'FontWeight');
FAngle  = get(ax,'FontAngle');

%---Draw new grid
if strcmp(Options.MagnitudeUnits,'abs')
   % Display natural gain 
   unitstr = '';
   M = [5 3 2 1.5 1.25 .8 .6 .4 .2];
   MA = M;
   UnitGain = 1;
else
   % Display magnitude in dB
   unitstr = 'dB';
   M = [2 4 6 10 20];  % lines where |L/(1+L)| = M dB
   M = [M -M];
   MA = 10.^(M/20);
   UnitGain = 0;
end
p = 2*pi*(0:1/128:1);
x = sin(p);
y = cos(p);

% Label positions
% REVISIT: move label to top border when calculated positions are outside axes limits
MA2 = MA.^2;
r = abs(MA./(1-MA2)); % M circle radii 
c = MA2./(1-MA2);     % M circle centers (x coordinate)

%---0dB line
Xlim = get(ax,'Xlim');
Ylim = get(ax,'Ylim');
GridHandles = line(...
   'Parent',ax,...
   'XData',[-.5 -.5],...
   'YData',Ylim,...
   'Color',Color,...
   'LineStyle',':',...
   'XlimInclude','off','YlimInclude','off',...
   'HandleVisibility','off','HitTest','off');
TextHandles = text(...
   'Parent',ax,...
   'Units','data',...
   'Position',[-.5 0],...
   'String',sprintf('%0.3g %s',UnitGain,unitstr),...
   'Hor','right',...
   'Ver','top',...
   'FontSize',FSize,...
   'FontWeight',FWeight,...
   'FontAngle',FAngle,...
   'Clipping','on',...
   'Color',TColor,...
   'XlimInclude','off','YlimInclude','off',...
   'HandleVisibility','off','HitTest','off');
xt = get(TextHandles,'Extent');
set(TextHandles,'Position',[-.5 Ylim(2)-0.5*xt(4)],...
   'HorizontalAlignment','center','VerticalAlignment','top');

%---Other mag values
minr = 0.01 * (Xlim(2)-Xlim(1)+Ylim(2)-Ylim(1));
for n=length(M):-1:1
   GridHandles(n+1,1) = line(...
      'Parent',ax,...
      'XData',r(n)*x+c(n),...
      'YData',r(n)*y,...
      'Color',Color,...
      'LineStyle',':',...
      'Tag','CSTgridLines',...
      'XlimInclude','off','YlimInclude','off',...
      'HandleVisibility','off','HitTest','off');
   TextHandles(n+1,1) = text(...
      'Parent',ax,...
      'Units','data',...
      'Position',[0 0],...
      'String',sprintf('%0.3g %s',M(n),unitstr),...
      'FontSize',FSize,...
      'FontWeight',FWeight,...
      'FontAngle',FAngle,...  
      'Clipping','on',...
      'Color',TColor,...
      'Tag','CSTgridLines',...
      'XlimInclude','off','YlimInclude','off',...
      'HandleVisibility','off','HitTest','off');
   % Adjust label position
   if r(n)<minr
      set(TextHandles(n+1),'Position',[NaN NaN])   % too small to label
   else
      xt = get(TextHandles(n+1),'Extent');
      [pos,hor,ver] = localLabelPos(c(n),r(n),Xlim,Ylim,xt(3),xt(4));
      set(TextHandles(n+1),'Position',pos,'HorizontalAlignment',hor,'VerticalAlignment',ver);
   end
end


%%%%%%%%%%%%%%%%%%
% localTextColor %
%%%%%%%%%%%%%%%%%%
function C = localTextColor(Ax)
%---Determine good color for grid text in axes Ax
C  = get(Ax,'XColor'); 
AC = get(Ax,'Color');
if isstr(AC), AC = get(get(Ax,'Parent'),'Color'); end
if sum(AC)>1.5
   C = C*0.5;
else
   C = C + 0.5*([1 1 1]-C);
end


%%%%%%%%%%%%%%%%%
% localLabelPos %
%%%%%%%%%%%%%%%%%
function [pos,hor,ver] = localLabelPos(xc,r,Xlim,Ylim,dx,dy)
% Positions labels

% Default (optimal) position is (xc,+r) 
pos = [xc,r];
hor = 'center';   
ver = 'bottom';

% Adjust position if default pos. is out of visible window
if xc>Xlim(1) & xc<Xlim(2) & r>Ylim(1) & r<Ylim(2)
   % Label is in scope. Adjust alignment
   if xc<=Xlim(1)+dx/2
      hor = 'left';
   elseif xc>=Xlim(2)-dx/2
      hor = 'right';
   end
   if r>=Ylim(2)-dy,   
      ver = 'top';
   end
else
   % Find intersection of M circle with x=Xlim lines that lie within Ylim range
   t = r^2 - (Xlim-xc).^2;
   idx = find(t>=0);
   t = sqrt(t(:,idx));
   xy1 = [Xlim(:,idx) Xlim(:,idx);t -t];
   xy1 = xy1(:,xy1(2,:)>Ylim(1) & xy1(2,:)<Ylim(2));
   
   % Find intersection of M circle with y=Ylim lines that lie within Xlim range
   t = r^2 - Ylim.^2;
   idx = find(t>=0);
   t = sqrt(t(:,idx));
   xy2 = [xc+t xc-t;Ylim(:,idx) Ylim(:,idx)];
   xy2 = xy2(:,xy2(1,:)>Xlim(1) & xy2(1,:)<Xlim(2));
   
   % Move to intersection point closest to optimal position
   xy = [xy1 xy2];
   if isempty(xy)
      return   % M circle does not intersect visible window: leave position unchanged
   end
   ang = atan2(xy(2,:),xy(1,:)-xc);
   [junk,imin] = min(abs(ang-pi/2));
   pos = xy(:,imin)';
   
   % Shift way from border and set alignment
   xshift = 0.2;
   if abs(pos(1)-Xlim(1))<dx
      hor = 'left';
      pos(1) = pos(1) + xshift*dx;
   elseif abs(pos(1)-Xlim(2))<dx
      hor = 'right';
      pos(1) = pos(1) - xshift*dx;
   end
   yshift = 0.5;
   if abs(pos(2)-Ylim(1))<dy
      ver = 'bottom';
      pos(2) = pos(2) + yshift*dy;
   elseif abs(pos(2)-Ylim(2))<dy
      ver = 'top';
      pos(2) = pos(2) - yshift*dy;
   end
end    


