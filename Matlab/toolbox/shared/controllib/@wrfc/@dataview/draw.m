function draw(this)
%DRAW  Default implementation of DRAW method.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:00 $
if strcmp(this.Visible, 'off')
   return
end
NormalRefresh = strcmp(this.RefreshMode,'normal');

% Update data 
if ~isempty(this.DataFcn)
   feval(this.DataFcn{:});
end

% Draw the @view objects that are visible
VisibleView = strcmp(get(this.View, 'Visible'), 'on');
for ct = find(VisibleView)'
   this.View(ct).draw(this.Data(ct),NormalRefresh);
end
