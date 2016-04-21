% $Revision: 1.1.6.1 $
% $Date: 2004/02/11 19:36:22 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_ssreuse

T1Break = Simulink.Parameter;
T1Break.RTWInfo.StorageClass = 'SimulinkGlobal';
T1Break.Value = [-5:5];

T1Data = Simulink.Parameter;
T1Data.RTWInfo.StorageClass = 'SimulinkGlobal';
T1Data.Value = [-1,-0.99,-0.98,-0.96,-0.76,0,0.76,0.96,0.98,0.99,1];

T2Break = copy(T1Break);
T2Data  = copy(T1Data);
T2Data.Value = [-1,-0.9,-0.7,-0.4,-0.3,0,0.3,0.4,0.7,0.9,1];

