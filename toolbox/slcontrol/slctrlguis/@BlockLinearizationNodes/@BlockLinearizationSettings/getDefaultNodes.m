function nodes = getDefaultNodes(this)
% GETDEFAULTNODES  Return list of required component names.

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.4 $  $Date: 2004/04/11 00:35:20 $

% Define list of required components for objects of this class
nodes = [GenericLinearizationNodes.Views('initialize')];
