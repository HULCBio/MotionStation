function [new_UD, OtherTypeBlock] = vqcreatemodel(UD)
%CREATEMODEL Create a subsystem.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:52 $

% new_UD = UD (modified), new_UD.otherTypeBlock;
% Get current system (gcs), if specified.
% Do not use a locked block diagram; it's probably an
% invisibly loaded library anyway.
% for spec see vqrealizemdl.m

OtherTypeBlock = 0;
if (UD.destinationMdl == 1) & ~syslocked(gcs),
    sys = gcs;
    if isempty(sys),
        sys = 'Untitled';
        new_system(sys, 'Model');
    end
else
    % Create a new system if required:
    sys = uniq_sys;
    new_system(sys, 'Model');
end

if (UD.whichBlock==1)%encoder
   VQLibBlkName=sprintf('Vector Quantizer\nEncoder');
   VQSfcnName = 'sdspvqenc';
   posVQ = [25    18   120    72];
else %decoder   
   VQLibBlkName=sprintf('Vector Quantizer\nDecoder') ;
   VQSfcnName = 'sdspvqdec';
   posVQ = [200   18   295    72];
end   
srcBlockWithPathAndName = strcat('dspquant2/',VQLibBlkName);
pos = posVQ;

VQblkNameInEditBox = UD.blockName;
if isempty(VQblkNameInEditBox),
    VQblkNameInEditBox = VQLibBlkName;
end

newTag = 'VQDESIGN_GUI_REALIZE_MODEL';
if (UD.destinationMdl == 1) & (UD.overwriteFlag == 1), % current model & overwrite
    subsys = [sys '/' VQblkNameInEditBox];
    currentblk = find_system(gcs, 'SearchDepth', 1,'Name', VQblkNameInEditBox);
    idx = find(strcmpi(gcs, currentblk));
    if ~isempty(idx), currentblk(idx) = []; end
    if ~isempty(currentblk),
        %%conn = get_param(currentblk{1}, 'PortConnectivity');
        try
          CurBlockIsVQblock = strcmp(get_param(currentblk{1},'FunctionName'),VQSfcnName); % for dspblks
                                          % simulink block doesn't have parameter 'FunctionName'
        catch
            % if the block doesn't have a parameter named 'FunctionName', it is not the VQenc/VQdec block
          CurBlockIsVQblock = 0;
        end                                 
        pos = get_param(currentblk{1}, 'Position');
        if ~CurBlockIsVQblock 
            % Get a new VQ ENC/DEC block only if it is not VQ ENC/DEC block
             UD.overwriteFlag = 0;% we do not want to overwrite other-type of block
             OtherTypeBlock = 1;
             pos = posVQ;;
        %else
        % do nothing (no add block, no position setting)
        end
    else
        addBlockSetPOsition(srcBlockWithPathAndName, subsys,newTag, pos);
    end
end    
if  ((UD.destinationMdl == 1) && (UD.overwriteFlag == 0)),  % current model & non-overwrite
    old_subsys = [sys '/' VQblkNameInEditBox];
    subsys = uniq_sys(old_subsys);
    % if the block exists in the model, then increment the block name (not to overwrite)
    % and give message to the user.
        addBlockSetPOsition(srcBlockWithPathAndName, subsys,newTag, pos);
elseif (UD.destinationMdl ~= 1)
    subsys = [sys '/' VQblkNameInEditBox];
    addBlockSetPOsition(srcBlockWithPathAndName, subsys,newTag, pos);
end

% Update object (case blockname had to be changed)
slindex = findstr(subsys,'/');
UD.blockName = subsys(slindex(end)+1:end);
UD.system = subsys;
new_UD = UD;

%------------------------- ----------------------------------
function new_sys = uniq_sys(sys)
% UNIQ_SYS Generate a unique system name, based on a desired system name.
%   NEW_SYS = UNIQ_SYS(SYS).  Note that the system is not created.  If
%   SYS is not provided, the default system name 'Untitled' is used.
%
%   See also UNIQ_BLK.

