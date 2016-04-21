function varargout = dspblkvarsel2(action)
% DSPBLKVARSEL Mask helper function for Variable Selector block.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 21:00:59 $
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
      if ~strcmp(ena{3},new_ena),
         ena{3} = new_ena;
         set_param(blk,'MaskEnables',ena);
      end

      % Finally, check the Rows/Columns selector popup and
      % set the Permute Matrix block options appropriately
      % under this block's mask
      strSelectRowsOrCols       = get_param(blk,'rowsOrCols');
      strSelectZerOneIdxMode   = get_param(blk,'ZerOneIdxMode');
      childBlk = [blk '/Permute Matrix'];
      strPermuteRowsOrCols    = get_param(childBlk,'mode');
      strPermuteZerOneIdxMode = get_param(childBlk,'ZeroOneIdxMode');
      if strcmp(strSelectRowsOrCols, 'Rows'),
          if ~strcmp(strPermuteRowsOrCols, 'Rows'),
              set_param(childBlk,'mode','Rows');
          end
      else
          if ~strcmp(strPermuteRowsOrCols, 'Columns'),
              set_param(childBlk,'mode','Columns');
          end
      end
      if strcmp(strSelectZerOneIdxMode, 'One-based'),
          if ~strcmp(strPermuteZerOneIdxMode, 'One-based'),
              set_param(childBlk,'ZeroOneIdxMode','One-based');
          end
      else
          if ~strcmp(strPermuteZerOneIdxMode, 'Zero-based'),
              set_param(childBlk,'ZeroOneIdxMode','Zero-based');
          end
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
