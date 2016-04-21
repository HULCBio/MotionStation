function OldBlocksRet=replace_block(System,varargin)
%REPLACE_BLOCK  Replace blocks in model.
%   REPLACE_BLOCK(System,BlockType,NewBlock) replaces all blocks in the
%   model named System having block type of BlockType with NewBlock.
%   For example, this command replaces all blocks in the model named
%   f14 having a block type of Gain with the Integrator block and
%   stores the paths of the changed blocks in the variable ReplaceNames:
%
%     ReplaceNames = replace_block('f14','Gain','Integrator');
%
%   REPLACE_BLOCK(System,BlockParameter,BlockParamValue,NewBlock)
%   replaces all blocks in the model named System whose parameter values
%   match BlockParameter and BlockParamValue with NewBlock. You can
%   include any number of parameter/value pairs. For example, this
%   command replaces all blocks in the subsystem named Unlocked in the
%   model named clutch having a value of 'bv' for the Gain parameter with
%   the Integrator block:
%
%     ReplaceNames = replace_block('clutch/Unlocked','Gain','bv','Integrator');
%
%   These commands display a dialog box that asks you to select matching
%   blocks before making the replacement. To suppress the dialog box from
%   being displayed, add the 'noprompt' argument as the last argument in
%   the command. For example, this command changes the Gain blocks to
%   Integrator blocks but does not display the dialog box and also does
%   not return the results to a left hand side argument:
%
%     replace_block('f14','Gain','Integrator','noprompt')
%
%   Because it may be difficult to undo the changes this command makes,
%   use it carefully. It is a good idea to save your model first.
%
%   See also FIND_SYSTEM.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.23 $

%
% the requisite nargin checking...
%
if nargin < 2,
  error('Not enough input arguments.');
end

CR = sprintf('\n');

%
% determine the number of input args and parse the 'noprompt' option
% System, OldBlockType, NewBlock
%
NumIn=nargin-1;
NoPromptFlag=0;
if isequal(varargin{end},'noprompt'),
  NumIn=NumIn-1;
  NoPromptFlag=1;
end

%
% determine if the system is a valid system path name or handle.
% if it's a handle, convert it to a full path name
%
try
  System = getfullname(System);
catch
  error('System must be a valid model or subsystem name.');
end

%
% identify the blocks that are to be replaced
%
if NumIn==2,
  OldBlocks=find_system(System,'LookUnderMasks','all','BlockType',varargin{1});
  if isempty(OldBlocks),
    OldBlocks = ...
        find_system(System,'LookUnderMasks','all','MaskType',varargin{1});
  end

elseif NumIn>2,
  OldBlocks=find_system(System,'LookUnderMasks','all',varargin{1:NumIn-1});
end

%
% identify the replacement block, a number of possibilities exist:
%   - the block is a built-in type speicified with or without 'built-in'
%   - the block is a full path name to a block
%
NewHandle={};
NewBlock=varargin{NumIn};
if strncmp(NewBlock,'built-in/',9),
  NewHandle=LocalCheckBuiltIn(NewBlock);

else,
  Loc=find(NewBlock=='/');
  if isempty(Loc),
    NewHandle=['built-in/' NewBlock];
    NewHandle=LocalCheckBuiltIn(NewHandle);
  else,
    try
      NewHandle=find_system(NewBlock,'flat');
    catch
      NewHandle={};
    end
  end
end

if isempty(NewHandle),
    error(['Invalid NewBlock (' NewBlock  ...
           ') passed to REPLACE_BLOCK' CR, ...
           'Try built-in/<BLOCKTYPE> or a valid block name.']);
end

if ~iscell(NewHandle),
  NewHandle={NewHandle};
end

if ~iscell(OldBlocks),
  TempBlocks=cell(length(OldBlocks,1));

  for lp=1:length(OldBlocks),
    TempBlocks{lp}=getfullname(OldBlocks(lp));
  end

  OldBlocks=TempBlocks;
end

%
% replace the blocks
%
if ~isempty(OldBlocks),
  OK=1;
  Selection=1:length(OldBlocks);
  if NoPromptFlag==0,
    [Selection,OK]=listdlg('ListString'  ,OldBlocks                 , ...
                           'ListSize'    ,[300 300]                 , ...
                           'InitialValue',1:length(OldBlocks)       , ...
                           'Name'        ,'Replace Dialog'          , ...
                           'PromptString','Select the blocks to replace');
  end
  
  if OK,
    OldBlocks=OldBlocks(Selection);
    OldHandles = get_param(OldBlocks, 'Handle');
    if strcmp(get_param(bdroot(System),'Lock'),'on'),
      error(['The model must be unlocked to make changes to it. ', CR, ...
             'To unlock the model, select "Unlock Library" from the ', ...
             'Edit menu.  ', CR, ...
             'Otherwise enter the comand:', CR, ...
             '  set_param(bdroot(System),''Lock'',''off'')', CR, ...
             'where System is the name of the system passed to ', ...
             'replace_block'])
    end
    for lp=1:length(OldBlocks),
      if ishandle(OldHandles{lp}),
        Orient=get_param(OldBlocks{lp},'orientation');
        Size=get_param(OldBlocks{lp},'position');
        delete_block(OldBlocks{lp});
        add_block(NewHandle{1},OldBlocks{lp}, ...
                  'Orientation',Orient      , ...
                  'Position'   ,Size          ...
                  );
      end
    end
  end
end
  
%
% return the output arg if necessary
%
if nargout,
  OldBlocksRet = OldBlocks;
end

% end replace_block

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCheckBuiltIn %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewHandle=LocalCheckBuiltIn(NewHandle)

if ~strcmp(NewHandle,'built-in/Subsystem'),
  try
    ValidHandle=get_param(NewHandle,'Name');
  catch
    ValidHandle=[];
  end

  if isempty(ValidHandle),
    NewHandle={};
  end % if
end % if ~strcmp
