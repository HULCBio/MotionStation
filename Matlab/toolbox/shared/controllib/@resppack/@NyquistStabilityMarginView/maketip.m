function str = maketip(this,tip,info)
%MAKETIP  Build data tips for NyquistStabilityMarginView Characteristics.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:15 $
h = info.Carrier.Parent; % plot handle
% UDDREVISIT
str = maketip_p(this,tip,info,h.FrequencyUnits,h.MagnitudeUnits,h.PhaseUnits);
