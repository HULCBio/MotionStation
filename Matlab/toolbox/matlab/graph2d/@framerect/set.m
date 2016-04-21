function A = set(A, varargin)
%FRAMERECT/SET Set framerect property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:46 $

if nargin == 3
   items = get(A,'items');
   switch varargin{1}
   case 'MaxLine'
      A.MaxLine = varargin{2};
   case 'MinLine'
      A.MinLine = varargin{2};      
   case {'HorizontalAlignment' 'VerticalAlignment'}
      for anItem = items
	 set(anItem,varargin{:})
      end
   case 'IsSelected'
      selected = get(A,'IsSelected');
      hgbinObj = A.hgbin;
      A.hgbin = set(hgbinObj, 'IsSelected', varargin{2});
      myH = get(A,'MyHandle');
      figH = get(A,'Figure');
      figObjH = getobj(figH);
      if ~isempty(figObjH)
	 dragBinH = figObjH.DragObjects;
	 if varargin{2}
	    A = set(A,'Selected','on');
	    % A = set(A,'FaceColor',[1 1 0]);
	    dragBinH.NewItem = myH;
	 else
	    A = set(A,'Selected','off');
	    % A = set(A,'FaceColor','w');
	    dragBinH.RemoveItem = myH;	    
	 end
      end
   case 'Position'
      HG = get(A,'MyHGHandle');
      position = varargin{2};
      minX = position(1);
      maxX = minX + position(3);
      minY = position(2);
      maxY = minY + position(4);
      set(HG, ...
	      'XData', [minX minX maxX maxX],...
	      'YData', [minY maxY maxY minY]);
%      for anItem = items
%	 set(anItem,varargin{:});
%      end
      % wierd behavior if setting min greater than max...
   case 'MinX'
      HG = get(A,'MyHGHandle');
      X = get(HG,'XData');
      X(find(X==min(X))) = varargin{2};
      set(HG,'XData',X);
      for anItem = items
	 set(anItem,varargin{:});
      end
   case 'MaxX'
      HG = get(A,'MyHGHandle');
      X = get(HG,'XData');
      X(find(X==max(X))) = varargin{2};
      set(HG,'XData',X);
      for anItem = items
	 set(anItem,varargin{:});
      end
   case 'MinY'
      HG = get(A,'MyHGHandle');
      Y = get(HG,'YData');
      Y(find(Y==min(Y))) = varargin{2};
      set(HG,'YData',Y);
      for anItem = items
	 set(anItem,varargin{:});
      end
   case 'MaxY'      
      HG = get(A,'MyHGHandle');
      Y = get(HG,'YData');
      Y(find(Y==max(Y))) = varargin{2};
      set(HG,'YData',Y);
      for anItem = items
	 set(anItem,varargin{:});
      end
   otherwise
      theBin = A.hgbin;
      A.hgbin = set(theBin, varargin{:});
   end
else
   theBin = A.hgbin;
   A.hgbin = set(theBin, varargin{:});
end
