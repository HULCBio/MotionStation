function [io, mm, cms, initir, ir, termir]=mamd9513parse(mastermode, countermode, init, commands, term)

% MAMD9513PARSE - Mask initialization function for AMD9513 based driver blocks

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 04:08:49 $

% MasterMode
if isempty(mastermode)
  mm=[];
else
  if ~isfield(mastermode,'ScalerControl')
    mastermode.ScalerControl='Binary';
  end
  if ~isfield(mastermode,'DataPointerControl')
    mastermode.DataPointerControl='Enable';
  end
  if ~isfield(mastermode,'DataBusWidth')
    mastermode.DataBusWidth='8';
  end
  if ~isfield(mastermode,'FOUTGate')
    mastermode.FOUTGate='On';
  end
  if ~isfield(mastermode,'FOUTDivider')
    mastermode.FOUTDivider='16';
  end
  if ~isfield(mastermode,'FOUTSource')
    mastermode.FOUTSource='F1';
  end
  if ~isfield(mastermode,'Comparator2')
    mastermode.Comparator2='Disable';
  end
  if ~isfield(mastermode,'Comparator1')
    mastermode.Comparator1='Disable';
  end
  if ~isfield(mastermode,'TimeOfDayMode')
    mastermode.TimeOfDayMode='Disable';
  end
  
  mm=0;
  
  idx= strmatch(lower(mastermode.ScalerControl),{'binary','bcd'},'exact');
  if isempty(idx)
    error('Invalid ScalerControl value defined');
  end
  mm=mm + bitshift(idx-1,15);
  idx= strmatch(lower(mastermode.DataPointerControl),{'enable','disable'},'exact');
  if isempty(idx)
    error('Invalid DataPointerControl value defined');
  end
  mm=mm + bitshift(idx-1,14);
  idx= strmatch(lower(mastermode.DataBusWidth),{'8','16'},'exact');
  if isempty(idx)
    error('Invalid DataBusWidth value defined');
  end
  mm=mm + bitshift(idx-1,13);
  idx= strmatch(lower(mastermode.FOUTGate),{'on','off'},'exact');
  if isempty(idx)
    error('Invalid FOUTGate value defined');
  end
  mm=mm + bitshift(idx-1,12);
  idx= strmatch(lower(mastermode.FOUTDivider),{'16','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'},'exact');
  if isempty(idx)
    error('Invalid FOUTDivider value defined');
  end
  mm=mm + bitshift(idx-1,8);
  idx= strmatch(lower(mastermode.FOUTSource),{'e1','src1','src2','src3','src4','src5','gate1','gate2','gate3','gate4','gate5','f1','f2','f3','f4','f5'},'exact');
  if isempty(idx)
    error('Invalid FOUTSource value defined');
  end
  mm=mm + bitshift(idx-1,4);
  idx= strmatch(lower(mastermode.Comparator2),{'disable','enable'},'exact');
  if isempty(idx)
    error('Invalid Comparator2 value defined');
  end
  mm=mm + bitshift(idx-1,3);
  idx= strmatch(lower(mastermode.Comparator1),{'disable','enable'},'exact');
  if isempty(idx)
    error('Invalid Comparator1 value defined');
  end
  mm=mm + bitshift(idx-1,2);
  idx= strmatch(lower(mastermode.TimeOfDayMode),{'disable','enable5','enable6','enable10'},'exact');
  if isempty(idx)
    error('Invalid TimeOfDayMode value defined');
  end
  mm=mm + idx-1;
  
end  


% CounterMode

if isempty(countermode)
  cms=[];
