function [convBaseAddr, SampleTime, SampleOffset] = mdohsad512 (flag, Channels, Sample, BaseAddr)

% MDOHSAD512 - InitFcn and Mask Initialization for HS AD 512 Digital Output Section

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $

persistent pool;

% Initialize Data Values
if flag == 0
  pool = [];
  return;
end

MAX_CHANNEL = 8;

% Get Length Channel Vector

chnLength = length (Channels);

% Label Input Ports

% Set MaskDisplay

chnDisplay = 'disp(''AD512\nHumusoft\nDigital Output'');';

% Compose MaskDisplay String

for i = 1:chnLength
  chnDisplay = strcat (chnDisplay,'port_label(''input'', ');
  chnDisplay = strcat (chnDisplay,num2str (i));
  chnDisplay = strcat (chnDisplay,' , ''');
  chnDisplay = strcat (chnDisplay, num2str (Channels(1,i)));
  chnDisplay = strcat (chnDisplay, ''') ');
end

% Set MaskDisplay String

set_param (gcb,'MaskDisplay',chnDisplay);

% Check Parameters

% Check Channel Vector
for i = 1:chnLength
  if (Channels(1,i) > (MAX_CHANNEL) | (Channels(1,i) < 0))
    error (['Channel must be between 0 and ',num2str (MAX_CHANNEL)])
  end

  for j = 1:(i-1)
    if Channels(i) == Channels(j)
      error ('Multi enteries of the same channel are not allowed')
    end
  end
end


% Check Sample Time
sampleLength = length (Sample);

if (sampleLength > 2)
  error (['Sample length vector cannot exceed size',num2str (MAX_CHANNEL)]);
end

if (sampleLength == 2)
  SampleTime = Sample(1,1);
  SampleOffset = Sample(1,2);
else
  SampleTime = Sample(1,1);
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
  eval(['pool.',boardref,'.Used=0;']);
end

level1=getfield(pool,boardref);

if level1.Used==1
  error('Hardware limits the digital output to one instance');
end

level1.Used=1;
pool=setfield(pool,boardref,level1);

% EOF mdohsad512.m