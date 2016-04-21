function [gridlines,labels] = zpchart(ax,varargin)
%ZPCHART  Generates the z-plane grid lines
%
%    [GRIDLINES,LABELS] = ZPCHART(AX) plots z-plane grid lines 
%    on the axes AX.  The range and spacing of the natural 
%    frequencies and damping ratios is determined automatically
%    based on the axes limits of AX.  GRIDLINES and LABELS
%    contain the handles for the lines and labels of the plotted
%    grid.
%
%    [GRIDLINES,LABELS] = ZPCHART(AX,ZETA,WN) plots an z-plane 
%    grid on the axes AX for the set of damping ratios and natural 
%    frequencies specified in ZETA and WN, respectively.
%
%    [GRIDLINES,LABELS] = SPCHART(AX,OPTIONS) specifies all the
%    grid parameters in the structure OPTIONS.  Valid fields
%    (parameters) include:
%       Damping: vector of damping rations
%       Frequency: vector of frequencies
%       FrequencyUnits = '[ Hz | {rad/sec} ]';
%       GridLabelType  = '[ {damping} | overshoot ]';
%       SampleTime     = '[ real scalar | {-1} ]';
%
%    Note that if frequency units of 'Hz' have been specified and
%    WN have been provided, then it is assumed that the WN values
%    are provided in units of 'Hz'.
%
%    See also PZMAP, ZGRID.

%   Revised: Adam DiVergilio, 11-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 04:43:07 $

%---Initialize return values
gridlines = [];
labels = [];

% Defaults
Options = gridopts('pzmap');

% Incorporate user-specified options
switch nargin
case 2
   % ZPCHART(AX,OPTIONS)
   s = varargin{1};
   for f=fieldnames(s)'
      Options.(f{1}) = s.(f{1});
   end
case 3
   % ZPCHART(AX,ZETA,WN)
   Options.Damping = varargin{2};
   Options.Frequency = varargin{3};
end
zeta = Options.Damping;
wn = Options.Frequency;
Ts = Options.SampleTime;
FrequencyUnits = Options.FrequencyUnits;
LimInclude  = Options.LimInclude;
Zlevel  = Options.Zlevel;

%---Axes info
XLIM = get(ax,'XLim');
YLIM = get(ax,'YLim');
dXLIM = diff(XLIM);
dYLIM = diff(YLIM);
ContainsXAxis = YLIM(1)<=0 & YLIM(2)>=0;
ContainsYAxis = XLIM(1)<=0 & XLIM(2)>=0;
ContainsOrigin = ContainsXAxis & ContainsYAxis;
Color = get(ax,'XColor');
LColor = Color;
TColor = localTextColor(ax);
FontSize = get(ax,'FontSize');
FontWeight = get(ax,'FontWeight');
FontAngle = get(ax,'FontAngle');

%---Plot unit circle (always include)
t = 0:2*pi/100:2*pi;
unitcircle = line('Parent',ax,...
   'XData',sin(t),'YData',cos(t),'Zdata',Zlevel(:,ones(length(t),1)),...
   'LineStyle','-','Color',LColor,...
   'Tag','CSTgridLines','HitTest','off',...
   'HandleVisibility','off','HelpTopicKey','isodampinggrid');

% Construct zeta, wn vectors
if all(isfinite(zeta)) & all(isfinite(wn))
   %---User-defined damping ratios and natural frequencies
   %---Make sure we are working with sorted rows
   zeta = sort(reshape(zeta,[1 length(zeta)]));
   zeta = zeta(:,zeta>=0 & zeta<=1);
   zeta(:,zeta<10*eps) = 0;  % round extremely small zeta values to zero
   wn = sort(reshape(wn,[1 length(wn)]));
   wn = unitconv(wn,FrequencyUnits,'rad/sec');  % Work in 'rad/sec'
   wn = wn(:,wn>0 & wn<=pi);
   %---Must have at least one zeta and one wn value to continue
   if isempty(zeta) & isempty(wn)
      % Return handle of unit circle only
      gridlines = unitcircle(:);
      return
   end
   %---Build strings for wn values (used in place of pi/T fractions)
   wns = cell(length(wn),1);
   for n=1:length(wn)
      wns{n} = sprintf('%0.3g',unitconv(wn(n),'rad/sec',FrequencyUnits));  % Show in requested units
   end
   
