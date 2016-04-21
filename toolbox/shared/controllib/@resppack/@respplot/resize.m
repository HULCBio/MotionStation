function resize(this,NewOutputNames,NewInputNames)
%RESIZE  Reconfigures plot given new set of collective I/O names.

%   Author: P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:42 $
AxGrid = this.AxesGrid;
OldSize = AxGrid.Size;

% Account for fixed-size plots
[hasFixedRowSize,hasFixedColSize] = hasFixedSize(this);
if hasFixedRowSize
   RowSize = OldSize(1);
   NewOutputNames = {};
else
   RowSize = length(NewOutputNames);
end
if hasFixedColSize
   ColSize = OldSize(2);
   NewInputNames = {};
else
   ColSize = length(NewInputNames);
end

% Resize if necessary
NewSize = [RowSize ColSize OldSize(3:end)];
if ~isequal(NewSize,OldSize)
   % Axes grid needs to be resized
   % 1) Reparent all responses to first axes (other axes may be deleted
   %    when downsizing)
   Axes = getaxes(AxGrid);
   Axes = Axes(ones(OldSize));
   for r=allwaves(this)'
      r.reparent(Axes)
   end
   % 2) Resize the axes grid
   AxGrid.Size = NewSize;
   % 3) Tatoo new HG axes
   ax = allaxes(this);
   for ct=1:prod(size(ax))
      setappdata(ax(ct),'WaveRespPlot',this)
   end
   % 4) Update plot's I/O-related properties (no listeners to prevent
   %    errors due to partial update)
   set(this.Listeners,'Enable','off')
   this.InputName = NewInputNames;
   this.OutputName = NewOutputNames;
   if ~hasFixedColSize
      this.InputVisible = repmat({'on'},[NewSize(2) 1]);  % RE: already reset in axes grid
   end
   if ~hasFixedRowSize
      this.OutputVisible = repmat({'on'},[NewSize(1) 1]);
   end
   if all(NewSize([1 2])==1)
      this.IOGrouping = 'none';
   end
   set(this.Listeners,'Enable','on')
   % 5) Update plot labels
   rclabel(this)
else
   % Just updates I/O names (cf. geck 84020)
   this.InputName = NewInputNames;
   this.OutputName = NewOutputNames;
end

% Relocate responses in axes grid
for r=allwaves(this)'
   localize(r)
end