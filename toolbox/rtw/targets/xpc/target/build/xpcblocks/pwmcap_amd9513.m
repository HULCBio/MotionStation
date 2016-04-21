function [MasterMode, CounterMode, Init, Runtime, Term]= ...
  pwmcap_amd9513(counter, freq_base);

% PWMCAP_AMD9513 - Mask Initialization function for PWM capturing functionality of AMD9513 based I/O-driver blocks

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:10:54 $

MasterMode.ScalerControl='BCD';

% Counter n - Measure High
CounterMode(1).Counter= num2str(counter+1);
CounterMode(1).GatingControl= 'ActiveHighLevelGateN';
CounterMode(1).CountControlSpecialGate= 'Enable';
CounterMode(1).CountControlMode= 'Repetetive';
CounterMode(1).CountControlDirection= 'Up';
CounterMode(1).CounterSource= ['F',num2str(freq_base)];

% Counter n+1 - Measure Duration
CounterMode(2).Counter=num2str(counter);
CounterMode(2).GatingControl='ActiveHighEdgeGateN';
CounterMode(2).CountControlSpecialGate='Enable';
CounterMode(2).CountControlMode='Repetetive';
CounterMode(2).CountControlDirection='Up';
CounterMode(2).CounterSource= ['F',num2str(freq_base)];

Init(1).Command= 'WriteLoad';
Init(1).Counters= ['[',num2str(counter+1),',',num2str(counter),']'];
Init(1).IO= '0';

Init(2).Command= 'WriteHold';
Init(2).Counters= ['[',num2str(counter+1),',',num2str(counter),']'];
Init(2).IO= '0';

Init(3).Command= 'LoadAndArm';
Init(3).Counters= ['[',num2str(counter+1),',',num2str(counter),']'];

Runtime(1).Command='ReadHold';
Runtime(1).Control='1';
Runtime(1).Counters=['[',num2str(counter+1),',',num2str(counter),']'];
Runtime(1).IO='p1';

Term(1).Command='Disarm';
Term(1).Counters=['[',num2str(counter+1),',',num2str(counter),']'];












