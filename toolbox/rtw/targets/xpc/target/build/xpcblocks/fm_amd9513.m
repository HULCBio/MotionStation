function [MasterMode, CounterMode, Init, Runtime, Term]= ...
  fm_amd9513(counter, freq_base, initfreq, duty, togglestart);

% FM_AMD9513 - Mask Initialization function for FM functionality of AMD9513 based I/O-driver blocks

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 04:01:30 $


relDuration= 1/initfreq;
initLoad= duty*relDuration;
initHold= relDuration-initLoad;

MasterMode.ScalerControl='BCD';

CounterMode(1).Counter= num2str(counter);
CounterMode(1).CountControlReload= 'LoadOrHold';
CounterMode(1).CountControlMode= 'Repetetive';
CounterMode(1).OutputControl= 'TCToggled';
CounterMode(1).CounterSource= ['F',num2str(freq_base)];

Init(1).Command= 'WriteLoad';
Init(1).Counters= num2str(counter);
Init(1).IO= num2str(initLoad);

Init(2).Command= 'WriteHold';
Init(2).Counters= num2str(counter);
Init(2).IO= num2str(initHold);

Init(3).Command= 'Load';
Init(3).Counters= num2str(counter);

if togglestart==1
  Init(4).Command= 'ClearToggle';
elseif togglestart==2
  Init(4).Command= 'SetToggle';
end
Init(4).Counters= num2str(counter);

Init(5).Command= 'Arm';
Init(5).Counters= num2str(counter);


Runtime(1).Command= 'WriteLoad';
Runtime(1).Control= '1';
Runtime(1).Counters= num2str(counter);
Runtime(1).IO= 'p1';

Runtime(2).Command= 'WriteHold';
Runtime(2).Control= '1';
Runtime(2).Counters= num2str(counter);
Runtime(2).IO= 'p2';

Term(1).Command= 'Disarm';
Term(1).Counters= num2str(counter);

















