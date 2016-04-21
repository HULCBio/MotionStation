function reparent(this,Axes)
%REPARENT  Remaps @waveform to new HG axes grid.
 
%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:19 $

if nargin<2
   % Get current curve->axes map
   Axes = getaxes(this);  % size = [Ny Nu nr nc] where [nr nc]=subplot size
else
   % Passing full axes grid -> take row and column indices into account
   Axes = Axes(this.RowIndex,this.ColumnIndex,:,:);
end
nax = prod(size(Axes));
if nax==0
   % g138403
   return
end

% Reparent @waveform's view objects (@view instances)
% REVISIT: ::reparent(this,Axes)
for vct = 1:length(this.View)
   viewHandles  = ghandles(this.View(vct));  
   % viewHandles has size [Ny Nu nr nc nobj] or [Ny Nu nobj] if nr*nc=1
   nobj = prod(size(viewHandles))/nax;
   viewHandles  = reshape(viewHandles,nax,nobj);
   for ct=1:nax
      isValid = ishandle(viewHandles(ct,:));
      set(viewHandles(ct,isValid), 'Parent', Axes(ct));
   end
end

% Reparent characteristics objects
for c = this.Characteristics'
   reparent(c,Axes);
end
