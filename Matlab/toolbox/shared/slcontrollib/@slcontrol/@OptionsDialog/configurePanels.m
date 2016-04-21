function configurePanels(this)
% CONFIGUREPANELS 

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:45 $

% Simulation related handles
this.SimOptionHandles   = struct( 'Panel', this.Dialog.getSimOptionPanel );

% Optimization related handles
this.OptimOptionHandles = struct( 'Panel', this.Dialog.getOptimOptionPanel);
