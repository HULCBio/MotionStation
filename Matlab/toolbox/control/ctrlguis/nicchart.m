function [varargout] = nicchart(varargin)
%NICCHART  Generates the Nichols grid.
%
%    [PHASE,GAIN,LABELS] = NICCHART(PMIN,PMAX,GMIN) generates the
%    data for plotting the Nichols chart. PMIN and PMAX specify the
%    phase interval in degrees and GMIN is the smallest gain in dB.  
%    NICCHART returns
%      * PHASE and GAIN: grid data
%      * LABELS: three-row matrix containing the x,y positions 
%                and the label values
%
%    [GRIDHANDLES,TEXTHANDLES] = NICCHART(AX)  plots the Nichols chart 
%    in the axis AX.  NICCHART uses the current axis limits.
%
%    [GRIDHANDLES,TEXTHANDLES] = NICCHART(AX,OPTIONS) specifies additional
%    grid options.  OPTION is a structure with fields:
%      * PhaseUnits: 'deg' or 'rad' (default = deg)
%      * Zlevel    : real scalar (default = 0)
%
%    See also NICHOLS, NGRID.

%   Authors: K. Gondoly and P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2004/04/10 23:14:48 $

% Note: GMIN is assumed to be in dB  
ni = nargin;
NanMat = NaN;

% Defaults
Options = gridopts('nichols');
if ni==2 && isa(varargin{2},'struct')
   s = varargin{2};
   for f=fieldnames(s)'
      Options.(f{1}) = s.(f{1});
   end
end
PhaseUnits = Options.PhaseUnits;
LimInclude  = Options.LimInclude;
Zlevel  = Options.Zlevel;

% Framing
if ni==3
   [pmin,pmax,gmin] = deal(varargin{1:3});
else
   ax = varargin{1};
   % Bounding rectangle PMIN,PMAX,GMIN
   Xlim = get(ax,'Xlim');
   Ylim = get(ax,'Ylim');
   pmin = Xlim(1);
   pmax = Xlim(2);
   gmin = Ylim(1);
end

% Unit conversion
pmin = unitconv(pmin,PhaseUnits,'deg');
pmax = unitconv(pmax,PhaseUnits,'deg');

% Round Gmin from below to nearest multiple of -20dB,
% and Pmin,Pmax to nearest multiple of 360
gmin = min([-20 20*floor(gmin/20)]);
pmax = 360*ceil(pmax/360);
pmin = min(pmax-360,360*floor(pmin/360));

% (1) Generate isophase lines for following phase values:
p1 = [1 5 10 20 30 50 90 120 150 180];

% Gain points (in dB)
g1 = [6 3 2 1 .75 .5 .4 .3 .25 .2 .15 .1 .05 0 -.05 -.1 ...
      -.15 -.2 -.25 -.3 -.4 -.5 -.75 -1 -2 -3 -4 -5 -6 -9 ...
      -12 -16 -20:-10:max(-40,gmin) gmin(:,gmin<-40)];

% Compute gains GH and phases PH in H plane
[p,g] = meshgrid((pi/180)*p1,10.^(g1/20)); % in H/(1+H) plane
z = g .* exp(j*p);
H = z./(1-z);
gH = 20*log10(abs(H));
pH = rem((180/pi)*angle(H)+360,360);

% Add phase lines for angle between 180 and 360 (using symmetry)
gH = [gH , gH];
pH = [pH , 360-pH];

% Each column of GH/PH corresponds to one phase line
% Pad with NaN's and convert to vector
m = size(gH,2);
gH = [gH ; NanMat(1,ones(1,m))];
pH = [pH ; NanMat(1,ones(1,m))];
gain = gH(:);   phase = pH(:);

% (2) Generate isogain lines for following gain values:
g2 = [6 3 1 .5 .25 0 -1 -3 -6 -12 -20 -40:-20:gmin];

% Phase points
p2 = [1 2 3 4 5 7.5 10 15 20 25 30 45 60 75 90 105 ...
      120 135 150 175 180];
p2 = [p2 , fliplr(360-p2(1:end-1))];

[g,p] = meshgrid(10.^(g2/20),(pi/180)*p2);  % mesh in H/(1+H) plane
z = g .* exp(j*p);
H = z./(1-z);
gH = 20*log10(abs(H));
pH = rem((180/pi)*angle(H)+360,360);

