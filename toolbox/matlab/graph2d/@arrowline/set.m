function A = set(A, varargin)
%ARROWLINE/SET Set arrowline property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2004/01/15 21:11:24 $

lArgin = varargin;
while length(lArgin) >= 2,
   prop = lArgin{1};
   val = lArgin{2};

   lArgin = lArgin(3:end);
   switch prop
   case 'XYData'
      editlineObj = A.editline;
      A.editline = set(editlineObj, 'XYData', val(1:2));
   case 'XYDataRefresh'
      editlineObj = A.editline;
      A.editline = set(editlineObj, 'XYData', val(1:2));
      makearrow(A.arrowhead);
   case 'Refresh'
      makearrow(A.arrowhead);      
   case 'XData'
      editlineObj = A.editline;
      A.editline = set(editlineObj, prop, val);
      makearrow(A.arrowhead);
   case 'YData'
      editlineObj = A.editline;
      A.editline = set(editlineObj, prop, val);
      makearrow(A.arrowhead);
   case 'EraseMode'
      switch val
      case 'xor'
         set([A.fullline A.line A.arrowhead], 'EraseMode','xor');
         set([A.line A.arrowhead], 'Visible','off')
         set(A.fullline, 'LineStyle',':');
      case 'normal'
         set([A.fullline A.line A.arrowhead], ...
                 'Visible', 'on', ...
                 'EraseMode','normal');
         set(A.fullline, 'LineStyle', 'none');
      end
   case 'Color'
      set(A.line, prop, val);
      set(A.arrowhead, ...
              'FaceColor', val, ...
              'EdgeColor', val);
   case 'LineWidth'
      set(A.line, prop, val);
      makearrow(A.arrowhead);
   case {'LineStyle' 
         'Marker'
         'MarkerSize'
         'MarkerEdgeColor'
         'MarkerFaceColor'};
      set(A.line, prop, val);
   otherwise
      editlineObj = A.editline;
      A.editline = set(editlineObj, prop, val);
   end
end

