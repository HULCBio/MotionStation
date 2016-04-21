function [errTxt] = vxintbuild(irqNumbers, irqOffsets, irqDirection, mode, preemptionFlags)
% VXINTBUILD VxWorks Interrupt Block Build Wizard
%   Creates the underlying blocks required for the interrupt control block.
%   In simulation mode the the input of the interrupt handler S-function
%   is connected to the output of a trigger port block.  In RTW mode the
%   input is connected to ground.  The arguments to this function are 
%
%   numIRQs   = Number of interrupt request signals (1-7)
%   startIdx  = Start index of first request signal (0 or 1)
%   direction = -1 (falling)
%             =  1 (rising)
%             =  0 (either), specified as a scalar or a vector
%   mode      =  1 (simulation)
%             =  2 (rtw)

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.9 $

errTxt = '';
maskType = 'VxWorks Interrupt Block';

% interrupt numbers must be 1-7
if (max(irqNumbers) > 7) | (min(irqNumbers) < 1)
  errTxt = 'interrupt numbers must be 1-7.';
  return
end  

% must specify at least 1 interrupt, 1 interrupt vector offset, and 1 preemption flag
numIRQs = length(irqNumbers);
numOffsets = length(irqOffsets);
numPreemptionFlags = length(preemptionFlags);
if numIRQs == 0 
  errTxt = 'Must specify at least 1 interrrupt.';
  return
elseif numOffsets == 0
  errTxt = 'Must specify at least 1 interrrupt vector offset.';
  return
elseif numPreemptionFlags == 0
  errTxt = 'Must specify preemption flag(s).';
  return
end

% the number of interrupt vector offsets must equal the number of interrupts
if numIRQs ~= numOffsets
  errTxt = [ ...
     'The number of interrupt vector offsets must match the ' ...
     'number of interrupts.' ...
   ];
  return
end

% if not a scalar, the number of preemption flags must equal the number of interrupts
if mod(numIRQs+numPreemptionFlags, numPreemptionFlags)
  errTxt = [ ...
     'The preemption flag must be a scalar or a vector whos length ' ...
     'matches the number of interrupts.' ];
  return
end

% can't specify duplicate interrupts or interrupt vector offsets
for i = 1 : numIRQs
  if length(find(irqNumbers == irqNumbers(i))) > 1
    errTxt = 'A duplicate interrupt was specified.';
    return
  end
  if length(find(irqOffsets == irqOffsets(i))) > 1
    errTxt = 'A duplicate interrupt vector offset was specified.';
    return
  end
end

% find the interrupt block in question
hModel = get_param(bdroot, 'handle');
modelName = get_param(hModel, 'Name');
ssBlocks = find_system(hModel,'LookUnderMasks','on','FollowLinks','on', ...
		       'BlockType','SubSystem', 'MaskType', maskType);

% only allow 1 interrupt block
if length(ssBlocks) > 1
  illegalBlockName = get_param(gcb, 'Name');
  set_param(gcb, 'ShowName', 'on');
  errTxt = [ ...
	     'To emulate interrupt priority all interrupt request signals must ' ...
	     'route through a single interrupt block.  Delete block: ' ...
	     illegalBlockName ...
	     ];
  return
else
  intBlock = ssBlocks(1);
end

% locate underlying blocks
triggerPorts = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
   'BlockType', 'TriggerPort');

sfunBlocks = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
   'BlockType', 'S-Function');

gndBlocks  = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
   'BlockType', 'Ground');

demuxBlocks = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
   'BlockType', 'Demux');

% there must be one and only one demux block
if length(demuxBlocks) > 1
   blockName = get_param(gcb,'Name');
   open_system(gcb,'force');
   errTxt = [ ...
         'Only 1 demux block is allowed under masked block: ' blockName ...
         '.  Remove the additional demux block.'];
   return
else
   demuxBlock = demuxBlocks(1);
   demuxBlockName = get_param(demuxBlock, 'Name');
end

% there must be one and only one S-Function block
if length(sfunBlocks) > 1
   blockName = get_param(gcb,'Name');
   open_system(gcb,'force');
   errTxt = [ ...
         'Only 1 S-Function block is allowed under masked block: ' blockName ...
         '.  Remove the additional S-Function block.'];
   return
else
   sfunBlock = sfunBlocks(1);
   sfunBlockName = get_param(sfunBlock, 'Name');
end

parentName = get_param(intBlock, 'parent');     % parent name of interrupt block
blkName = get_param(intBlock, 'Name');          % name of interrupt block

