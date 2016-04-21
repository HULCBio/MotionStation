function wf = allwaves(this)
%ALLWAVES  Collects all @waveform components.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:50 $
wf = [this.Responses;this.Input];

