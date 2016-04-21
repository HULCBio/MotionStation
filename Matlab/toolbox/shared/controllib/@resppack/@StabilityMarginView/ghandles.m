function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a StabilityMarginView object.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:37 $
h_mag = [this.MagPoints; this.MagLines; this.MagCrossLines];
h_mag = reshape(h_mag,[1 1 1 1 length(h_mag)]);

h_phase = [this.PhasePoints; this.PhaseLines; this.PhaseCrossLines];  
h_phase = reshape(h_phase,[1 1 1 1 length(h_phase)]);

h = cat(3,h_mag,h_phase);
% REVISIT: Include line tips when handle(NaN) workaround removed