else
  cms= -1* ones(1,5);
  for i=1:length(countermode)
    counterm= countermode(i);
    if ~isfield(counterm,'Counter') | isempty(counterm.Counter)
      error('Fieldname ''Counter'' is undefined');
    end
    counter= str2num(counterm.Counter);
    if ~isfield(counterm,'GatingControl') | isempty(counterm.GatingControl)
      counterm.GatingControl='None';
    end
    if ~isfield(counterm,'SourceEdge') | isempty(counterm.SourceEdge)
      counterm.SourceEdge='Rising';
    end
    if ~isfield(counterm,'CounterSource') | isempty(counterm.CounterSource)
      counterm.CounterSource='F1';
    end
    if ~isfield(counterm,'CountControlSpecialGate') | isempty(counterm.CountControlSpecialGate)
      counterm.CountControlSpecialGate='Disable';
    end
    if ~isfield(counterm,'CountControlReload') | isempty(counterm.CountControlReload)
      counterm.CountControlReload='Load';
    end
    if ~isfield(counterm,'CountControlMode') | isempty(counterm.CountControlMode)
      counterm.CountControlMode='Once';
    end
    if ~isfield(counterm,'CountControlScaler') | isempty(counterm.CountControlScaler)
      counterm.CountControlScaler='Binary';
    end
    if ~isfield(counterm,'CountControlDirection') | isempty(counterm.CountControlDirection)
      counterm.CountControlDirection='Down';
    end
    if ~isfield(counterm,'OutputControl') | isempty(counterm.OutputControl)
      counterm.OutputControl='InactiveOutputLow';
    end
    if ~isfield(counterm,'TCToggleOutput') | isempty(counterm.TCToggleOutput)
      counterm.TCToggleOutput='Set';
    end
    if ~isfield(counterm,'InitialLoad') | isempty(counterm.InitialLoad)
      counterm.InitialLoad='-1';
    end
    if ~isfield(counterm,'InitialHold') | isempty(counterm.InitialHold)
      counterm.InitialHold='-1';
    end
    if ~isfield(counterm,'InitialArm') | isempty(counterm.InitialArm)
      counterm.InitialArm='No';
    end
    
    cm=0;
    idx= strmatch(lower(counterm.GatingControl),{'none','activehighleveltcn-1','activehighlevelgaten+1','activehighlevelgaten-1','activehighlevelgaten',...
      'activelowlevelgaten','activehighedgegaten','activelowedgegaten'},'exact');
    if isempty(idx)
      error('Invalid GatingControl value defined');
    end
    cm=cm + bitshift(idx-1,13);
    idx= strmatch(lower(counterm.SourceEdge),{'rising','falling'},'exact');
    if isempty(idx)
      error('Invalid SourceEdge value defined');
    end
    cm=cm + bitshift(idx-1,12);
    idx= strmatch(lower(counterm.CounterSource),{'tcn-1','src1','src2','scr3','src4','src5','gate1','gate2','gate3','gate4','gate5','f1','f2','f3','f4','f5'},'exact');
    if isempty(idx)
      error('Invalid CounterSource value defined');
    end
    cm=cm + bitshift(idx-1,8);
    idx= strmatch(lower(counterm.CountControlSpecialGate),{'disable','enable'},'exact');
    if isempty(idx)
      error('Invalid CountControlSpecialGate value defined');
    end
    cm=cm + bitshift(idx-1,7);
    idx= strmatch(lower(counterm.CountControlReload),{'load','loadorhold'},'exact');
    if isempty(idx)
      error('Invalid CountControlReload value defined');
    end
    cm=cm + bitshift(idx-1,6);
    idx= strmatch(lower(counterm.CountControlMode),{'once','repetetive'},'exact');
    if isempty(idx)
      error('Invalid CountControlMode value defined');
    end
    cm=cm + bitshift(idx-1,5);
    idx= strmatch(lower(counterm.CountControlScaler),{'binary','bcd'},'exact');
    if isempty(idx)
      error('Invalid CountControlScaler value defined');
    end
    cm=cm + bitshift(idx-1,4);
    idx= strmatch(lower(counterm.CountControlDirection),{'down','up'},'exact');
    if isempty(idx)
      error('Invalid CountControlDirection value defined');
    end
    cm=cm + bitshift(idx-1,3);
    idx= strmatch(lower(counterm.OutputControl),{'inactiveoutputlow','activehighterminalcountpulse','tctoggled','illegal','inactiveoutputhighimpedance','activelowterminalcountpulse'},'exact');
    if isempty(idx)
      error('Invalid OutputControl value defined');
    end
    cm=cm + idx-1;
    
    cms(counter)= cm;
    
  end
end

if isempty(init)
  initir=[];
else
  [io, initir]= parsecommands(init);
end

if isempty(term)
  termir=[];
else
  [io, termir]= parsecommands(term);
end

[io, ir]= parsecommands(commands);

function [io, ir]= parsecommands(commands)


nCommands=length(commands);

k=2;
ir=nCommands;
inputs=[];
inputWidth=[];
outputs=[];
outputWidth=[];


