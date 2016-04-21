function val = get(A, varargin)
%AXISOBJ/GET Get axisobj property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:11:43 $  

HGObj = A.scribehgobj;

if nargin == 2
   switch varargin{1}
   case 'Figure'
      HG = get(A,'MyHGHandle');
      val = get(HG,'Parent');
  case 'Axis'  % really, the overlay axis...
      HG = get(A,'MyHGHandle');
      fig = get(HG,'Parent');
      axH = findall(fig,'type','axes');
      if ~isempty(axH)
          val = double(find(handle(axH),'-class','graph2d.annotationlayer'));
          if isempty(val)
              val = findall(axH,'flat','Tag','ScribeOverlayAxesActive');
          end
      else
          val=[];
      end
  case 'ZoomScale'
      val = A.ZoomScale;
  otherwise
      val = get(HGObj, varargin{:});
   end
else
   val = get(HGObj, varargin{:});
end


