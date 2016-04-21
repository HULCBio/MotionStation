function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a BodeStabilityMarginView object.

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:52 $

h_mag = [this.MagVLine; this.MagAxVLine; this.Mag180VLine; this.ZeroDBLine];
h_mag = reshape(h_mag,[1 1 1 1 length(h_mag)]);

h_phase = [this.PhaseVLine; this.PhaseAxVLine; this.Phase0DBVLine; this.PhaseCrossLine];  
h_phase = reshape(h_phase,[1 1 1 1 length(h_phase)]);

h = cat(3,h_mag,h_phase);