function blockH = chart2block(chartID)
% BLOCK2CHART returns the Simulink block handle for a Stateflow chart ID

%   J. Breslau
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:56:06 $

    blockH = sf('get', sf('get', chartID, 'chart.instances'), 'instance.simulinkBlock');