function d=depth(p)
%DEPTH returns the depth of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:31 $

allHandles=p.h;
if length(allHandles)>1
   d=-2*ones(1,length(allHandles));
   fullCells=1;
   cellIndices=[1:length(allHandles)];
   
   while ~isempty(fullCells)
      allHandles=get(allHandles,'Parent');
      
      emptyCells=find(cellfun('isempty',allHandles));
      fullCells=setxor(emptyCells,cellIndices);
      
      d(fullCells)=d(fullCells)+1;
      if ~isempty(emptyCells)
         [allHandles{emptyCells}]=deal(0);
      end
      allHandles=[allHandles{:}];
   end
else
   d=-3;
   while ~isempty(allHandles)
      d=d+1;
      allHandles=get(allHandles,'Parent');
   end
end
