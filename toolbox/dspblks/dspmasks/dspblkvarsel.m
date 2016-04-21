function varargout = dspblkvarsel(action)
% DSPBLKVARSEL Mask helper function for Variable Selector block.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 20:56:40 $

blk=gcb;
if nargin==0, action = 'dynamic'; end

switch action
   case 'dynamic'
      % Enable the Elements edit dialog:
      ena = get_param(blk,'MaskEnables');
      isVar = strcmp(get_param(blk,'IdxMode'),'Variable');
      if isVar,
         new_ena = 'off';
      else
         new_ena = 'on';
      end
      
      % Don't dirty model until absolutely necessary:
      if ~strcmp(ena{2},new_ena),
         ena{2} = new_ena;
         set_param(blk,'MaskEnables',ena);
      end
      
   case 'init'
      % To do;
      % 1 - Update port/constant for variable/fixed operation
      % 2 - Turn on/off port labels
      % 3 - Set warning mode into popup in underlying block
      
      % The 3rd dialog (popuo) changes the constant to a port
      % - Port means we can externally drive the index port
      % - Constant means the index port is removed
      
      idxBlk      = [blk '/Idx'];
      portIsPresent = strcmp(get_param(idxBlk,'BlockType'),'Inport');
      wantPort      = strcmp(get_param(blk,'IdxMode'),'Variable');
      
      if wantPort & ~portIsPresent,
         % Change Constant to Port
         pos = get_param(idxBlk,'Position');
         delete_block(idxBlk);
         add_block('built-in/Inport',idxBlk,'Position',pos);
         
         % Turn off port labels:
         set_param(blk,'MaskIconOpaque','off');
       
      elseif ~wantPort & portIsPresent,
         % Change Port to Constant
         pos = get_param(idxBlk,'Position');
         delete_block(idxBlk);
         add_block('built-in/Constant',idxBlk,'Position',pos,'Value','Elements');
         set_param(blk,'MaskIconOpaque','on');
      end
      
      % Propagate warning mode to underlying block:
      childBlk = [blk '/Permute Matrix'];
      parent = get_param(blk,     'errmode');
      child  = get_param(childBlk,'errmode');
      if ~strcmp(parent,child),
         set_param(childBlk,'errmode',parent);
      end
           
   otherwise
      error('unhandled case');
end

% [EOF] dspblkvarsel.m
