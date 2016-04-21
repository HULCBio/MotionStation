function [convBaseAddr, SampleTime, SampleOffset] = madadvpcl818 (flag, boardType, Channels, Range, Mux, Sample, BaseAddr)

% MADADVPCL818 - InitFcn and Mask Initialization for Advantech PCL-818 family A/D section

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 04:04:33 $

% Initialize Data Values
persistent pool;

if flag == 0
  pool = [];
  return;
end

if Mux == 1
   MAX_CHANNEL=16;   
else
   MAX_CHANNEL=8;
end

switch boardType
case 1	
   chnDisplay='disp(''PCL-818\nAdvantech\n';
   description='PCL-818';
   RangeElements = [-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25];
   RangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
case 2
   chnDisplay='disp(''PCL-818L\nAdvantech\n';
   description='PCL-818L';
   RangeElements = [-5, -2.5, -1.25, -0.625];
   RangeStr='-5, -2.5, -1.25, -0.625';
case 3
   chnDisplay='disp(''PCL-818H\nAdvantech\n';
   description='PCL-818H';
   RangeElements = [-5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25, -10];
   RangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
case 4
   chnDisplay='disp(''PCL-818HD\nAdvantech\n';
   description='PCL-818HD';
   RangeElements = [-5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25, -10];
   RangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
case 5
   chnDisplay='disp(''PCL-818HG\nAdvantech\n';
   description='PCL-818HG';
   RangeElements = [-5, -0.5, -0.05, -0.005, 10, 1, 0.1, 0.01, -10, -1, -0.1, -0.01];
   RangeStr='-10, -5, -1, -0.5, -0.1, -0.05, -0.01, -0.005, 10, 1, 0.1, 0.01';
case 9
   chnDisplay='disp(''PCL-1800\nAdvantech\n';
   description='PCL-1800';
   RangeElements = [-5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25, -10];
   RangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
end

% Get Length Channel Vector
chnLength = length(Channels);

% Label Output Ports

% Compose MaskDisplay String
chnDisplay=[chnDisplay,'Analog Input'');'];
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
for i=1:chnLength
   if (Channels(i)<1 | Channels(i)>MAX_CHANNEL)
      error(['The number of channels must be in the range 1..',num2str(MAX_CHANNEL)]);
   end
end

rangeLength =  length(Range);

if rangeLength ~= chnLength
  error ('Length of the range and channel vectors must be equal');
end

for i = 1:rangeLength
  if ~ismember(Range(i),RangeElements)
    error (['Invalid range value: valid range values are ', RangeStr]);
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
  eval(['level1.',boardref,'.chUsed=zeros(1,16);']);
end
level2=getfield(level1,boardref);
for i = 1:length(Channels)
  channel=Channels(i);
  if channel<1 | channel > MAX_CHANNEL
    error(['Elements of the channel vector must be in between 1 and ',num2str(MAX_CHANNEL)]);
  end
  if level2.chUsed(channel)==1
    error(['Channel ',num2str(channel),' already in use']);
  end
  level2.chUsed(channel)=1;
end

level1=setfield(level1,boardref,level2);
pool=setfield(pool,boardtype,level1);

%% EOF madadvpcl818.m
