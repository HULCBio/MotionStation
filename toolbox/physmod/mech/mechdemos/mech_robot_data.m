% Data defining the manutec robot.

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/06/27 18:43:01 $

Actuator{1}.MotorGain = 1.1616;
Actuator{1}.MotorConstant = 4590;
Actuator{1}.MotorDamping = 0.6;
Actuator{1}.MotorInertia = 0.0013;
Actuator{1}.GearRatio = -105;
Actuator{1}.ShaftStiffness = 43;
Actuator{1}.ShaftDamping = 0.005;
Actuator{1}.FrictionConstant = 0.4;
Actuator{1}.FrictionGain = 0.13/160;
Actuator{1}.PeakRatio = 1.01;
Actuator{1}.Axis = [0 1 0];

Actuator{2}.MotorGain = 1.1616;
Actuator{2}.MotorConstant = 5500;
Actuator{2}.MotorDamping = 0.6;
Actuator{2}.MotorInertia = 0.0013;
Actuator{2}.GearRatio = 210;
Actuator{2}.ShaftStiffness = 8;
Actuator{2}.ShaftDamping = 0.01;
Actuator{2}.FrictionConstant = 0.5;
Actuator{2}.FrictionGain = 0.1/130;
Actuator{2}.PeakRatio = 1.01;
Actuator{2}.Axis = [1 0 0];

Actuator{3}.MotorGain = 1.1616;
Actuator{3}.MotorConstant = 5500;
Actuator{3}.MotorDamping = 0.6;
Actuator{3}.MotorInertia = 0.0013;
Actuator{3}.GearRatio = 60;
Actuator{3}.ShaftStiffness = 58;
Actuator{3}.ShaftDamping = 0.04;
Actuator{3}.FrictionConstant = 0.7;
Actuator{3}.FrictionGain = 0.2/130;
Actuator{3}.PeakRatio = 1.01;
Actuator{3}.Axis = [1 0 0];

Actuator{4}.MotorGain = 0.2365;
Actuator{4}.MotorConstant = 6250;
Actuator{4}.MotorInertia = 1.6e-4;
Actuator{4}.MotorDamping = 0.55;
Actuator{4}.GearRatio = -99;
Actuator{4}.FrictionConstant = 21.8/abs(Actuator{4}.GearRatio);
Actuator{4}.FrictionGain = 9.8/Actuator{4}.GearRatio^2;
Actuator{4}.PeakRatio = 26.7/21.8;
Actuator{4}.Axis = [0 1 0];

Actuator{5}.MotorGain = 0.2608;
Actuator{5}.MotorConstant = 6250;
Actuator{5}.MotorDamping = 0.55;
Actuator{5}.MotorInertia = 1.8e-4;
Actuator{5}.GearRatio = 79.2;
Actuator{5}.FrictionConstant = 30.1/abs(Actuator{5}.GearRatio);
Actuator{5}.FrictionGain = 0.03/Actuator{5}.GearRatio^2;
Actuator{5}.PeakRatio = 39.6/30.1;
Actuator{5}.Axis = [1 0 0];

Actuator{6}.MotorGain = 0.0842;
Actuator{6}.MotorConstant = 7400;
Actuator{6}.MotorDamping = 0.27;
Actuator{6}.MotorInertia = 4.3e-5;
Actuator{6}.GearRatio = -99;
Actuator{6}.FrictionConstant = 10.9/abs(Actuator{6}.GearRatio);
Actuator{6}.FrictionGain = 3.92/Actuator{6}.GearRatio^2;
Actuator{6}.PeakRatio = 16.8/10.9;
Actuator{6}.Axis = [0 1 0];