else
   %---Default damping ratios and natural frequencies
   zeta = .1:.1:.9;
   wn = pi/10:pi/10:pi;
   if Ts>0
      for n=1:length(wn)
         wns{n} = sprintf('%0.3g',unitconv(wn(n)/Ts,'rad/sec',FrequencyUnits));
      end
   else
      if strcmpi(FrequencyUnits,'Hz')
         wns = {'0.05/T','0.10/T','0.15/T','0.20/T','0.25/T',...
               '0.30/T','0.35/T','0.40/T','0.45/T','0.50/T'};
      else
         wns = {'0.1\pi/T','0.2\pi/T','0.3\pi/T','0.4\pi/T','0.5\pi/T',...
               '0.6\pi/T','0.7\pi/T','0.8\pi/T','0.9\pi/T','\pi/T'};
      end
   end
end
wns = strrep(wns,'+00','');
wns = strrep(wns,'+0','');

%---Plot zeta lines (damping)
m = tan(asin(zeta)) + i;
zzeta = [exp((0:pi/100:pi)'*(-m)); NaN*ones(size(zeta))];
zzeta = zzeta(:);
rzzeta = real(zzeta);
izzeta = imag(zzeta);
zetalines = line('Parent',ax,...
   'XData',[rzzeta; rzzeta],'YData',[izzeta; -izzeta],'Zdata',Zlevel(ones(2*length(rzzeta),1),:),...
   'LineStyle',':','Color',LColor,...
   'Tag','CSTgridLines','HitTest','off','HandleVisibility','off',...
   'XlimInclude',LimInclude,'YlimInclude',LimInclude,'HelpTopicKey','isodampinggrid');

%---Plot wn lines (natural frequency)
e_itheta = exp(i * (pi/2:pi/50:pi)');
e_r = exp(wn);
zwn = [(ones(length(e_itheta),1)*e_r).^(e_itheta*ones(size(e_r))); NaN*ones(size(e_r))];
zwnc = zwn(:);
rzwn = real(zwnc);
izwn = imag(zwnc);
wnlines = line('Parent',ax,...
   'XData',[rzwn; rzwn],'YData',[izwn; -izwn],'Zdata',Zlevel(ones(2*length(rzwn),1),:),...
   'LineStyle',':','Color',LColor,...
   'Tag','CSTgridLines','HitTest','off','HandleVisibility','off',...
   'XlimInclude',LimInclude,'YlimInclude',LimInclude,'HelpTopicKey','isofrequencygrid');

%---Return handles of new gridlines
gridlines = [wnlines(:); zetalines(:); unitcircle(:)];

%---Limits may have changed due to axis autoscaling,
%--- so requery limits prior to placing text
XLIM = get(ax,'XLim');
YLIM = get(ax,'YLim');
dXLIM = diff(XLIM);
dYLIM = diff(YLIM);
ContainsXAxis = YLIM(1)<=0 & YLIM(2)>=0;
ContainsYAxis = XLIM(1)<=0 & XLIM(2)>=0;
ContainsOrigin = ContainsXAxis & ContainsYAxis;

%---Construct wn midpoint information (for zeta label positioning)
%---Create wn vector which contains 0,pi
wntmp = [0 wn(:,wn<pi) pi];
%---Vector of midpoints between plotted wn lines
wnmid = (wntmp(1:end-1)+wntmp(2:end))/2;
%---Coordinates of wnmid on z-plane
e_itheta = exp(i * (pi/2:pi/50:pi)');
e_r = exp(wnmid);
zwnmid = [(ones(length(e_itheta),1)*e_r).^(e_itheta*ones(size(e_r)))];

%---If y=0 line is showing, draw frequency labels above and below x-axis
if ContainsXAxis
   wn = [wn wn];
   zwn = [zwn conj(zwn)];
   wns = [wns wns];
   wnmid = [wnmid wnmid];
   zwnmid = [zwnmid conj(zwnmid)];
   %---If only negative y-values are showing, only draw frequency labels below x-axis
elseif YLIM(2)<0
   zwn = conj(zwn);
   zwnmid = conj(zwnmid);
end

%---Space fraction from axes edge
edge = 0.015;

%---Space fraction of axes used to determine label crowding
crowdlim = 1/6;

%---Try to find a label position for each wn value
for n=1:length(wn)
   %---Find coordinates of wn line which lie within axes limits
   wnz = zwn(~isnan(zwn(:,n)),n);
   idx = find((real(wnz)>=XLIM(1))&(real(wnz)<=XLIM(2))&...
      (imag(wnz)>=YLIM(1))&(imag(wnz)<=YLIM(2)));
   %---Initialize label position
   wnx = [];
   wny = [];
   %---If this wn line is visible, add label at position set by wn and axes limits
   if ~isempty(idx)
      %---Visible coordinate along wn which is closest to unit circle
      firstvis = idx(1);
      %---If unit circle is shown at this wn, use it for label position
      if firstvis==1
         wnx = real(wnz(1));
         wny = imag(wnz(1));
         dx = real(wnz(2))-wnx;
         dy = imag(wnz(2))-wny;
         slp = dy/dx;
         if     wn(n)>pi/2, HA = 'left';
         elseif wn(n)<pi/2, HA = 'right';
         else,              HA = 'center';
         end
         %---Otherwise, interpolate a point along axes edge
      else
         w1 = wnz(firstvis-1);
         w2 = wnz(firstvis);
         x = [real(w1) real(w2)];
         y = [imag(w1) imag(w2)];
         dx = diff(x);
         dy = diff(y);
         slp = dy/dx;
         if y(1)>(YLIM(2)-dYLIM*edge)
            if ~(ContainsXAxis & abs(YLIM(2)/dYLIM)<crowdlim)
               wny = YLIM(2)-dYLIM*edge;
               wnx = x(1) + (wny-y(1))/slp;
               HA = 'center';
            end
         elseif y(1)<(YLIM(1)+dYLIM*edge)
            if ~(ContainsXAxis & abs(YLIM(1)/dYLIM)<crowdlim)
               wny = YLIM(1)+dYLIM*edge;
               wnx = x(1) + (wny-y(1))/slp;
               HA = 'center';
            end
         elseif x(1)<XLIM(1)+dXLIM*edge;
            if ~(ContainsYAxis & abs(XLIM(1)/dXLIM)<crowdlim)
               wnx = XLIM(1)+dXLIM*edge;
               wny = y(1) + (wnx-x(1))*slp;
               HA = 'left';
            end
         else %--- x(1)>XLIM(2)-dXLIM*edge
            if ~(ContainsYAxis & abs(XLIM(2)/dXLIM)<crowdlim)
               wnx = XLIM(2)-dXLIM*edge;
               wny = y(1) + (wnx-x(1))*slp;
               HA = 'right';
            end
         end
      end
      %---Select vertical alignment based on dy (slope in y)
      if dy<=0, VA = 'top';
      else,     VA = 'bottom';
      end
   end
   %---Draw label if valid coordinate was determined
   if ~isempty(wnx)
      tpos = [wnx wny];
      tpos(:,3) = Zlevel;
      labels(length(labels)+1) = text(...
         'Units','data','Position',tpos,'String',wns(n),...
         'Parent',ax,'Color',TColor,'FontSize',FontSize,'FontWeight',FontWeight,'FontAngle',FontAngle,...
         'Clipping','on','Rotation',0,'HorizontalAlignment',HA,'VerticalAlignment',VA,...
         'Tag','CSTgridLines','HitTest','off','HandleVisibility','off',...
         'XlimInclude','off','YlimInclude','off','HelpTopicKey','isofrequencygrid');
   end
end

%---If the default locations for zeta labels is visible, use them
wndef = 3.5*pi/10;
zzdef = exp(wndef*(-zeta + i*sqrt(1-zeta.^2)));
zzdefr = real(zzdef);
zzdefi = imag(zzdef);
zzdefin = -zzdefi;
if all(zzdefr>=XLIM(1) & zzdefr<=XLIM(2) & zzdefi>=YLIM(1) & zzdefi<=YLIM(2)) | ...
      all(zzdefr>=XLIM(1) & zzdefr<=XLIM(2) & zzdefin>=YLIM(1) & zzdefin<=YLIM(2))
   wnzeta = wndef;
   
   %---Otherwise, select most-visible vector from wnmid values
else
   %---Create vector of values representing visible zeta range of each wnmid vector
   for n=1:length(wnmid)
      %---Find coordinates of wnmid line which lie within axes limits
      wnz = zwnmid(:,n);
      idx = find((real(wnz)>=XLIM(1))&(real(wnz)<=XLIM(2))&...
         (imag(wnz)>=YLIM(1))&(imag(wnz)<=YLIM(2)));
      if isempty(idx)
         zdiff(n) = 0;
      else
         %---Visible coordinate along wnmid which is closest to unit circle
         zmin = real((-((log(wnz(idx(1)))).^2)-(wnmid(n)).^2)./(2*wnmid(n)*log(wnz(idx(1)))));
         %---Visible coordinate along wnmid which is farthest from unit circle
         zmax = real((-((log(wnz(idx(end)))).^2)-(wnmid(n)).^2)./(2*wnmid(n)*log(wnz(idx(end)))));
         %---Fix round-off error
         if abs(zmin)<10*eps,   zmin = 0; end
         if abs(1-zmax)<10*eps, zmax = 1; end
         %---Visible zeta range
         zdiff(n) = zmax-zmin;
      end
   end
   %---wnmid value associated with max(zdiff) is where the zeta labels should go
   [tmp,zidx] = max(zdiff);
   wnzeta = wnmid(zidx);
end

%---Draw zeta labels
if abs(YLIM(2))>=abs(YLIM(1))
   wnzetasign = 1;
else
   wnzetasign = -1;
end
zz = exp(wnzeta*(-zeta + i*sqrt(1-zeta.^2)));
if strcmpi(Options.GridLabelType,'overshoot')
   dispzeta = exp(-(zeta*pi)./sqrt(1-zeta.*zeta));
   dispzeta = round(1e5*dispzeta)/1e3; % round off small values
else
   dispzeta = zeta;
end
for n=1:length(zeta)
   tpos = [real(zz(n)) wnzetasign*imag(zz(n))];
   tpos(:,3) = Zlevel;
   labels(length(labels)+1) = text(...
      'Units','data','Position',tpos,...
      'String',sprintf('%0.3g',dispzeta(n)),...
      'Parent',ax,'Color',TColor,'FontSize',FontSize,'FontWeight',FontWeight,'FontAngle',FontAngle,...
      'Clipping','on','Rotation',0,'HorizontalAlignment','center','VerticalAlignment','middle',...
      'Tag','CSTgridLines','HitTest','off','HandleVisibility','off',...
      'XlimInclude','off','YlimInclude','off','HelpTopicKey','isodampinggrid');
end

%---Return handles of new labels
labels = labels(:);

%---Restack axes children so that grid lines/labels are on bottom
if Zlevel==0
   AllKids = allchild(ax);
   BotKids = [labels;gridlines];
   TopKids = AllKids(~strcmp(get(AllKids,'Tag'),'CSTgridLines'));
   set(ax,'Children',[TopKids(:);BotKids(:)]);
end

%%%%%%%%%%%%%%%%%%
% localTextColor %
%%%%%%%%%%%%%%%%%%
function C = localTextColor(Ax)
%---Determine good color for grid text in axes Ax
C  = get(Ax,'XColor');
AC = get(Ax,'Color');
if isstr(AC), 
   AC = get(get(Ax,'Parent'),'Color'); 
end
if sum(AC)>1.5
   C = C*0.5;
else
   C = C + 0.5*([1 1 1]-C);
end