% Each column of GH/PH describes one gain line
% Pad with NaN's and convert to vector
m = size(gH,2);
gH = [gH ; NanMat(1,ones(1,m))];
pH = [pH ; NanMat(1,ones(1,m))];
gain = [gain ; gH(:)];
phase = [phase ; pH(:)];

% Replicate Nichols chart if necessary
lp = length(phase);
dn = round((pmax-pmin)/360);     % number of 360 degree windup
gain = repmat(gain,dn,1);
phase = repmat(phase,dn,1);
shift = kron(pmin+360*(0:dn-1)',ones(lp,1));
ix = find(~isnan(phase));
phase(ix) = phase(ix) + shift(ix);
pH = pH + shift(end);

% Generate label output
labels = [pH(end-1,:) ; gH(end-1,:) ; g2];

if ni>=3
   % Return data only
   varargout = {phase,gain,labels};
else
   phase = unitconv(phase,'deg',PhaseUnits);
   labels(1,:) = unitconv(labels(1,:),'deg',PhaseUnits);
   
   % Plot grid
   Color   = get(ax,'XColor');
   TColor  = localTextColor(ax);
   FSize   = get(ax,'FontSize');
   FWeight = get(ax,'FontWeight');
   FAngle  = get(ax,'FontAngle');
   GridHandles(1,1) = line(phase, gain, Zlevel(ones(length(gain),1),:), ...
      'XlimInclude',LimInclude,'YlimInclude',LimInclude,...
      'LineStyle', ':', 'Color', Color, ...
      'Parent', ax, 'Tag', 'CSTgridLines', ...
      'HandleVisibility', 'off', 'HitTest', 'off');
   pcr = unitconv((pmin+180):360:pmax,'deg',PhaseUnits);
   gcr = ones(1,length(pcr))*0;
   GridHandles(2,1) = line(pcr, gcr, Zlevel(ones(length(gcr),1),:), ...
      'XlimInclude',LimInclude,'YlimInclude',LimInclude,...
      'LineStyle', 'none', 'Marker', '+', 'Color', Color, ...
      'Parent', ax, 'Tag', 'CSTgridLines', ...
      'HandleVisibility', 'off', 'HitTest', 'off');
   TextHandles = zeros(size(labels,2),1);
   Zpos = Zlevel(:,ones(length(labels(1,:)),1));
   for jloop = 1:length(TextHandles)
      TextHandles(jloop) = text(labels(1,jloop), labels(2,jloop), Zpos(jloop), ...
         sprintf(' %.3g dB', labels(3,jloop)), ...
         'Parent', ax, 'Color', TColor, ...
         'XlimInclude','off','YlimInclude','off',...
         'FontWeight', FWeight, 'FontAngle', FAngle, ...
         'FontSize', FSize, ...
         'Tag', 'CSTgridLines', ...
         'HandleVisibility', 'off', 'HitTest', 'off');
   end
   
   % Position grid labels to multiple of 360 degree nearest to
   % rightmost X limit
   Xlim = get(ax,'Xlim');
   Ylim = get(ax,'Ylim');
   twopi = unitconv(360,'deg',PhaseUnits);
   DesiredX = twopi * round((0.02*Xlim(1)+0.98*Xlim(2))/twopi);  % desired position
   TextPositions = get(TextHandles,{'Position'});
   CurrentX = twopi * round(TextPositions{1}(1)/twopi);
   ShiftX = DesiredX-CurrentX;
   for h=TextHandles(:)'
      Position = get(h,'Position');
      NewPosition = [Position(1)+ShiftX , Position(2:end)];
      if prod(NewPosition(1)-Xlim)<0 & ...
            prod(NewPosition(2)-Ylim)<0,
         % Label within current axis limits
         set(h,'Position',NewPosition,'Visible','on')
      else
         set(h,'Position',NewPosition,'Visible','off')
      end
      
      % Change anchor point if label lies outside of axes limit
      ex = get(h,'Extent');
      if ex(1)+ex(3)>Xlim(2), 
         set(h,'HorizontalAlignment','right'); 
      end
      if ex(2)<Ylim(1), 
         set(h,'VerticalAlignment','bottom');  
      end
      if ex(2)+ex(4)>Ylim(2), 
         set(h,'VerticalAlignment','top');     
      end
   end
   varargout = {GridHandles,TextHandles};
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