for i=1:nCommands
  
  command= commands(i);
  
  % extract 'Command'
  if ~isfield(command,'Command')
    error('Fieldname ''Command'' not defined');
  end
  idx= strmatch(lower(command.Command),{'writeload','writehold','readload','readhold','arm','disarm',...
      'load','loadandarm','disarmandsave','save','settoggle','cleartoggle',...
      'gateon','gateoff'},'exact');
  if isempty(idx)
    error('Invalid Command defined');
  end
  switch idx
  case 1
    ir(k)=10;
  case 2
    ir(k)=11;
  case 3
    ir(k)=12;
  case 4
    ir(k)=13;
  case 5
    ir(k)=20;
  case 6
    ir(k)=21;
  case 7
    ir(k)=30;
  case 8
    ir(k)=22;
  case 9
    ir(k)=23;
  case 10
    ir(k)=31;
  case 11
    ir(k)=40;
  case 12
    ir(k)=41;
  case 13
    ir(k)=50;
  case 14
    ir(k)=51;
  end
  
  % extract 'Control'
  if ~isfield(command,'Control')
    command.Control='1';
  end
  if isempty(command.Control)
    command.Control='1';
  end
  isInput=0;
  if command.Control(1)=='p'
    isInput=1;
    command.Control=command.Control(2:end);
  end
  tmp=str2num(command.Control);
  if isempty(tmp)
    error('Invalid ''Control'' format defined');
  end
  if ~isInput & ~tmp
    ir(k+1)=0;
  else
    ir(k+1)=1;
  end
  if isInput
    ir(k+1)= -tmp;
    inputs= [inputs,tmp];
    inputWidth= [inputWidth, 1];
  end  
  
  % extract 'Counters'
  if ~isfield(command,'Counters')
    command.Counters='[1]';
  end
  if isempty(command.Counters)
    command.Counters='[1]';
  end
  try
    tmp=eval(command.Counters);
  catch
    error('Invalid ''Counters'' format defined');
  end
  if ~isempty(find(tmp<1)) | ~isempty(find(tmp>5))
    error('''Counters'' elements must be in the range 1..5');
  end
  if length(unique(tmp))~=length(tmp)
    error('''Counters'' values cannot be re-used');
  end
  % set number of counters
  ir(k+2)=length(tmp);
  % set counters bit pattern
  tmp1=0;
  for j=1:length(tmp)
    tmp1=tmp1+2^(tmp(j)-1);
  end
  ir(k+3)= tmp1;
  %set counters
  tmp1=zeros(1,5);
  tmp1(1:length(tmp))=tmp;
  ir(k+4:k+8)= tmp1;
  ncounters= length(tmp);

  
  % extract 'IO'  
  if ~isfield(command,'IO')
    command.IO='0';
  end
  if isempty(command.IO)
    command.IO='0';
  end
  if command.IO(1)=='p'
    tmp= str2num(command.IO(2:end));
    if isempty(tmp)
      error('Invalid ''IO'' format defined');
    end
    ir(k+9)= -tmp;
    ir(k+10:k+13)=0;
    switch ir(k)
    case {10,11}
      inputs= [inputs,tmp];
      inputWidth= [inputWidth, ncounters];
    case {12,13}
      outputs= [outputs,tmp];
      outputWidth= [outputWidth, ncounters];
    end  
  else
    try
      tmp=eval(command.IO);
    catch
      error('Invalid ''IO'' format defined');
    end
    tmp1=zeros(1,5);
    tmp1(1:length(tmp))=tmp;
    ir(k+9:k+13)= tmp1;
  end
  
  
  k=k+14;
  
end


[inputs,sortorder]=unique(inputs);
inputWidth= inputWidth(sortorder);
if isempty(inputs)
  io(1)=0;
else
  if isempty(find(inputs==1))
    error('Input ports must be used starting with 1');
  end
  if ~isempty(find(inputs>length(inputs)))
    error('Input ports must be used from 1..n');
  end
  io(1)=length(inputs);
  io(3:2+io(1))=inputWidth;
end

[outputs, sortorder]=unique(outputs);
outputWidth= outputWidth(sortorder);
if isempty(outputs)
  io(2)=0;
else
  if isempty(find(outputs==1))
    error('Output ports must be used starting with 1');
  end
  if ~isempty(find(outputs>length(outputs)))
    error('Output ports must be used from 1..n');
  end
  io(2)=length(outputs);
  io(3+io(1):2+io(1)+length(outputs))= outputWidth;
end

