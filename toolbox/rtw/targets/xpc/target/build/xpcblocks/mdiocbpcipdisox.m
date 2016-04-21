function [boardType, filtervec, maskDisplay, maskDescription]= mdiocbpcipdisox(action, port, channels, filtervec, pciSlot)

% MPCI8255 - Mask Initialization for all PCI boards with DIO supported by 8255

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 03:58:10 $

if action==1
    
    % collect information accross blocks
    
    maskType=get_param(gcb, 'MaskType');
    maskType= maskType(3:end);
    inBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType', ['di',maskType]);
    outBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',['do',maskType]);
    
    % create signature, define field using signature, assign fields and values
    
    info=[];
    
    blocks=[inBlocks;outBlocks];
    transition= length(inBlocks);
    
    signatures={};
    
    maskValues= get_param(blocks,'MaskValues');
    for i=1:length(blocks)
        % create signature
        signature=[];
        try
            pciSlot= eval([maskValues{i}{5},';']);
        catch
            error('PCI slot cannot be evaluated');
        end
        if length(pciSlot)==2
            pciSlot=1000*pciSlot(1)+pciSlot(2);
        end
        tmp='';
        if pciSlot>=0
            tmp= num2str(pciSlot);
        end
        signature= [signature, 'b', tmp];
        signature= [signature, 'p', maskValues{i}{3}];
        % create signature field if necessary
        if ~isfield(info, signature)
            eval(['info.',signature,'.channels= zeros(2,8);']);
            eval(['info.',signature,'.filters= zeros(1,8);']);
        end
        if i>transition
            direction=2;
        else
            direction=1;
        end
        signatures= [signatures, {signature}];
        % check channels and filter
        try
            channels= eval([maskValues{i}{1},';']);
        catch
            error('Channel vector cannot be evaluated');
        end
        try
            filters= eval([maskValues{i}{2},';']);
        catch
            error('Filter vector cannot be evaluated');
        end
        % scalar expansion of filter parameter
        if length(filters==1)
            filters= filters * ones(1, length(channels));
        end
        if length(filters) ~=length(channels);
            filters=zeros(1, length(channels));
        end
        eval(['chan= info.',signature,'.channels;']);
        eval(['filtvec = info.',signature,'.filters;']);
        for k=1:length(channels)
          if channels(k)>0 & channels(k)<9
            if chan(direction,channels(k))==1
              switch direction
               case 1
                error(['Input channel ',num2str(channels(k)),' is accessed by more than one input block. This introduces unnecessary additional latency by the drivers.']);
               case 2
                error(['Output channel ',num2str(channels(k)),' is accessed by more than one output block. This introduces unnecessary additional latency by the drivers.']);
              end
            end
            chan(direction,channels(k))=1;
            if filters(k)==0 | filters(k)==1
              if filtvec(channels(k))==0
                filtvec(channels(k))=filters(k);
              end
            end
          end
        end
        eval(['info.',signature,'.channels= chan;']);
        eval(['info.',signature,'.filters= filtvec;']);
    end
    
    % setup filter info 
    for i=1:length(blocks)
        eval(['tmp= info.',signatures{i},'.filters;']);
        filtervec = 0;
        for k=1:length(tmp) 
            filtervec = bitset(filtervec,k,tmp(k));
        end
        set_param(blocks{i},'UserData',filtervec);
    end    
            
else
    
    maskType=get_param(gcb, 'MaskType');
    directionStr= maskType(1:2);
    if strcmp(directionStr, 'di')
        direction=1;
    elseif strcmp(directionStr, 'do')
        direction=2;
    end    
    maskType= maskType(3:end);
    
    if strcmp(maskType,'cbpcipdiso8')
        maskDisplay='disp(''PCI-DISO8\nComputerBoards\n';
        maskDescription=['PCI-DISO8',10,'ComputerBoards',10];
        boardType=1;
    elseif strcmp(maskType,'cbpcipdiso16')
        maskDisplay='disp(''PCI-DISO16\nComputerBoards\n';
        maskDescription=['PCI-DISO16',10,'ComputerBoards',10];
        boardType=2;
    else
        error('Unknown board type');
    end
    
    % check channel vector
    
    if ~isa(channels,'double')
        error('Channel vector must be of class ''double''');
    end
    if size(channels,1)>1
        error('Channel vector must be a row vector');
    end
    channels= round(channels);
    occupied=zeros(1,8);
    for i=1:length(channels)
        channel=channels(i);
        if channel<1 | channel >8
            error('Channel vector elements must be in the range 1..8');
        end
        if occupied(channel)==1
            error('Don''t access a channel more than once because this will introduce unnessecary additional latency by the driver.');
        end
        occupied(channel)=1;
    end
    
    % check filter vector
    
    if ~isa(filtervec,'double')
        error('Filter vector must be of class ''double''');
    end
    if size(filtervec,1)>1
        error('Filter vector must be a row vector');
    end
    filtervec = round(filtervec);
    % scalar expansion
    if length(filtervec)==1
        filtervec= filtervec*ones(1,length(channels));
    end
    if length(channels)~=length(filtervec)
        error('Filter vector must have the same length as the channel vector');
    end
    for i=1:length(filtervec)
        filtvec = filtervec(i);
        if filtvec < 0 | filtvec >1
            error('Filter vector elements must be either 0 or 1');
        end
    end
    
    if direction==1
      maskDisplay=[maskDisplay,'Digital Input'');'];
      for i=1:length(channels)
        maskDisplay=[maskDisplay,'port_label(''output'',',num2str(i),',''',num2str(channels(i)),''');'];
      end       
      maskDescription= [maskDescription, 'Digital Input'];
    elseif direction==2
      maskDisplay=[maskDisplay,'Digital Output'');'];
      for i=1:length(channels)
        maskDisplay=[maskDisplay,'port_label(''input'',',num2str(i),',''',num2str(channels(i)),''');'];
      end   
      maskDescription= [maskDescription, 'Digital Output'];
    end
    
    
    filtervec = get_param(gcb, 'UserData');
    if isempty(filtervec)
        filtervec = 0;
    end
    
end
        
