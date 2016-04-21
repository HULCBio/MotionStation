function [MasterMode, CounterMode, Init, Runtime, Term]= ...
  fmarm_amd9513(counter, freq_base, duty, initfreq, togglestart, init_arm);

% FMARM_AMD9513 - Mask Initialization function for FM and ARM functionality of AMD9513 based I/O-driver blocks

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.6.1 $ $Date: 2004/04/08 21:02:21 $

relDuration= 1/initfreq;
initLoad= duty*relDuration;
initHold= relDuration-initLoad;

MasterMode.ScalerControl='BCD';

CounterMode(1).Counter= num2str(counter);
CounterMode(1).CountControlReload= 'LoadOrHold';
CounterMode(1).CountControlMode= 'Repetetive';
CounterMode(1).OutputControl= 'TCToggled';
CounterMode(1).CounterSource= ['F',num2str(freq_base)];

Init(1).Command= 'Disarm';
Init(1).Counters= num2str(counter);

Init(2).Command= 'WriteLoad';
Init(2).Counters= num2str(counter);
Init(2).IO= num2str(initLoad);

Init(3).Command= 'WriteHold';
Init(3).Counters= num2str(counter);
Init(3).IO= num2str(initHold);

Init(4).Command= 'Load';
Init(4).Counters= num2str(counter);

if togglestart==1
  Init(5).Command= 'ClearToggle';
elseif togglestart==2
  Init(5).Command= 'SetToggle';
end
Init(5).Counters= num2str(counter);

n = 1;

Runtime(n).Command= 'WriteLoad';
Runtime(n).Control= '1';
Runtime(n).Counters= num2str(counter);
Runtime(n).IO= 'p1';
n = n+1;
Runtime(n).Command= 'WriteHold';
Runtime(n).Control= '1';
Runtime(n).Counters= num2str(counter);
Runtime(n).IO= 'p2';
n=n+1;
% ARM toggle low
Runtime(n).Command= 'ClearToggle';
Runtime(n).Control= 'p3';
Runtime(n).Counters= num2str(counter);
n=n+1;
Runtime(n).Command= 'Load';
Runtime(n).Control= 'p3';
Runtime(n).Counters= num2str(counter);
n=n+1;
Runtime(n).Command= 'Arm';
Runtime(n).Control= 'p3';
Runtime(n).Counters= num2str(counter);
n=n+1;
% ARM toggle high
Runtime(n).Command= 'SetToggle';
Runtime(n).Control= 'p4';
Runtime(n).Counters= num2str(counter);
n=n+1;
Runtime(n).Command= 'Load';
Runtime(n).Control= 'p4';
Runtime(n).Counters= num2str(counter);
n=n+1;
Runtime(n).Command= 'Arm';
Runtime(n).Control= 'p4';
Runtime(n).Counters= num2str(counter);
n=n+1;
% Disarm toggle low
Runtime(n).Command= 'Disarm';
Runtime(n).Control= 'p5';
Runtime(n).Counters= num2str(counter);
n=n+1;
Runtime(n).Command= 'ClearToggle';
Runtime(n).Control= 'p5';
Runtime(n).Counters= num2str(counter);
n=n+1;
% Disarm toggle high
Runtime(n).Command= 'Disarm';
Runtime(n).Control= 'p6';
Runtime(n).Counters= num2str(counter);
n=n+1;
Runtime(n).Command= 'SetToggle';
Runtime(n).Control= 'p6';
Runtime(n).Counters= num2str(counter);

Term(1).Command= 'Disarm';
Term(1).Counters= num2str(counter);
if togglestart==1
  Term(2).Command= 'ClearToggle';
elseif togglestart==2
  Term(2).Command= 'SetToggle';
end
Term(2).Counters= num2str(counter);

















