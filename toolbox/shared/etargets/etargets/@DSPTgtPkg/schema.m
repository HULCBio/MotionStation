function schema()
%SCHEMA  Package constructor function.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:37 $

%%%% Construct package
schema.package('DSPTgtPkg');

%%%% Create user-defined enumerated string types
if isempty(findtype('OptimizationLevelType'))
  schema.EnumType('OptimizationLevelType', {
    'None';
    'Register(-o0)';
    'Local(-o1)';
    'Function(-o2)';
    'File(-o3)';});
else
  warning('A type named ''OptimizationLevelType'' already exists.');
end

if isempty(findtype('CompilerVerbosityType'))
  schema.EnumType('CompilerVerbosityType', {
    'Verbose';
    'Quiet';
    'Super_quiet';});
else
  warning('A type named ''CompilerVerbosityType'' already exists.');
end

if isempty(findtype('SymbolicDebuggingType'))
  schema.EnumType('SymbolicDebuggingType', {
    'Yes';
    'No';});
else
  warning('A type named ''SymbolicDebuggingType'' already exists.');
end

if isempty(findtype('DSPChipType'))
  schema.EnumType('DSPChipType', {
    'TI TMS320C2407';
    'TI TMS320C2810';
    'TI TMS320C2812';});
else
  warning('A type named ''DSPChipType'' already exists.');
end

if isempty(findtype('MemoryUse'))
  schema.EnumType('MemoryUse', {
    'Text';
    'Data';
    'Text and Data';});
else
  warning('A type named ''MemoryUse'' already exists.');
end

if isempty(findtype('MemoryType'))
  schema.EnumType('MemoryType', {
    'SRAM';
    'SBSRAM';
    'SDRAM';});
else
  warning('A type named ''MemoryType'' already exists.');
end

if isempty(findtype('LinkerCMDFileType'))
  schema.EnumType('LinkerCMDFileType', {
    'Full_memory_map';
    'Internal_memory_map';
    'Custom_file';});
else
  warning('A type named ''LinkerCMDFileType'' already exists.');
end

if isempty(findtype('BuildActionType'))
  schema.EnumType('BuildActionType', {
    'Generate_code_only';
    'Create_CCS_Project';
    'Build';
    'Build_and_execute';});
else
  warning('A type named ''BuildActionType'' already exists.');
end

if isempty(findtype('OverrunActionType'))
  schema.EnumType('OverrunActionType', {
    'Continue';
    'Halt';});
else
  warning('A type named ''OverrunActionType'' already exists.');
end

if isempty(findtype('TSEG1Type'))
  schema.EnumType('TSEG1Type', {
    '2';
    '3';
    '4';
    '5';
    '6';
    '7';
    '8';
    '9';
    '10';
    '11';
    '12';
    '13';
    '14';
    '15';
    '16';});
else
  warning('A type named ''TSEG1Type'' already exists.');
end

if isempty(findtype('TSEG2Type'))
  schema.EnumType('TSEG2Type', {
    % this setting prevents CCE from being cleared
    % remove for now; revisit in the future
    %'1';
    '2';
    '3';
    '4';
    '5';
    '6';
    '7';
    '8';});
else
  warning('A type named ''TSEG2Type'' already exists.');
end

if isempty(findtype('SBGType'))
  schema.EnumType('SBGType', {
    'Only_falling_edges';
    'Both_falling_and_rising_edges';});
else
  warning('A type named ''SBGType'' already exists.');
end

if isempty(findtype('SJWType'))
  schema.EnumType('SJWType', {
    '1';
    '2';
    '3';    
    '4';});
else
  warning('A type named ''SJWType'' already exists.');
end

if isempty(findtype('SAMType'))
  schema.EnumType('SAMType', {
    'Sample_one_time';
    'Sample_three_times';});
else
  warning('A type named ''SAMType'' already exists.');
end

if isempty(findtype('C2400TimerType'))
  schema.EnumType('C2400TimerType', {
    'EVA_timer1';
    'EVA_timer2';
    'EVB_timer3';
    'EVB_timer4';});
else
  warning('A type named ''C2400TimerType'' already exists.');
end

if isempty(findtype('C2800TimerType'))
  schema.EnumType('C2800TimerType', {
    'CPU_timer0';});
    % not using CPU_timer1, CPU_timer2 since they are reserved for use in
    % dSP/BIOS and other RTOS
    %'CPU_timer0';
    %'CPU_timer1';
    %'CPU_timer2';});
else
  warning('A type named ''C2800TimerType'' already exists.');
end

if isempty(findtype('TimerClockPrescalerType'))
  schema.EnumType('TimerClockPrescalerType', {
    '1';
    '2';
    '4';
    '8';
    '16';
    '32';
    '64';
    '128';});
else
  warning('A type named ''TimerClockPrescalerType'' already exists.');
end
