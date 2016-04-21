function A = set(A, varargin)
%CELLTEXT/SET Set celltext property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:12:14 $


if nargin == 3
   switch varargin{1}
   case {'MinX' 'MaxX'}
      HG = get(A,'MyHGHandle');      
      A = LUpdatePosition(A,HG,'x');
   case {'MinY' 'MaxY'}
      HG = get(A,'MyHGHandle');
      A = LUpdatePosition(A,HG,'y');      
   case 'HorizontalAlignment'
      HG = get(A,'MyHGHandle');
      set(HG,'HorizontalAlignment',varargin{2});
      A.HorizontalAlignment = varargin{2};
      A = LUpdatePosition(A,HG,'x');
   case 'VerticalAlignment'
      HG = get(A,'MyHGHandle');
      set(HG,'VerticalAlignment',varargin{2});      
      A.VerticalAlignment = varargin{2};
      A = LUpdatePosition(A,HG,'y');
   case 'FontSize'
      ax = get(A,'Axis');
      HG = get(A,'MyHGHandle');
      axObj = getobj(ax);
      scale = get(axObj,'ZoomScale');
      size = varargin{2};
      set(HG,'FontSize',size*scale);
      A.FontSize = size;
   case 'ZoomScale'
      HG = get(A,'MyHGHandle');
      scale = varargin{2};
      size = A.FontSize;
      set(HG,'FontSize',size*scale);      
   otherwise
      axistextObj = A.axistext;
      A.axistext = set(axistextObj, varargin{:});
   end
else
   axistextObj = A.axistext;
   A.axistext = set(axistextObj, varargin{:});
end


% -------------------------------
function A = LUpdatePosition(A,HG, dim)
pos = get(HG,'Position');
myFrame = get(A,'MyBin');
framePos = get(myFrame,'Position');


switch dim
case 'x'
   switch A.HorizontalAlignment
   case 'left'
      x = framePos(1)+A.CellPadding;
   case 'center'
      x = framePos(1)+framePos(3)/2;
   case 'right'
      x = framePos(1)+framePos(3)-A.CellPadding;      
   end
   pos(1) = x;
case 'y'
   switch A.VerticalAlignment
   case {'top' 'cap'}
      y = framePos(2)+framePos(4)-A.CellPadding;            
   case 'middle'
      y = framePos(2)+framePos(4)/2;      
   case {'baseline' 'bottom'}
      y = framePos(2)+A.CellPadding;      
   end
   pos(2) = y;
end
set(HG,'Position',pos);

