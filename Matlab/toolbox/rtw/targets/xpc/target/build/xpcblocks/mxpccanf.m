function [can1UserBR, ...
    can2UserBR, ...
    initarray, ...
    termarray, ...
    ioBaseAddress, ...
  memBaseAddress]= mxpccanf(bType, can1BR, can1UserBR, can2BR, can2UserBR, init, term, ioBaseAddressL, memBaseAddressL, board)

% MXPCCANF - Mask Initialization function for Softing CAN driver blocks (FIFO mode)

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 03:58:54 $

% bType 1: 104
% bType 2: pci

switch bType
case {1}
  ioBaseAddress=convertAddress(ioBaseAddressL);
  memBaseAddress=convertAddress(memBaseAddressL);
  if memBaseAddress<819200 | memBaseAddress>884736
    error('Memory Base Address must be in the range 0xc8000..0xd8000');
  end
case {3,4}
  ioBaseAddress=0;
  memBaseAddress=0;
end

switch can1BR
case 1
  can1UserBR=[1,1,4,3];
case 2
  can1UserBR=[1,1,6,3];
case 3
  can1UserBR=[1,1,8,7];
case 4
  can1UserBR=[2,1,8,7];
case 5
  can1UserBR=[4,1,8,7];
case 6
  can1UserBR=[4,4,11,8];
case 7
  can1UserBR=[32,4,16,8];
case 8
  checkUserBR(can1UserBR,1)
end

switch can2BR
case 1
  can2UserBR=[1,1,4,3];
case 2
  can2UserBR=[1,1,6,3];
case 3
  can2UserBR=[1,1,8,7];
case 4
  can2UserBR=[2,1,8,7];
case 5
  can2UserBR=[4,1,8,7];
case 6
  can2UserBR=[4,4,11,8];
case 7
  can2UserBR=[32,4,16,8];
case 8
  checkUserBR(can2UserBR,2)
end

if ~isempty(init)
  checkInitTerm(init);
end
if ~isempty(term)
  checkInitTerm(term);
end

%derive initialization array
if ~isempty(init)
initarray=length(init);
start=2;
for i=1:length(init)
  initarray(start)=init(i).port;
  if strcmp(lower(init(i).type),'standard')
    initarray(start+1)=0;
  else
    initarray(start+1)=1;
  end
  initarray(start+2)=init(i).identifier;
  initarray(start+3)=length(init(i).data);
  for j=1:8
    if j>length(init(i).data)
      tmp=0;
    else
      tmp=init(i).data(j);
    end
    initarray(start+3+j)=tmp;
  end
  initarray(start+3+9)=init(i).pause;
  start=start+13;
end
else
  initarray=0;
end

%derive termination array
if ~isempty(term)
termarray=length(term);
start=2;
for i=1:length(term)
  termarray(start)=term(i).port;
  if strcmp(lower(term(i).type),'standard')
    termarray(start+1)=0;
  else
    termarray(start+1)=1;
  end
  termarray(start+2)=term(i).identifier;
  termarray(start+3)=length(term(i).data);
  for j=1:8
    if j>length(term(i).data)
      tmp=0;
    else
      tmp=term(i).data(j);
    end
    termarray(start+3+j)=tmp;
  end
  termarray(start+3+9)=term(i).pause;
  start=start+13;
end
else
  termarray=0;
end

function addrnum=convertAddress(addrstr)

if length(addrstr)<2
  error('Base Addresses must begin with 0x denoting hexadecimal values');
end
if addrstr(1)~='0' | addrstr(2)~='x'
  error('Base Addresses must begin with 0x denoting hexadecimal values');
end
addrnum=hex2dec(addrstr(3:end));
if isempty(addrnum)
  error('Invalid Base Address specified');
end


function checkInitTerm(str)
if ~isa(str,'struct')
  error('Initialization and Termination parameter must be a struct');
end
if size(str,1)~=1
  error('Initialization and Termination parameter must be a row vector struct');
