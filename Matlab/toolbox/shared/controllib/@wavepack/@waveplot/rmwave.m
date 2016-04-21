function rmwave(this, h)
%RMWAVE  Removes a waveform from the current wave plot.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:41 $

% Validate input argument
if ~ishandle(h)
  error('Second argument must be a valid handle.')
end

% Find position of @waveform object
idx = find(this.Waves == h);

% Delete @waveform object
if ~isempty(idx)
  delete(this.Waves(idx));
  this.Waves = this.Waves([1:idx-1, idx+1:end]);
end

% Redraw plot
draw(this)