% need to remove the ground block and add a trigger block if it was previously
% configured for rtw and it's now configured for simulation
if length(gndBlocks) == 1 & mode == 1
   % delete ground and signal from ground to s-function
   gndBlock = gndBlocks(1);
   gndBlockName = get_param(gndBlock, 'Name');
   srcBlock = [gndBlockName '/1'];
   dstBlock = [sfunBlockName '/1'];
   delete_line([parentName '/' blkName], srcBlock, dstBlock)
   ground = [parentName '/' blkName '/' gndBlockName];
   delete_block(ground);
   % add trigger port and connect it to s-function
   x2 = 10;
   add_block('built-in/TriggerPort',[parentName, '/', blkName, '/', 'Trigger'], ...
      'Position',[x2 30*i x2+20 30*i+20]);
   set_param([parentName '/' blkName '/' 'Trigger'], 'ShowOutputPort', 'on');
   srcBlock = ['Trigger/1'];
   dstBlock = [sfunBlockName '/1'];
   add_line([parentName '/' blkName], srcBlock, dstBlock);

% need to remove the trigger block and add a ground block if it was previously
% configured for simulation and now it's configured for rtw
elseif length(triggerPorts) == 1 & mode == 2
   % delete trigger block and signal from trigger block to s-function
   trigBlock = triggerPorts(1);
   trigBlockName = get_param(trigBlock, 'Name');
   srcBlock = [trigBlockName '/1'];
   dstBlock = [sfunBlockName '/1'];
   delete_line([parentName '/' blkName], srcBlock, dstBlock)
   trigger = [parentName '/' blkName '/' trigBlockName];
   delete_block(trigger);
   % add ground block and connect it to the s-function
   x2 = 0;
   add_block('built-in/Ground',[parentName, '/', blkName, '/', 'Ground'], ...
      'Position',[x2 30*i x2+20 30*i+20]);
   srcBlock = ['Ground/1'];
   dstBlock = [sfunBlockName '/1'];
   add_line([parentName '/' blkName], srcBlock, dstBlock)
end

% may need to configure the trigger port
if mode == 1
   triggerPorts = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
      'BlockType', 'TriggerPort');
   triggerPort = triggerPorts(1);
   if irqDirection == 1,
      set_param(triggerPort, 'TriggerType', 'rising');
   elseif irqDirection == 2,
      set_param(triggerPort, 'TriggerType', 'falling');
   else
      set_param(triggerPort, 'TriggerType', 'either');
   end
end

% create or delete outport blocks as necessary

outports=find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
   'BlockType', 'Outport');

numOutports=length(outports);

% temporarily rename the blocks to avoid clashing
renameOutports(intBlock, 'tempIRQOut', 1, numOutports, [1:numOutports]);

% add some outports
if numOutports < numIRQs,
   set_param(demuxBlock, 'Outputs', int2str(numIRQs));
   x2 = 350;
   for i = numOutports+1:numIRQs,
      irqNumber = irqNumbers(i);
      parentName = get_param(intBlock, 'parent');
      blkName = get_param(intBlock, 'Name');
      portName=['IRQ' int2str(irqNumber)];
      add_block('built-in/Outport',[parentName, '/', blkName, '/', portName], ...
         'Position',[x2 30*i x2+20 30*i+20]);
      srcBlock = [demuxBlockName, '/', int2str(i)];
      dstBlock = ['IRQ', int2str(irqNumber), '/1'];
      add_line([parentName '/' blkName], srcBlock, dstBlock)
   end
   % rename the leading outports
   renameOutports(intBlock, 'IRQ', 1, numIRQs, irqNumbers);
% remove some outports
elseif numOutports > numIRQs,
   numExtraOutports = numOutports - numIRQs;
   for i = 1:numExtraOutports,
      parentName = get_param(intBlock, 'parent');
      blkName = get_param(intBlock, 'Name');
      outport = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
         'BlockType', 'Outport', 'Port', num2str(numOutports));
      srcBlock = [demuxBlockName, '/', int2str(numOutports)];
      dstBlock = [get_param(outport, 'Name') '/1'];
      delete_line([parentName '/' blkName], srcBlock, dstBlock)
      delete_block(outport);
      numOutports = numOutports - 1;
   end
   % set demux
   set_param(demuxBlocks(1),'Outputs',int2str(numIRQs));
   % rename the leading outports
   renameOutports(intBlock, 'IRQ', 1, numIRQs, irqNumbers);
else
  % may need to re-index
  renameOutports(intBlock, 'IRQ', 1, numIRQs, irqNumbers);
end

function renameOutports(intBlock, prefix, startIdx, endIdx, numbers)
for i = startIdx:endIdx
   outport = find_system(intBlock, 'LookUnderMasks','on','FollowLinks','on', ...
      'BlockType', 'Outport', 'Port', num2str(i));
   set_param(outport, 'Name', [prefix, num2str(numbers(i))]);
end
