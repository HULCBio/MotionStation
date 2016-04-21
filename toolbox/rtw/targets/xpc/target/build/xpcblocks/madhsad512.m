function [convBaseAddr, SampleTime, SampleOffset] = madhsad512 (flag, Channels, Range, Sample, BaseAddr)

% MADHSAD512 - InitFcn and Mask Initialization for HS AD 512 A/D Section

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $

% Initialize Data Values
persistent pool;

if flag == 0
  pool = [];
  return;
end

MAX_CHANNEL = 8;

% Get Length Channel Vector
chnLength = length(Channels);

% Label Output Ports

% Set MaskDisplay
chnDisplay = 'disp(''AD512\nHumusoft\nA/D'');';

% Compose MaskDisplay String
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

% Check Range Vector
rangeLength =  length(Range);

if rangeLength ~= chnLength
  error ('Length of the range and channel vectors must be equal');
end

RangeElements = [-10,10,-5,5];

for i = 1:rangeLength
  if ~ismember(Range(i),RangeElements)
    error ('Invalid range value: valid range values are -5 , 5, -10, 10');
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

% Check For Multipule instances using the same channel

boardref=['ref',num2str(convBaseAddr)];
if ~isfield(pool,boardref)
  eval(['pool.',boardref,'.chUsed=zeros(1,8);']);
end
level1=getfield(pool,boardref);
for i = 1:length(Channels)
  channel=Channels(i);
  if channel<1 | channel > MAX_CHANNEL
    error(['Elements of the channel vector must be in between 1 and ',num2str(MAX_CHANNEL)]);
  end
  if level1.chUsed(channel)==1
    error(['Channel ',num2str(channel),' already in use']);
  end
  level1.chUsed(channel)=1;
end

pool=setfield(pool,boardref,level1);

%% EOF madhdad512.c
