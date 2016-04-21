function dlg_sort_uicontrols( fig )
%DLG_SORT_UICONTROLS( FIG )

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9.2.1 $  $Date: 2004/04/15 00:57:12 $

   children = get(fig,'Children');
   ui = findobj(children,'Type','uicontrol');

   if isempty(ui) | length(ui)==1, return; end

   value = zeros(size(children))+inf;
   uiPos = get(ui,'Position');
   uiPos = [uiPos{:}];
   posX = uiPos(1:4:end);
   posX = max(posX)-posX;
   posY = uiPos(2:4:end);
   for i = 1:length(ui)
      index = find(children==ui(i));
      switch get(ui(i),'Style')
      case 'edit'
         value(index) = posY(i)*(2^(ceil(log2(posY(i)))+1)) + posX(i);
      case 'popupmenu'
         value(index) = posY(i)*(2^(ceil(log2(posY(i)))+1)) + posX(i);
      case 'checkbox'
         value(index) = posY(i)*(2^(ceil(log2(posY(i)))+1)) + posX(i);
      case 'pushbutton'
         value(index) = posY(i)*(2^(ceil(log2(posY(i)))+1)) + posX(i);
      otherwise
      end
   end
   [h,i] = sort(value);
   sortedChildren = children(i);
   set(fig,'Children',sortedChildren);