if nargin==0 | isempty(sys),
  new_sys='Untitled';
else
  new_sys = sys;
end
while( sysexist(new_sys) ),
  [numsuff,prefix]=namenum(new_sys);
  if isempty(numsuff),
    new_sys=[new_sys '1'];  % System name did not end with a number
  else
    new_sys=[prefix num2str(numsuff+1)];
  end
end


%-----------------------------------------------------------
function [suffix,prefix] = namenum(s)
%NAMENUM Parse a string name for trailing numeric characters.
%   [SUFFIX,PREFIX] = NAMENUM(S) returns the value corresponding to the
%   numeric characters found at the end of the string S as SUFFIX.
%   Optionally returns the beginning portion of the string (up to but not
%   including any trailing numeric characters) as string PREFIX.
%
%   Only contiguous numeric characters located at the end of the string are
%   converted to the numeric SUFFIX; any other numeric characters are simply
%   returned as part of the PREFIX string.
%
%   If no trailing numeric characters are found, empty is returned for SUFFIX
%   and the entire string S returned as PREFIX.

suffix = [];
prefix = s;
if isempty(s) | ~isstr(s) | s(end)<'0' | s(end)>'9',
  return;
end
[r,c] = find( (s<'0') | (s>'9') );
mc = max(c);
prefix = s(1:mc);
suffix = str2double(s(mc+1:end));


%-----------------------------------------------------------
function y=sysexist(sys)
%SYSEXIST Returns true (1) if the specified path is a Simulink system or
%         subsystem and is currently open; otherwise, returns false (0).
%
%         See also BLKEXIST.

stype=systype(sys);
y = strcmp(stype,'model') | strcmp(stype,'subsystem') | strcmp(stype,'block');


%-----------------------------------------------------------
function y = syslocked(sys)
% SYSLOCKED Determine whether a system is locked.
%  This function is error-protected against calls on
%  subsystems or blocks, which do not have a lock parameter.

y = ~isempty(sys);
if y,
   y = strcmpi(get_param(bdroot(sys),'lock'),'on');
end


%-----------------------------------------------------------
function y=systype(p)
%SYSTYPE Returns type of Simulink entity.
%   SYSTYPE(P) returns a type string corresponding to the
%   Simulink entity described by path P.  Possible type
%   strings returned are:
%        'model'     if P is the top-level model
%        'subsystem' if P is a subsystem
%        'block'     if P is a block,
%        'entity'    if P is a Simulink entity other than a model,
%                    subsystem, or block.
%        'none'      if P is not a Simulink entity.

% Decision Logic:
%
% if it has a "BlockType" field,
%   it's a block or subsystem of the top-level system.
%   if BlockType is "SubSystem",
%     it's a subsystem block.
%   else
%     it's a Simulink block
% else if it has a "Version" field,
%   it's the top-level system.
% else if it has a "Name" field,
%   it's some unknown Simulink entity,
% else
%   it's not a Simulink entity.

eval('bt=get_param(p,''BlockType'');this_is=1;','this_is=0;');
if this_is,
  if strcmp(bt,'SubSystem'),
    y='subsystem';
  else
    y='block';
  end
  return
end

eval('get_param(p,''Version'');this_is=1;','this_is=0;');
if this_is,
  y='model';
  return
end

eval('get_param(p,''Name'');this_is=1;','this_is=0;');
if this_is,
  y='entity';
else
  y='none';
  
  % At this point, we've tried everything and still
  % do not match the block
  % Clean up by clearing the last error message
  lasterr('');
end

function addBlockSetPOsition(srcBlockWithPathAndName, destBlockWithPathAndName,newTag, pos)
  load_system('dspquant2');
  add_block(srcBlockWithPathAndName,destBlockWithPathAndName, 'Tag',  newTag);
  % Restore position of the block
  set_param(destBlockWithPathAndName,'Position', pos);
  
% [EOF]
