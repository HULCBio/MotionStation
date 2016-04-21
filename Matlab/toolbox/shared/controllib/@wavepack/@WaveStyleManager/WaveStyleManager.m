function this = WaveStyleManager
%WAVESTYLEMANAGER  Constructor for @WaveStyleManager class.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:35 $

% Create class instance
this = wavepack.WaveStyleManager;

% Compute a default set of style combinations
makestyles(this)