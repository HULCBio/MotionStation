function [p,xy] = dspblkcount2(varargin)
% DSPBLKCOUNT2 is the mask function for the Signal Processing Blockset Counter Block


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:13 $

block = gcbh;

if nargin == 0  
   dynamic(block);
else
   % set up icon display
   [p,xy] = icon(block);
end

%---------------------------------------------

function dynamic(block)
% check the value of the control
% modify the dialog accordingl

% Preset the mask enables to all 'on':
en_orig = get_param(block,'MaskEnables');
en = en_orig;

CounterSize = 4;
HitValue = 7;
SamplePerFrame = 9;
SampleTimeEdit = 10;
CountDataType = 11;
HitDataType = 12;

% If count event is not free-run the disable the sample time edit box
% and disable the SamplesPerOutput frame edit box.
freerun = strcmp('free running',lower(get_param(block,'CountEvent')));
if ~freerun,
   en{SamplePerFrame}='off'; % SamplesPerFrame edit
   en{SampleTimeEdit}='off'; % Sample time edit
else
   en{SamplePerFrame}='on';  % SamplesPerFrame edit   
   en{SampleTimeEdit}='on';  % Sample time edit
end


% If userdef is the not the counter size disable the Max count dialog
userdef = strcmp('user defined',lower(get_param(block,'CounterSize')));
if ~userdef,
   en{CounterSize}='off';
else
   en{CounterSize}='on';
end


% If the hit output is not selected, then disable the hitvalue edit box 
hit = ~isempty(findstr('hit',lower(get_param(block,'Output'))));
if ~hit,
   en{HitValue}='off';  % Disable last dialog
else
   en{HitValue}='on';
end


norst = strcmp('off', get_param(block, 'ResetInput')); % reset port
cnt =  ~isempty(findstr('Count',get_param(block,'Output')));
cntisdouble = 1;
if ~cnt
    en{CountDataType} = 'off';
else
    en{CountDataType} = 'on';
    cntisdouble = strcmp('double',lower(get_param(block,'CntDType')));
end
if ~cntisdouble | ~hit
    en{HitDataType} = 'off';
else
    en{HitDataType} = 'on';
end

if ~isequal(en, en_orig),
   set_param(block,'MaskEnables',en);
end

%---------------------------------------------
function [p,xy] = icon(block)
% Check the parmeter values that were passed in
%  -Direction     (icon)
%  -Reset         (input)
%  -Enable        (input)
%  -Count         (output)
%  -Hit           (output)
%
% Set up the port labels and icon

direction = get_param(block,'Direction');
reset     = strcmp(get_param(block,'ResetInput'),'on');
count     = ~isempty(findstr('count',lower(get_param(block,'Output'))));
hit       = ~isempty(findstr('hit',lower(get_param(block,'Output'))));
freerun   = strcmp('free running',lower(get_param(block,'CountEvent')));


% Setup Inport labels
if(freerun)
   p.in1 = 'output';      % Set outport as dummy call.  Will subsequently change.
   p.i1 = 1; p.i1s = '';  % No clock port
   if(reset),
      p.in2 = 'input';
      p.i2 = 1; 
      p.i2s = 'Rst';  
   else, 
      p.in2 = 'output';
      p.i2 = 1; 
      p.i2s = '';
   end
else
   p.in1 = 'input';
   p.in2 = 'input';
   p.i1 = 1; p.i1s = 'Clk';
   if(reset), p.i2 = 2; p.i2s = 'Rst';
   else,      p.i2 = 1; p.i2s = 'Clk'; end
end

% Setup Outport label.  At least one exist
p.out = 'output';  % Choose the side of block to label

if(count & hit) 
   p.o1 = 1; p.o1s = 'Cnt';     
   p.o2 = 2; p.o2s = 'Hit';  
elseif(count & ~hit)
   p.o1 = 1; p.o1s = 'Cnt';  
   p.o2 = 1; p.o2s = 'Cnt';  
elseif(~count & hit)
   p.o1 = 1; p.o1s = 'Hit';
   p.o2 = 1; p.o2s = 'Hit';  
else
   p.o1 = 1; p.o1s = '';
   p.o2 = 1; p.o2s = '';  
end

% Display Count direction
if(strcmp(direction,'Up'))
   xy.direction = 'Up';
else
   xy.direction = 'Down';
end

% [EOF] dspblkcount.m
