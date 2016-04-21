function resize(this, NewChannelNames)
% RESIZE Reconfigures plot given new set of collective channel names.

% Author: P. Gahinet
% Revised: Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:40 $

AxGrid = this.AxesGrid;
OldSize = AxGrid.Size;

% Account for fixed-size plots
[hasFixedRowSize,hasFixedColSize] = hasFixedSize(this);
if hasFixedRowSize
  RowSize = OldSize(1);
  NewChannelNames = {};
else
  RowSize = length(NewChannelNames);
end

% Resize if necessary
NewSize = [RowSize 1 OldSize(3:end)];
if ~isequal(NewSize, OldSize)
  % Axes grid needs to be resized
  % 1) Reparent all responses to first axes (other axes may be deleted
  %    when downsizing)
  Axes = getaxes(AxGrid);
  Axes = Axes(ones(OldSize));
  for r = allwaves(this)'
    r.reparent(Axes)
  end
  
  % 2) Resize the axes grid
  AxGrid.Size = NewSize;
  
  % 3) Tatoo new HG axes
  ax = allaxes(this);
  for ct = 1:prod( size(ax) )
    setappdata( ax(ct), 'WaveRespPlot', this )
  end
  
  % 4) Update plot's I/O-related properties (no listeners to prevent
  %    errors due to partial update)
  set( this.Listeners,'Enable','off' )
  this.ChannelName = NewChannelNames;
  if ~hasFixedRowSize
    this.ChannelVisible = repmat( {'on'}, [ NewSize(1) 1 ] );
    % RE: already reset in axes grid
  end
  if all( NewSize([1 2]) == 1 )
    this.ChannelGrouping = 'none';
  end
  set(this.Listeners,'Enable','on')
  
  % 5) Update plot labels
  rclabel(this)
else
  % Just updates I/O names (cf. geck 84020)
  this.ChannelName = NewChannelNames;
end

% Relocate responses in axes grid
for r = allwaves(this)'
  localize(r)
end
