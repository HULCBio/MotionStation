function val = get(A, varargin)
%FRAMERECT/GET Get framerect property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/01/15 21:12:45 $

theHGBin = A.hgbin;

if nargin == 2
   switch varargin{1}
   case 'MaxLine'
      val = A.MaxLine;
   case 'MinLine'
      val = A.MinLine;      
   case 'MinWidth'
      val = A.MinWidth;
   case 'Figure'  % dup of axischild
      HG = get(A,'MyHGHandle');
      AX= get(HG,'Parent');
      val = get(AX,'Parent');
   case 'Axis'    % dup of axischild
      HG = get(A,'MyHGHandle');
      val= get(HG,'Parent');
   case 'Position'
      HG = get(A,'MyHGHandle');
      X = get(HG,'XData');
      Y = get(HG,'YData');
      val = [min(X)  min(Y) max(X)-min(X)  max(Y)-min(Y)];
   case 'MinX'
      HG = get(A,'MyHGHandle');
      val = min(get(HG,'XData'));
   case 'MaxX'
      HG = get(A,'MyHGHandle');
      val = max(get(HG,'XData'));
   case 'MinY'
      HG = get(A,'MyHGHandle');
      val = min(get(HG,'YData'));
   case 'MaxY'      
      HG = get(A,'MyHGHandle');
      val = max(get(HG,'YData'));
   otherwise
      val = get(theHGBin, varargin{:});
   end
else
   val = get(theHGBin, varargin{:});
end

