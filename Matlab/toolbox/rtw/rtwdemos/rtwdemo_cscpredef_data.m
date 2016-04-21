% $Revision: 1.1.6.2 $
% $Date: 2004/04/11 00:15:27 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_cscpredef.mdl

clear;

temp=Simulink.Signal;
temp.RTWInfo.StorageClass= 'Custom';
temp.RTWInfo.CustomStorageClass= 'Struct';

pressure=Simulink.Signal;
pressure.RTWInfo.StorageClass= 'Custom';
pressure.RTWInfo.CustomStorageClass= 'Struct';

O2=Simulink.Signal;
O2.RTWInfo.StorageClass= 'Custom';
O2.RTWInfo.CustomStorageClass= 'Struct';

rpm=Simulink.Signal;
rpm.RTWInfo.StorageClass= 'Custom';
rpm.RTWInfo.CustomStorageClass= 'Struct';

tempalarm=Simulink.Signal;
tempalarm.RTWInfo.StorageClass= 'Custom';
tempalarm.RTWInfo.CustomStorageClass= 'BitField';

pressurealarm=Simulink.Signal;
pressurealarm.RTWInfo.StorageClass= 'Custom';
pressurealarm.RTWInfo.CustomStorageClass= 'BitField';

O2alarm=Simulink.Signal;
O2alarm.RTWInfo.StorageClass= 'Custom';
O2alarm.RTWInfo.CustomStorageClass= 'BitField';

rpmalarm=Simulink.Signal;
rpmalarm.RTWInfo.StorageClass= 'Custom';
rpmalarm.RTWInfo.CustomStorageClass= 'BitField';

templimit=Simulink.Parameter;
templimit.RTWInfo.StorageClass= 'Custom';
templimit.RTWInfo.CustomStorageClass= 'ConstVolatile';
templimit.Value = 202.0;

pressurelimit=Simulink.Parameter;
pressurelimit.RTWInfo.StorageClass= 'Custom';
pressurelimit.RTWInfo.CustomStorageClass= 'ConstVolatile';
pressurelimit.Value = 45.2;

O2limit=Simulink.Parameter;
O2limit.RTWInfo.StorageClass= 'Custom';
O2limit.RTWInfo.CustomStorageClass= 'ConstVolatile';
O2limit.Value = 0.96;

rpmlimit=Simulink.Parameter;
rpmlimit.RTWInfo.StorageClass= 'Custom';
rpmlimit.RTWInfo.CustomStorageClass= 'ConstVolatile';
rpmlimit.Value = 7400.0;


