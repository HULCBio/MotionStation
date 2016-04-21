function dspblksummult(varargin)
% DSPBLKSUMMULT Signal Processing Blockset DSP Sum/DSP Product block helper 
% function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.4 $ $Date: 2004/04/12 23:07:25 $

if nargin == 1
  action = 'dynamic';
  undertype = varargin{1};
else
  action    = varargin{1};
  undertype = varargin{2};
end

[OUT_MODE,OUT_WL,OUT_FL,R_MODE,O_MODE] = deal(2,3,4,5,6);

blk = gcb;
underblk    = [blk '/' undertype];
outPropBlk0 = [blk '/Data Type' char(10) 'Propagation'];
outPropBlk1 = [blk '/Data Type' char(10) 'Propagation1'];

if strcmp(undertype,'Product')
  modeParam = 'prodOutputMode';
  wlParam = 'prodOutputWordLength';
  flParam = 'prodOutputFracLength';
else
  modeParam = 'accumMode';
  wlParam = 'accumWordLength';
  flParam = 'accumFracLength';
end
mode = get_param(blk,modeParam);

switch (action)
 case 'init'
  % Set non-graphical parameters here
  if strcmp(mode,'User-defined')
    set_param(outPropBlk0,'NumBitsMult','0');
    set_param(outPropBlk0,'NumBitsAdd',wlParam);
    set_param(outPropBlk0,'SlopeMult','0');
    set_param(outPropBlk0,'SlopeAdd',['2^-(' flParam ')']);
    
    set_param(outPropBlk1,'NumBitsMult','0');
    set_param(outPropBlk1,'NumBitsAdd',wlParam);
    set_param(outPropBlk1,'SlopeMult','0');
    set_param(outPropBlk1,'SlopeAdd',['2^-(' flParam ')']);

  else
    set_param(outPropBlk0,'NumBitsMult','1');
    set_param(outPropBlk0,'NumBitsAdd','0');
    set_param(outPropBlk0,'SlopeMult','1');
    set_param(outPropBlk0,'SlopeAdd','0');
    
    set_param(outPropBlk1,'NumBitsMult','1');
    set_param(outPropBlk1,'NumBitsAdd','0');
    set_param(outPropBlk1,'SlopeMult','1');
    set_param(outPropBlk1,'SlopeAdd','0');
  end

  set_param(underblk,'RndMeth',get_param(blk,'roundingMode'));
  set_param(underblk,'saturateOnIntegerOverflow', ...
                     get_param(blk,'overflowMode'));
  
 case 'update'
  %
  % Need to correct propagation rules based on mode
  % (i.e. change line connections to Data Type Prop blocks)
  %
  if strcmp(mode,'User-defined')
    % "User-defined":
    % Make sure Ref2 of outPropBlk1
    % connects to subsystem's input 2
    try
      % If an error occurs on "delete_line", exit immediately
      % (nothing more to do here - no need for a "catch")
      delete_line(blk, 'Check Signal Attributes/1',  'Data Type Propagation1/2');
      add_line(   blk, 'Check Signal Attributes1/1', 'Data Type Propagation1/2');
    end
    
  else
    % "Same as first input":
    % Make sure Ref2 of outPropBlk1
    % connects to subsystem's input 1
    try
      % If an error occurs on "delete_line", exit immediately
      % (nothing more to do here - no need for a "catch")
      delete_line(blk, 'Check Signal Attributes1/1', 'Data Type Propagation1/2');
      add_line(   blk, 'Check Signal Attributes/1',  'Data Type Propagation1/2');
    end
  end
  
 case 'dynamic'
  % Only set graphical parameters on mask here (i.e. enables and/or visibilities)
  curVis = get_param(blk,'maskvisibilities');
  lastVis = curVis;

  if strcmp(mode,'User-defined')
    curVis(OUT_WL) = {'on'};
    curVis(OUT_FL) = {'on'};
  else
    curVis(OUT_WL) = {'off'};
    curVis(OUT_FL) = {'off'};
  end
  
  if ~isequal(curVis,lastVis)
    set_param(blk,'maskvisibilities',curVis);
  end
end

