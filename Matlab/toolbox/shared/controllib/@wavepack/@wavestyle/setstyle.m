function setstyle(this,varargin)
%SETSTYLE  User-friendy specification of  style attributes.
%
%  SETSTYLE(StyleObj,'r-x') specifies a color/linestyle/marker string.
%
%  SETSTYLE(StyleObj,'Property1',Value1,...) specifies individual style 
%  attributes.  Valid properties include Color, LineStyle, LineWidth, 
%  and Marker.

%  Author(s): P. Gahinet, Karen Gondoly
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:46 $

if nargin==2
   StyleStr = varargin{1};
   if isempty(StyleStr)
      return
   end
   [LineStyle,Color,Marker,msg] = colstyle(StyleStr);
   if ~isempty(msg)
      error(sprintf('Invalid style string "%s"',StyleStr))
   end
   Values = {Color,LineStyle,[],Marker};
else
   Props = {'Color','LineStyle','LineWidth','Marker'};
   Values = cell(1,4);
   if rem(length(varargin),2)
      error('Property names and values must come in pair.')
   end
   for ct=1:length(varargin)/2
      prop = varargin{2*ct-1};
      idx = find(strncmpi(prop,Props,length(prop)));
      if length(idx)~=1
         error('Unknown or ambiguous property "%s"',prop)
      end
      Values(idx) = varargin(2*ct);
   end
end

% Finalize settings
[Color,LineStyle,Marker,Legend] = StyleFinish(Values{[1 2 4]});

% Create style object
this.Colors = {Color};
this.LineStyles = {LineStyle};
if ~isempty(Values{3})
   this.LineWidth = Values{3};
end
this.Markers = {Marker};
this.Legend = Legend;

% Notify clients
this.send('StyleChanged')

%-------------------- Local Functions ------------------------

function [Color,LineStyle,Marker,Legend] = StyleFinish(Color,LineStyle,Marker)
% RE: All plot styles are assumed to be user specified at this point

% Load appropriate color table
rgb = isnumeric(Color) & length(Color)==3;
if rgb,
   % Colors specified as RGB triplets
   ColorTable64 = cstdefs('Color64');
else
   ColorTable8 = cstdefs('Color8');
end

% Defaults
if isempty(Color)
   Color = 'blue';
elseif strcmp(Color,'k'),
   Color = 'black';
end

% Get RGB value and text characterization for color
if rgb,
   % Identify color name
   Cstr = GetColorName(Color,ColorTable64);
else
   % Get RGB value and full name for string color (one of eight basic colors)
   Cind = find(strncmpi(Color,ColorTable8(:,2),length(Color)));
   Color = ColorTable8{Cind(1),1};
   Cstr = ColorTable8{Cind(1),2};
end

% Resolve unspecified line styles and markers
if isempty(Marker)
   Marker = 'none';
   if isempty(LineStyle)
      LineStyle = '-';
   end
elseif isempty(LineStyle),
   LineStyle = 'none';
end

% Build legend
Legend = LocalMakeLegend(Cstr,LineStyle,Marker);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function name = GetColorName(rgbcolor,ColorTable64)

if ~isa(rgbcolor,'double') | length(rgbcolor(:))~=3
   error('RGB color must be a 3 element numeric vector.')
elseif any(rgbcolor(:)<0) | any(rgbcolor(:)>1)
   error('RGB values must be between 0 and 1.')
end

% Preprocessing
if min(rgbcolor)>0.9,
   rgbcolor = [1 1 1];
elseif max(rgbcolor)<0.5
   rgbcolor = [0 0 0];
elseif max(abs(rgbcolor-mean(rgbcolor)))<0.1
   rgbcolor = mean(rgbcolor) * [1 1 1];
end

AllRGBs = cat(1,ColorTable64{:,1});
gaps = sum(abs(AllRGBs - rgbcolor(ones(length(ColorTable64),1),:)).^2,2);
[garb,imatch] = min(gaps);

name = ColorTable64{imatch,2};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LegendStr = LocalMakeLegend(Cstr,LL,MM)
%LEGDSTR  Creates color/linestyle/marker legend for Response Object menus

% Determine line style name
if get(0,'ScreenDepth')==1 % Monochrome screen
   Lind = find(strcmpi(LL,{'--';'-.';':';'-'}));
else
   % Solid = default (don't mention)
   Lind = find(strcmpi(LL,{'--';'-.';':'}));
end

if length(Lind)==1
   AllLines = {'dashed';'dash-dot';'dotted';'solid'};
   Lstr = AllLines{Lind};
else
   % Assume 'none'
   Lstr = '';
end      

% Set marker name
Mstr = MM;
if strcmp(Mstr,'none'), % Don't bother showing empty markerstyles
   Mstr = '';
end

% Construct legend string
LegendStr = Cstr;
if ~isempty(Lstr)
   LegendStr = sprintf('%s,%s',LegendStr,Lstr);
end
if ~isempty(Mstr),
   LegendStr = sprintf('%s,%s',LegendStr,Mstr);
end



