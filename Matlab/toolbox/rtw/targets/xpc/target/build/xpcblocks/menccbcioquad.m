function [convBaseAddr] = menccbcioquad (flag, Module, BaseAddr, slot, BoardType)

% MENCCBCIOQUAD - InitFcn and Mask Initialization for CB CIO-QUAD series board

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.4.1 $ $Date: 2003/11/13 06:22:33 $


% Initialize Data Values
global xpcquad04check;


MAX_MODULE = 4;

if flag == 0
  xpcquad04check = [];
  return;
end

% Label Output Ports

% Set MaskDisplay

if BoardType == 1
  display=['text(0.05,0.75,''CIO-QUAD02'',''horizontalAlignment'',''left'');'];
  display=[display,'text(0.05,0.5,''Comp. Boards'',''horizontalAlignment'',''left'');'];
  display=[display,'text(0.05,0.25,''Inc. Encoder'',''horizontalAlignment'',''left'');'];
  description=['CIO-QUAD02',10,'Computer Boards',10,'Incremental Encoder'];
  MAX_MODULE = 2;
elseif BoardType == 2
  display=['text(0.05,0.75,''CIO-QUAD04'',''horizontalAlignment'',''left'');'];
  display=[display,'text(0.05,0.5,''Comp. Boards'',''horizontalAlignment'',''left'');'];
  display=[display,'text(0.05,0.25,''Inc. Encoder'',''horizontalAlignment'',''left'');'];
  description=['CIO-QUAD04',10,'Computer Boards',10,'Incremental Encoder'];
  MAX_MODULE = 4;
elseif BoardType == 3
  display=['text(0.05,0.75,''PCI-QUAD04'',''horizontalAlignment'',''left'');'];
  display=[display,'text(0.05,0.5,''Comp. Boards'',''horizontalAlignment'',''left'');'];
  display=[display,'text(0.05,0.25,''Inc. Encoder'',''horizontalAlignment'',''left'');'];
  description=['PCI-QUAD04',10,'Computer Boards',10,'Incremental Encoder'];
  MAX_MODULE = 4;
end

% Compose MaskDisplay String

display = strcat(display,'port_label(''output'',1,''Angle'')');
display = strcat(display,'port_label(''output'',2,''Turns'')');
display = strcat(display,'port_label(''output'',3,''Init'')');

% Set MaskDisplay and MaskDescription Strings
set_param(gcb,'MaskDisplay',display);
set_param(gcb,'MaskDescription',description);


% Base Address

BaseAddr(find(BaseAddr=='''')) = [];

index = findstr(lower(BaseAddr),'0x');

if ~isempty(index) & index==1
  BaseAddr = BaseAddr(3:end);
  baLength = length (BaseAddr);
  baseStringMember = [abs('0'):abs('9'),abs('a'):abs('f'),abs('A'):abs('F')];
  for i = 1:baLength
    if ~ismember(BaseAddr(i),baseStringMember)
      error ('Invalid character in hexadecimal string');
    end
  end
  convBaseAddr = hex2dec(BaseAddr);
else
  convBaseAddr = str2num(BaseAddr);
end

% Check For Multipule instances using the same module

if length(slot) == 1
  if slot == -1
    slotstr = 'm1';
  else
    slotstr = num2str(slot);
  end
else
  slotstr = [num2str(slot(1)),'s',num2str(slot(2))];
end

boardref=['ref',num2str(convBaseAddr),'type',num2str(BoardType),'s',slotstr];
if ~isfield(xpcquad04check,boardref)
  eval(['xpcquad04check.',boardref,'.chUsed=zeros(1,8);']);
end
level1=getfield(xpcquad04check,boardref);

if Module<1 | Module > MAX_MODULE
  error(['Module must be in between 1 and ',num2str(MAX_MODULE)]);
end
if level1.chUsed(Module) == 1
  error(['Module ',num2str(Module),' already in use']);
end
level1.chUsed(Module) = 1;

xpcquad04check = setfield(xpcquad04check,boardref,level1);

%% EOF menccbcioquad.m
