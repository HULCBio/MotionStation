% $Revision: 1.1.4.1 $
% $Date: 2004/04/11 00:15:29 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%
% Abstract:
%   Data for rtwdemo_slbus.mdl

clear;

BusObject = Simulink.Bus;
BusObject.Description = 'This bus contains sensor measurements';

e1 = Simulink.BusElement;
e1.DataType = 'double';
e1.Name = 'temperature';

e2 = Simulink.BusElement;
e2.DataType = 'double';
e2.Name = 'heat';

e3 = Simulink.BusElement;
e3.DataType = 'double';
e3.Name = 'pressure';
e3.Dimensions = 20;

BusObject.Elements = [e1 e2 e3];


BusObject1 = Simulink.Bus;
BusObject.Description = 'This bus contains actuator commands';

e4 = Simulink.BusElement;
e4.DataType = 'boolean';
e4.Name = 'relay';

e5 = Simulink.BusElement;
e5.DataType = 'double';
e5.Name = 'angle';

BusObject1.Elements = [e4 e5];


BusObject2 = Simulink.Bus;
BusObject2.Description = 'This bus contains mode logic signals';

e6 = Simulink.BusElement;
e6.DataType = 'boolean';
e6.Name = 'loaded';

e7 = Simulink.BusElement;
e7.DataType = 'boolean';
e7.Name = 'advanced';

BusObject2.Elements = [e6 e7];

clear e1 e2 e3 e4 e5 e6 e7







