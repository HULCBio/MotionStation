% $Revision: 1.1.6.1 $
% $Date: 2004/02/11 19:36:19 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_paraminline

T1Break = Simulink.Parameter;
T1Break.RTWInfo.StorageClass = 'Auto';
T1Break.Value = [-5:5];

T1Data = Simulink.Parameter;
T1Data.RTWInfo.StorageClass = 'Auto';
T1Data.Value = [-1,-0.99,-0.98,-0.96,-0.76,0,0.76,0.96,0.98,0.99,1];

T2Break = Simulink.Parameter;
T2Break.RTWInfo.StorageClass = 'Auto';
T2Break.Value = [1:3];

T2Data = Simulink.Parameter;
T2Data.RTWInfo.StorageClass = 'Auto';
T2Data.Value = [4 5 6;16 19 20;10 18 23];

MAX_LIFT = Simulink.Parameter;
MAX_LIFT.RTWInfo.StorageClass = 'Auto';
MAX_LIFT.Value = 10;

SLIDER_POS = Simulink.Parameter;
SLIDER_POS.RTWInfo.StorageClass = 'Auto';
SLIDER_POS.Value = 0;
