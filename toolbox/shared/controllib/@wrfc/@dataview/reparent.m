function reparent(this,Axes)
%REPARENT  Remaps @dataview to new HG axes grid.
 
%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:05 $

% Reparent view objects (@view instances)
nax = prod(size(Axes)); 
for vct = 1:length(this.View)
   viewHandles  = ghandles(this.View(vct));  
   % viewHandles has size [Nr Nc nr nc nobj] or [Nr Nc nobj] if nr*nc=1
   % (nr and nc are the subgrid dimensions)
   nobj = prod(size(viewHandles))/nax;
   viewHandles  = reshape(viewHandles,nax,nobj);
   for ct=1:nax
      isValid = ishandle(viewHandles(ct,:));
      set(viewHandles(ct,isValid), 'Parent', Axes(ct));
   end
end