% $Revision: 1.1.6.1 $
% $Date: 2004/02/11 19:36:20 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_reusable.mdl

% Define parameter objects

k1 = Simulink.Parameter; 
k1.RTWInfo.StorageClass = 'SimulinkGlobal'; 
k1.set('Value',2, ...
		 'Description',  'k1 gain', ...
		 'Min',      -2, ...
		 'Max',      2, ...
		 'DocUnits', 'm/(s^2)');


