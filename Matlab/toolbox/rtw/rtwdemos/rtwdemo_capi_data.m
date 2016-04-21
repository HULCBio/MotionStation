% $Revision: 1.1.6.1 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   postload data for rtwdemo_capi.mdl

p1=Simulink.Parameter;
p1.Value=rand(3);
p1.Value=p1.Value(:,1);
p1.RTWInfo.StorageClass='SimulinkGlobal';

p2=Simulink.Parameter;
p2.Value=rand(2,3);
p2.RTWInfo.StorageClass='SimulinkGlobal';

p3=Simulink.Parameter;
p3.Value=rand(2,4,2);
p3.RTWInfo.StorageClass='SimulinkGlobal';

Kp       = Simulink.Parameter;
Kp.Value = 4;
Kp.RTWInfo.StorageClass ='SimulinkGlobal';

Ki       = Simulink.Parameter;
Ki.Value = 7;
Ki.RTWInfo.StorageClass ='SimulinkGlobal';

Kd       = Simulink.Parameter;
Kd.Value = 1;
Kd.RTWInfo.StorageClass ='SimulinkGlobal';

sig1_sg = Simulink.Signal;
sig1_sg.RTWInfo.StorageClass = 'SimulinkGlobal';

sig2_eg = Simulink.Signal;
sig2_eg.RTWInfo.StorageClass = 'ExportedGlobal';
