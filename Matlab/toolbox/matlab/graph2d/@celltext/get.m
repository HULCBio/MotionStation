function val = get(A, varargin)
%CELLTEXT/GET Get celltext property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:13 $

axistextObj = A.axistext;

if nargin == 2
   switch varargin{1}
   case 'FontSize'
      val = A.FontSize;
   case 'Position'
      val = get(axistextObj, 'Extent');
   otherwise
      val = get(axistextObj, varargin{:});
   end
else
   val = get(axistextObj, varargin{:});
end
