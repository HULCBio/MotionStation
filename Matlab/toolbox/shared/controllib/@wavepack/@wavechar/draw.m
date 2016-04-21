function draw(this,NoCheckFlag)
%DRAW  Draw method for @wavechar objects.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:01 $
if nargin==1 & ~isvisible(this)
   return
end

% Update data 
if ~isempty(this.DataFcn)
   feval(this.DataFcn{:});
end

% Draw the @view objects that are visible
wf = this.Parent;  % parent @waveform
NormalRefresh = strcmp(this.RefreshMode,'normal');
VisibleView = strcmp(get(this.View, 'Visible'), 'on');
for ct = find(VisibleView)'
   if this.Data(ct).Exception
      % Invalid data: clear graphics
      ghndls = double(ghandles(this.View(ct)));
      set(ghndls(ishandle(ghndls)),'XData',[],'YData',[],'ZData',[])
   else
      % Valid data: proceed with draw
      this.View(ct).draw(this.Data(ct),NormalRefresh);
      this.View(ct).applystyle(wf.Style,wf.RowIndex,wf.ColumnIndex,ct);
   end
end