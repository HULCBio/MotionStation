function [canBR, ...
    canList, ...
    canDirect, ...
    canType, ...
    canSize, ...
    initarray, ...
    termarray]= mxpccan(can1BR, can1UserBR, init, term)

%[can1UserBR, can1SendS, can1SendE, can1RecS, can1RecE, can1RecSI, can1RecEI, initarray, termarray]= mcan527(can1Baudrate, can1UserBR, init, term)

% MXPCCAN - Mask Initialization function for Intel 82527 Can (Targetbox)

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:25:04 $

setupBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','can527setup');

if length(setupBlocks)>1
    error('Only one instance of the CAN TargetBox Setup block allowed in a model');
end

maxObj=14;

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

canBR= can1UserBR;

if ~isempty(init)
  checkInitTerm(init);
end
if ~isempty(term)
  checkInitTerm(term);
end

%can1SendS=[];
%can1SendE=[];
%can1RecS=[];
%can1RecE=[];

canIds=[];
canDirect=[];
canType=[];
canSize=[];


%collect send identifiers
sendBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','can527send');
if ~isempty(sendBlocks)
  for i=1:length(sendBlocks)
    parameters= get_param(sendBlocks{i},'MaskValues');
    identifiers=eval(parameters{2});
    if strcmp(parameters{1},'Standard (11-bit)')
      type=zeros(1,length(identifiers));
    else
      type=ones(1,length(identifiers));
    end
    cansizes=eval(parameters{3});
    if length(cansizes)==1
        cansizes= cansizes*ones(1,length(identifiers));
    end
    if length(cansizes)~=length(identifiers)
        error('can size problem')
    end
    checkIdentifiers(identifiers, type);
    canIds=[canIds,identifiers];
    canDirect=[canDirect,zeros(1,length(identifiers))];
    canType=[canType,type];
    canSize=[canSize,cansizes];
  end
end

%collect receive identifiers
recBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','can527receive');
if ~isempty(recBlocks)
  for i=1:length(recBlocks)
    parameters= get_param(recBlocks{i},'MaskValues');
    identifiers=eval(parameters{2});
    if strcmp(parameters{1},'Standard (11-bit)')
      type=zeros(1,length(identifiers));
    else
      type=ones(1,length(identifiers));
    end
    cansizes=eval(parameters{3});
    if length(cansizes)==1
        cansizes= cansizes*ones(1,length(identifiers));
    end
    if length(cansizes)~=length(identifiers)
        error('can size problem')
    end
    checkIdentifiers(identifiers, type);
    canIds=[canIds,identifiers];
    canDirect=[canDirect,ones(1,length(identifiers))];
    canType=[canType,type];
    canSize=[canSize,cansizes];
  end
end

%collect initialization identifiers
for i=1:length(init)
    if strcmp(lower(init(i).type),'standard')
        can1SendS=[can1SendS,init(i).identifier];
    else
        can1SendE=[can1SendE,init(i).identifier];
    end
end

%collect termination identifiers
for i=1:length(term)
    if strcmp(lower(term(i).type),'standard')
        can1SendS=[can1SendS,term(i).identifier];
    else
        can1SendE=[can1SendE,term(i).identifier];
    end
end


%can1SendS=unique(can1SendS);
%can1SendE=unique(can1SendE);
%can1RecS=unique(can1RecS);
%can1RecE=unique(can1RecE);
%canList= unique([can1SendS,can1SendE,can1RecS,can1RecE]); 

[canList, ids]= unique(canIds);
canDirect=canDirect(ids);
canType=canType(ids);
canSize=canSize(ids);

if length(canList) > maxObj
    error(['The number of send-objects and receive-objects cannot exceed ',num2str(maxObj)]);
end

%derive index vectors for send blocks
sendBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','can527send');
if ~isempty(sendBlocks)
  for i=1:length(sendBlocks)
    parameters= get_param(sendBlocks{i},'MaskValues');
    identifiers=eval(parameters{2});
    if strcmp(parameters{1},'Standard (11-bit)')
        setIdxParam(1,sendBlocks{i},canList,identifiers);
    else
        setIdxParam(1,sendBlocks{i},canList,identifiers);
    end
  end
end

%derive index vectors for receive blocks
recBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','can527receive');
if ~isempty(recBlocks)
  for i=1:length(recBlocks)
    parameters= get_param(recBlocks{i},'MaskValues');
    identifiers=eval(parameters{2});
    if strcmp(parameters{1},'Standard (11-bit)')
        setIdxParam(1,recBlocks{i},canList,identifiers);
        %can1RecSI=setIntFlag(can1RecSI,recBlocks{i},can1RecS,identifiers);
    else
        setIdxParam(1,recBlocks{i},canList,identifiers);
        %can1RecEI=setIntFlag(can1RecEI,recBlocks{i},can1RecE,identifiers);
    end
  end
end


%derive initialization array
if ~isempty(init)
initarray=length(init);
start=2;
for i=1:length(init)
  initarray(start)=init(i).port;
  if init(i).port==1
    if strcmp(lower(init(i).type),'standard')
      initarray(start+1)=0;
      index=find(can1SendS==init(i).identifier);
      initarray(start+2)=index-1;
    else
      initarray(start+1)=0;
      index=find(can1SendE==init(i).identifier)+length(can1SendS);
      initarray(start+2)=index-1;
    end
  else
    if strcmp(lower(init(i).type),'standard')
      initarray(start+1)=1;
      index=find(can2SendS==init(i).identifier);
      initarray(start+2)=index-1;
    else
      initarray(start+1)=1;
      index=find(can2SendE==init(i).identifier)+length(can2SendS);
      initarray(start+2)=index-1;
    end
  end
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
  if term(i).port==1
    if strcmp(lower(term(i).type),'standard')
      termarray(start+1)=0;
      index=find(can1SendS==term(i).identifier);
      termarray(start+2)=index-1;
    else
      termarray(start+1)=0;
      index=find(can1SendE==term(i).identifier)+length(can1SendS);
      termarray(start+2)=index-1;
    end
  else
    if strcmp(lower(term(i).type),'standard')
      termarray(start+1)=1;
      index=find(can2SendS==term(i).identifier);
      termarray(start+2)=index-1;
    else
      termarray(start+1)=1;
      index=find(can2SendE==term(i).identifier)+length(can2SendS);
      termarray(start+2)=index-1;
    end
  end
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
  

