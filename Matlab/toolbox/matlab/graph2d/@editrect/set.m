function A = set(A, varargin)
%EDITRECT/SET Set editrect property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:12:28 $


myBin = A.Objects;

lArgin = varargin;
while length(lArgin) >= 2,
   prop = lArgin{1};
   val = lArgin{2};

   lArgin = lArgin(3:end);

   switch prop
   case 'NewItem'
      myBin.NewItem = val;
   case 'EraseMode'
      editlineObj = A.editline;
      A.editline = set(editlineObj, prop, val);
      for anObjH = myBin.Items
         set(anObjH, prop, val);
      end
   case 'XYData'
      oldX = get(A,'XData');
      oldY = get(A,'YData');
      editlineObj = A.editline;
      A.editline = set(editlineObj, 'XData', val{1}, 'YData', val{2});
      newX = get(A,'XData');
      newY = get(A,'YData');
      % normalized move...
      dX = newX-oldX;
      dY = newY-oldY;
      dX = dX(find(dX));
      dY = dY(find(dY));
      fMove = length(dX)==4 | length(dY)==4;
      if fMove
         for anObjH = myBin.Items
            X = get(anObjH,'XData');
            Y = get(anObjH,'YData');
            if ~isempty(dX)
               X = X + dX(1);
            end
            if ~isempty(dY)
               Y = Y + dY(1);
            end
            set(anObjH,'XYData', {X Y});
         end
      else % resize
         width=range(oldX);
         height=range(oldY);
         left=min(oldX);
         bottom=min(oldY);
         for anObjH = myBin.Items
            X = get(anObjH,'XData');
            Y = get(anObjH,'YData');
            if ~isempty(dX)            
               X = X + dX(1)*(mean(X)-left)/width;
            end
            if ~isempty(dY)
               Y = Y + dY(1)*(mean(Y)-bottom)/height;
            end
            set(anObjH,'XYData',{X Y});

         end
      end
   case {'XData' 'YData'}
      oldX = get(A,'XData');
      oldY = get(A,'YData');
      editlineObj = A.editline;
      A.editline = set(editlineObj, varargin{:});
      newX = get(A,'XData');
      newY = get(A,'YData');
      % normalized move...
      dX = newX-oldX;
      dY = newY-oldY;
      dX = dX(find(dX));
      dY = dY(find(dY));
      fMove = length(dX)==4 | length(dY)==4;
      if fMove
         myBin.Items
         for anObjH = myBin.Items
            if ~isempty(dX)
               X = get(anObjH,'XData');
               X = X + dX(1);
               set(anObjH,'XData',X);
            end
            if ~isempty(dY)
               Y = get(anObjH,'YData');
               Y = Y + dY(1);
               set(anObjH,'YData',Y);
            end
         end
      else % resize
         width=range(oldX);
         height=range(oldY);
         left=min(oldX);
         bottom=min(oldY);
         for anObjH = myBin.Items
            if ~isempty(dX)
               X = get(anObjH,'XData');
               X = X + dX(1)*(mean(X)-left)/width;
               set(anObjH,'XData',X);
            end
            if ~isempty(dY)
               Y = get(anObjH,'YData');
               Y = Y + dY(1)*(mean(Y)-bottom)/height;
               set(anObjH,'YData',Y);
            end
         end
      end

   otherwise
      editlineObj = A.editline;
      A.editline = set(editlineObj, varargin{:});
   end
end





