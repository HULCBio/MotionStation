function s = dspblkcumsumprod(action)
% DSPBLKCUMSUMPROD Signal Processing Blockset Cumulative Sum/Product block 
% helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:06:14 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;

switch action
 case 'icon'
  fcn = get_param(blk,'dim');
  isRunning = (findstr(fcn,'Channels (running ') == 1);
  % Setup port label structure:
  if isRunning
    % 2 inputs (in, rst)
    % 1 output (val)
    isRst = ~strcmp(get_param(blk,'reset_popup'),'None');
    if isRst,
      s.i1 = 1; s.i1s = 'In'; 
      s.i2 = 2; s.i2s = 'Rst';
    else
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  % No need to annotate one input
    end      
  else
    % 1 input (in)
    % 1 output
    s.i1 = 1; s.i1s = ''; 
    s.i2 = 1; s.i2s = '';  %In
  end
  % icon label
  switch fcn
   case 'Columns'
    s.str = 'Column';
   case 'Rows'
    s.str = 'Row';
   case 'Channels (running sum)'
    s.str = 'Running';
   case 'Channels (running product)'
    s.str = 'Running';
   otherwise
    error('dspblkcumsumprod:fcn','unhandled fcn case');
  end 
 otherwise
  error('dspblkcumsumprod:action','unhandled action case');
end

