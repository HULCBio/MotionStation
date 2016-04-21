function [convBaseAddr, SampleTime, SampleOffset] = mdiadvpcl812 (flag, boardType, Channels, Sample, BaseAddr)

% MDIADVPCL812 - InitFcn and Mask Initialization for Advantech PCL-812 family digital input section

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 04:09:41 $

% Initialize Data Values
persistent pool;

if flag == 0
  pool = [];
  return;
end

MAX_CHANNEL = 16;

switch boardType
case 1	
   chnDisplay='disp(''PCL-812\nAdvantech\n';
   description='PCL-812';
case 2
   chnDisplay='disp(''PCL-812PG\nAdvantech\n';
   description='PCL-812PG';
case 3
   chnDisplay='disp(''PCL-711B\nAdvantech\n';
   description='PCL-711B';
end

% Get Length Channel Vector
chnLength = length(Channels);

% Label Input Ports

% Compose MaskDisplay String
chnDisplay=[chnDisplay,'Digital Input'');'];
for i = 1:chnLength
  chnDisplay = strcat(chnDisplay,'port_label(''output'', ');
  chnDisplay = strcat(chnDisplay,num2str (i));
  chnDisplay = strcat(chnDisplay,' , ''');
  chnDisplay = strcat(chnDisplay, num2str (Channels(1,i)));
  chnDisplay = strcat(chnDisplay, ''') ');
end

% Set MaskDisplay String
set_param(gcb,'MaskDisplay',chnDisplay);

% Check Parameters

% Check Channel Vector
% Check Parameters
for i=1:chnLength
   if (Channels(i)<1 | Channels(i)>MAX_CHANNEL)
      error(['The channel numbers must be in the range 1..',num2str(MAX_CHANNEL)]);
   end
end

for j = 1:(i-1)
  if Channels(i) == Channels(j)
    error ('Multiple enteries of the same channel are not allowed')
  end
end

% Check sample time

sampleLength = length (Sample);

if (sampleLength > 2)
  error ('Sample length vector cannot exceed two elements');
end

if (sampleLength == 2)
  SampleTime = Sample(1);
  SampleOffset = Sample(2);
else
  SampleTime = Sample(1);
  SampleOffset = 0;
end

% Check Base Address

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

% Check For Multiple instances using the same channel

boardtype=['btype',num2str(boardType)];
boardref=['ref',num2str(convBaseAddr)];
if ~isfield(pool,boardtype)
  eval(['pool.',boardtype,'=[];']);
end
level1=getfield(pool,boardtype);
if ~isfield(level1,boardref)
  eval(['level1.',boardref,'.Used=0;']);
end
level2=getfield(level1,boardref);
if level2.Used==1
  error('Only one block per physical board supported (hardware limitation)');
end
level2.Used=1;
level1=setfield(level1,boardref,level2);
pool=setfield(pool,boardtype,level1);

% EOF mdiadvpcl812.m
