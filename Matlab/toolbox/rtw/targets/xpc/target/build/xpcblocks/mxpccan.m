function [can1UserBR, ...
    can2UserBR, ...
    can1SendS, ...
    can1SendE, ...
    can2SendS, ...
    can2SendE, ...
    can1RecS, ...
    can1RecE, ...
    can2RecS, ...
    can2RecE, ...
    can1RecSI, ...
    can1RecEI, ...
    can2RecSI, ...
    can2RecEI, ...
    initarray, ...
    termarray, ...
    ioBaseAddress, ...
  memBaseAddress] = mxpccan(phase, bType, can1BR, can1UserBR, can2BR, can2UserBR, init, term, ioBaseAddressL, memBaseAddressL, board)

% MXPCCAN - Mask Initialization function for Softing CAN driver blocks

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.9.4.2 $ $Date: 2004/03/02 03:04:55 $

% bType 1: 104
% bType 2: pci

  if phase == 1
    masktype = get_param( gcb, 'MaskType' );
    idx = findstr( masktype, 'setup' );
    type = masktype(idx-3:idx-1);
    basetype = masktype( 1:idx-1 );
    
    board = get_param( gcb, 'board' );
    
    setupBlocks=find_system(bdroot, ...
                            'FollowLinks', 'on', ...
                            'LookUnderMasks', 'all', ...
                            'MaskType', masktype, ...
                            'board', board );
   
    if length(setupBlocks)>1
      switch type
       case '104'
        error('Only one instance of the CAN-AC2-104 Setup block for a board allowed in a model');
       case 'pci'
        error('Only one instance of the CAN-AC2-PCI Setup block for a board allowed in a model');
       case 'isa'
        error('Only one instance of the CAN-AC2-ISA Setup block allowed in a model');
       case 'sae'
        error('Only one instance of the CAN-AC2-ISA (Standard/Extended) Setup block allowed in a model');
      end
    end

    sendtype = [basetype,'send'];
    sendBlocks = find_system(bdroot, ...
                             'FollowLinks', 'on', ...
                             'LookUnderMasks', 'all', ...
                             'MaskType', sendtype, ...
                             'board', board );
    
    rectype = [basetype, 'receive' ];
    recBlocks = find_system(bdroot, ...
                            'FollowLinks','on', ...
                            'LookUnderMasks','all', ...
                            'MaskType', rectype, ...
                            'board', board );
    
    % Save send and receive block lists for mask init time.
    temp = { sendBlocks, recBlocks };
    set_param( gcb, 'UserData', temp );
    
  end  % end phase 1, InitFcn

  if phase == 2  % mask init
    mtemp = get_param( gcb, 'UserData' );
    if ~isempty(mtemp)
      sendBlocks = mtemp{1};
      recBlocks = mtemp{2};
    else
      sendBlocks = [];
      recBlocks = [];
    end
    
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

    maxObj=200;

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

    can1SendS=[];
    can1SendE=[];
    can1RecS=[];
    can1RecE=[];
    can2SendS=[];
    can2SendE=[];
    can2RecS=[];
    can2RecE=[];

    %collect send identifiers
    if ~isempty(sendBlocks)
      for i=1:length(sendBlocks)
        parameters= get_param(sendBlocks{i},'MaskValues');
        if strcmp(parameters{3},'Standard (11-bit)') % range
          type=0;
        else
          type=1;
        end
        identifiers=eval(parameters{4}); % ids
        checkIdentifiers(identifiers, type);
        if strcmp(parameters{2},'CAN 1')  % canPort
          if type==0
            can1SendS=[can1SendS,identifiers];
          else
            can1SendE=[can1SendE,identifiers];
          end
        else
          if type==0
            can2SendS=[can2SendS,identifiers];
          else
            can2SendE=[can2SendE,identifiers];
          end
        end
      end
    end

    %collect receive identifiers
    if ~isempty(recBlocks)
      for i=1:length(recBlocks)
        parameters= get_param(recBlocks{i},'MaskValues');
        if strcmp(parameters{3},'Standard (11-bit)')
          type=0;
        else
          type=1;
        end
        identifiers=eval(parameters{4});
        checkIdentifiers(identifiers, type);
        if strcmp(parameters{2},'CAN 1')
          if type==0
            can1RecS=[can1RecS,identifiers];
          else
            can1RecE=[can1RecE,identifiers];
          end
        else
          if type==0
            can2RecS=[can2RecS,identifiers];
          else
            can2RecE=[can2RecE,identifiers];
          end
        end
      end
    end

    %collect initialization identifiers
    for i=1:length(init)
      if init(i).port==1
        if strcmp(lower(init(i).type),'standard')
          can1SendS=[can1SendS,init(i).identifier];
        else
          can1SendE=[can1SendE,init(i).identifier];
        end
      else
        if strcmp(lower(init(i).type),'standard')
          can2SendS=[can2SendS,init(i).identifier];
        else
          can2SendE=[can2SendE,init(i).identifier];
        end
      end
    end

    %collect termination identifiers
    for i=1:length(term)
      if term(i).port==1
        if strcmp(lower(term(i).type),'standard')
          can1SendS=[can1SendS,term(i).identifier];
        else
          can1SendE=[can1SendE,term(i).identifier];
        end
      else
        if strcmp(lower(term(i).type),'standard')
          can2SendS=[can2SendS,term(i).identifier];
        else
          can2SendE=[can2SendE,term(i).identifier];
        end
      end
    end


    can1SendS=unique(can1SendS);
    can1SendE=unique(can1SendE);
    can2SendS=unique(can2SendS);
    can2SendE=unique(can2SendE);
    can1RecS=unique(can1RecS);
    can1RecE=unique(can1RecE);
    can2RecS=unique(can2RecS);
    can2RecE=unique(can2RecE);

    if isempty(can1RecS), can1RecSI=[]; else can1RecSI=zeros(1,length(can1RecS)); end
    if isempty(can1RecE), can1RecEI=[]; else can1RecEI=zeros(1,length(can1RecE)); end
    if isempty(can2RecS), can2RecSI=[]; else can2RecSI=zeros(1,length(can2RecS)); end
    if isempty(can2RecE), can2RecEI=[]; else can2RecEI=zeros(1,length(can2RecE)); end

    if (length(can1SendS)+length(can1SendE)) > maxObj
      error(['The number of CAN1-port send-objects cannot exceed ',num2str(maxObj)]);
    end
    if (length(can2SendS)+length(can2SendE)) > maxObj
      error(['The number of CAN2-port send-objects cannot exceed ',num2str(maxObj)]);
    end
    if (length(can1RecS)+length(can1RecE)) > maxObj
      error(['The number of CAN1-port receive-objects cannot exceed ',num2str(maxObj)]);
    end
    if (length(can2RecS)+length(can2RecE)) > maxObj
      error(['The number of CAN2-port receive-objects cannot exceed ',num2str(maxObj)]);
    end


    %derive index vectors for send blocks
    if ~isempty(sendBlocks)
      for i=1:length(sendBlocks)
        parameters= get_param(sendBlocks{i},'MaskValues');
        identifiers=eval(parameters{4});
        if strcmp(parameters{2},'CAN 1')
          if strcmp(parameters{3},'Standard (11-bit)')
            setIdxParam(1,sendBlocks{i},can1SendS,identifiers);
          else
            setIdxParam(2,sendBlocks{i},can1SendE,identifiers,length(can1SendS));
          end
        else
          if strcmp(parameters{3},'Standard (11-bit)')
            setIdxParam(1,sendBlocks{i},can2SendS,identifiers);
          else
            setIdxParam(2,sendBlocks{i},can2SendE,identifiers,length(can2SendS));
          end
        end
      end
    end

    %derive index vectors for receive blocks
    if ~isempty(recBlocks)
      for i=1:length(recBlocks)
        parameters= get_param(recBlocks{i},'MaskValues');
        identifiers=eval(parameters{4});
        if strcmp(parameters{2},'CAN 1')
          if strcmp(parameters{3},'Standard (11-bit)')
            setIdxParam(1,recBlocks{i},can1RecS,identifiers);
            can1RecSI=setIntFlag(can1RecSI,recBlocks{i},can1RecS,identifiers);
          else
            setIdxParam(2,recBlocks{i},can1RecE,identifiers,length(can1RecS));
            can1RecEI=setIntFlag(can1RecEI,recBlocks{i},can1RecE,identifiers);
          end
        else
          if strcmp(parameters{3},'Standard (11-bit)')
            setIdxParam(1,recBlocks{i},can2RecS,identifiers);
            can2RecSI=setIntFlag(can2RecSI,recBlocks{i},can2RecS,identifiers);
          else
            setIdxParam(2,recBlocks{i},can2RecE,identifiers,length(can2RecS));
            can2RecEI=setIntFlag(can2RecEI,recBlocks{i},can2RecE,identifiers);
          end
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
  

