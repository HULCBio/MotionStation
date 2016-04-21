function [p,xy] = dspblkcount(varargin)
% DSPBLKCOUNT is the mask function for the Signal Processing Blockset Counter Block


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.9.4.2 $ $Date: 2004/04/12 23:06:12 $

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
% modify the dialog accordingly



% Preset the mask enables to all 'on':
en_orig = get_param(block,'MaskEnables');
en = en_orig;

% If count event is not free-run the disable the sample time edit box
% and disable the SamplesPerOutput frame edit box.
freerun = strcmp('free running',lower(get_param(block,'CountEvent')));
if ~freerun,
   en{9} ='on';  % Framebased checkbox
   en{10}='off'; % SamplesPerFrame edit
   en{11}='off'; % Sample time edit
else
   en{9} ='off'; % Famebaed checkbox  
   en{10}='on';  % SamplesPerFrame edit   
   en{11}='on';  % Sample time edit
end

% If userdef is the not the counter size disable the Max count dialog
userdef = strcmp('user defined',lower(get_param(block,'CounterSize')));
if ~userdef,
   en{4}='off';
else
   en{4}='on';
end

% If the hit output is not selected, then disable the hitvalue edit box 
hit = ~isempty(findstr('hit',lower(get_param(block,'Output'))));
if ~hit,
   en{7}='off';  % Disable last dialo
else
   en{7}='on';
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