end
for k=1:length(str)
  tmp=str(k);
  if ~isfield(tmp,'port')
    error('Initialization and Termination struct must have field: port');
  end
  if ~isfield(tmp,'type')
    error('Initialization and Termination struct must have field: type');
  end
  if ~isfield(tmp,'identifier')
    error('Initialization and Termination struct must have field: identifier');
  end
  if ~isfield(tmp,'data')
    error('Initialization and Termination struct must have field: data');
  end
  if ~isfield(tmp,'pause')
    error('Initialization and Termination struct must have field: pause');
  end
  if ~isa(tmp.port,'double')
    error('Initialization and Termination struct: port field value must be of class double');
  end
  if size(tmp.port,1)~=1 |  size(tmp.port,2)~=1
    error('Initialization and Termination struct: port field value must be a scalar');
  end
  if tmp.port~=1 & tmp.port~=2
    error('Initialization and Termination struct: port field value must be either 1 or 2');
  end
  if ~isa(tmp.type,'char')
    error('Initialization and Termination struct: type field value must be of class char');
  end
  if ~strcmp(lower(tmp.type),'standard') & ~strcmp(lower(tmp.type),'extended')
    error('Initialization and Termination struct: type field value must be either ''standard'' or ''extended''');
  end
  if strcmp(lower(tmp.type),'standard')
    checkIdentifiers(tmp.identifier, 0);
  else
    checkIdentifiers(tmp.identifier, 1);
  end
  if ~isa(tmp.data,'double')
    error('Initialization and Termination struct: data field value must be of class double');
  end
  if size(tmp.data,1)~=1
    error('Initialization and Termination struct: data field value must be a row vector');
  end
  if size(tmp.data,2)>8
    error('Initialization and Termination struct: data field value must be a row vector with no more than 8 elements');
  end
  for i=1:length(tmp.data)
    if tmp.data(i)<0 | tmp.data(i)>255
      error('Initialization and Termination struct: data field value elements must be in the range 0..255');
    end
  end
  if ~isa(tmp.pause,'double')
    error('Initialization and Termination struct: pause field value must be of class double');
  end
  if size(tmp.pause,1)~=1 |  size(tmp.pause,2)~=1
    error('Initialization and Termination struct: pause field value must be a scalar');
  end
end


function setIdxParam(type,block,list,ids,nStand)
param='[';
for i=1:length(ids)
  index=find(list==ids(i));
  if type==2
    index=nStand+index;
  end
  param=[param,num2str(index-1),','];
end
param(end)=[];
param= [param,']'];
set_param(block,'ididx',param);


function intArray=setIntFlag(intArray,block,list,ids)
if strcmp(get_param(block,'inten'),'off')
  return
end
for i=1:length(ids)
  index=find(list==ids(i));
  intArray(index)=1;
end

function checkIdentifiers(ids, type)

maxIdSt=2031;
maxIdExt=536870911;

if ~isa(ids,'double')
  error('Identfiers parameter must be a double array');
end
if size(ids,1)~=1
  error('Identifiers parameter must be a row vector');
end
for i=1:length(ids)
  if type==0
    if ids(i) > maxIdSt | ids(i)<0
      error(['Standard identifiers must be in the range 0..',num2str(maxIdSt+1)]);
    end
  else  
    if ids(i) > (maxIdExt) | ids(i)<0
      error(['Extended identifiers must be in the range 0..',num2str(maxIdExt)]);
    end
  end
end

function checkUserBR(userBR, port)
if ~isa(userBR,'double')
  error(['CAN Port ',num2str(port),': User defined baudrate parameter must be a double array']);
end
if size(userBR,1)~=1 | size(userBR,2)~=4
  error(['CAN Port ',num2str(port),': User defined baudrate parameter must be a row vector with four elements']);
end
if userBR(1) < 1 | userBR(1) > 32
  error(['CAN Port ',num2str(port),': Prescaler of user defined baudrate must be in the range 1..32']);
end
if userBR(2) < 1 | userBR(2) > 4
  error(['CAN Port ',num2str(port),': Synchronisation-Jump-Width of user defined baudrate must be in the range 1..4']);
end
if userBR(3) < 1 | userBR(3) > 16
  error(['CAN Port ',num2str(port),': Time-Segment 1 of user defined baudrate must be in the range 1..16']);
end
if userBR(4) < 1 | userBR(4) > 8
  error(['CAN Port ',num2str(port),': Time-Segment 2 of user defined baudrate must be in the range 1..8']);
end
tmp= 1 + userBR(3) + userBR(4);
if tmp < 8 | tmp > 25
  error(['CAN Port ',num2str(port),': Value (1 + tseg1 + tseg2) of user defined baudrate must be in the range 8..25']);
end
if (userBR(3)+userBR(4)) < (2*userBR(2))
  error(['CAN Port ',num2str(port),': Value (tseg1 + tseg2) must be greater or equal than value (2 * sjw) of user defined baudrate']);
end
if (userBR(2)<1) | (userBR(2) > userBR(4))
  error(['CAN Port ',num2str(port),': Value (sjw) of user defined baudrate must be in the range 1..(tseg2)']);
end
  

