function [baseAddress, control, maskDisplay, maskDescription, reset, initValue]= misa8255(action, chip, port, channels, baseAddress, reset, initValue)

% MISA8255 - Mask Initialization for all ISA boards with DIO supported by 8255
% The reset and initValue parameters used only for output blocks.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.18.6.2 $ $Date: 2004/04/08 21:03:05 $

if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
  return
end

if action==1

    % collect information across blocks

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
        signature= [signature, 'b', get_param(blocks{i}, 'baseaddress')];
        signature= [signature, 'c', get_param(blocks{i}, 'chip')];
        % create signature field if necessary
        if ~isfield(info, signature)
            eval(['info.',signature,'.direction= zeros(1,3);']);
            eval(['info.',signature,'.channels= zeros(3,8);']);
        end
        port=abs(maskValues{i}{2})-64;
        if i>transition
            direction=2;
        else
            direction=1;
        end
        % check direction
        eval(['direct= info.',signature,'.direction;']);
        if direct(port)==1 & direction~=1
            error(['Port ',maskValues{i}{2},' is already used by a Digital Input driver block']);
        end
        if direct(port)==2 & direction~=2
            error(['Port ',maskValues{i}{2},' is already used by a Digital Output driver block']);
        end
        direct(port)=direction;
        eval(['info.',signature,'.direction= direct;']);
        signatures= [signatures, {signature}];
        % check channels
        try
            channels= eval([maskValues{i}{1},';']);
        catch
            error('Channel vector cannot be evaluated');
        end
        eval(['chan= info.',signature,'.channels;']);
        for k=1:length(channels)
            if channels(k)>0 & channels(k)<9
                if chan(port,channels(k))==1
                    error(['Channel ',num2str(channels(k)),' is already accessed by this or another block, which unnecessarily increases latency.']);
                else
                    chan(port, channels(k))=1;
                end
            end
        end
        eval(['info.',signature,'.channels= chan;']);
    end

    % calculate control
    for i=1:length(blocks)
        eval(['tmp= info.',signatures{i},'.direction;']);
        control=155;
        if tmp(1)==2
            control=bitset(control,5,0);
        end
        if tmp(2)==2
            control=bitset(control,2,0);
        end
        if tmp(3)==2
            control=bitset(control,1,0);
            control=bitset(control,4,0);
        end
        set_param(blocks{i},'UserData',control);
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

    if strcmp(maskType,'cbciodda06')
        maskDisplay='disp(''CIO-DDA06\nComputerBoards\n';
        maskDescription=['CIO-DDA06',10,'ComputerBoards',10];
        baseAddress= baseAddress+12;
    elseif strcmp(maskType,'cbciodio48')
        maskDisplay='disp(''CIO-DIO48\nComputerBoards\n';
        maskDescription=['CIO-DIO48',10,'ComputerBoards',10];
        baseAddress= baseAddress + (chip-1)*4 ;
    elseif strcmp(maskType,'cbciodas160112')
        maskDisplay='disp(''CIO-DAS1601/12\nComputerBoards\n';
        maskDescription=['CIO-DAS1601/12',10,'ComputerBoards',10];
        baseAddress= baseAddress+1024;
    elseif strcmp(maskType,'cbciodas160212')
        maskDisplay='disp(''CIO-DAS1602/12\nComputerBoards\n';
        maskDescription=['CIO-DAS1602/12',10,'ComputerBoards',10];
        baseAddress= baseAddress+1024;
    elseif strcmp(maskType,'cbciodio24')
        maskDisplay='disp(''CIO-DIO24\nComputerBoards\n';
        maskDescription=['CIO-DIO24',10,'ComputerBoards',10];
        baseAddress= baseAddress+0;
    elseif strcmp(maskType,'cbciodio96')
        maskDisplay='disp(''CIO-DIO96\nComputerBoards\n';
        maskDescription=['CIO-DIO96',10,'ComputerBoards',10];
        baseAddress= baseAddress + (chip-1)*4;
    elseif strcmp(maskType,'cbciodio192')
        maskDisplay='disp(''CIO-DIO192\nComputerBoards\n';
        maskDescription=['CIO-DIO192',10,'ComputerBoards',10];
        baseAddress= baseAddress + (chip-1)*4;
    elseif strcmp(maskType,'cbciodio24h')
        maskDisplay='disp(''CIO-DIO24H\nComputerBoards\n';
        maskDescription=['CIO-DIO24H',10,'ComputerBoards',10];
        baseAddress= baseAddress+0;
    elseif strcmp(maskType,'cbciodio48h')
        maskDisplay='disp(''CIO-DIO48H\nComputerBoards\n';
        maskDescription=['CIO-DIO48H',10,'ComputerBoards',10];
        baseAddress= baseAddress + (chip-1)*4;
    elseif strcmp(maskType,'cbciodas160216')
        maskDisplay='disp(''CIO-DAS1602/16\nComputerBoards\n';
        maskDescription=['CIO-DAS1602/16',10,'ComputerBoards',10];
        baseAddress= baseAddress+1024;
    elseif strcmp(maskType,'cbciodda0616')
        maskDisplay='disp(''CIO-DDA06/16\nComputerBoards\n';
        maskDescription=['CIO-DDA06/16',10,'ComputerBoards',10];
        baseAddress= baseAddress+12;
    elseif strcmp(maskType,'cbpc104dio48')
        maskDisplay='disp(''PC104-DIO48\nComputerBoards\n';
        maskDescription=['PC104-DIO48',10,'ComputerBoards',10];
        baseAddress= baseAddress + (chip-1)*4;
    elseif strcmp(maskType,'nipcdio24')
        maskDisplay='disp(''PC-DIO-24\nNational Instr.\n';
        maskDescription=['PC-DIO-24',10,'National Instruments',10];
        baseAddress= baseAddress + (chip-1)*4;
    elseif strcmp(maskType,'rtddm6604')
        maskDisplay='disp(''DM6604\nRTD\n';
        maskDescription=['DM6604',10,'Real Time Devices',10];
        baseAddress= baseAddress+0;
    elseif strcmp(maskType,'rtddm6804')
        maskDisplay='disp(''DM6804\nRTD\n';
        maskDescription=['DM6804',10,'Real Time Devices',10];
        baseAddress= baseAddress+0;
    elseif strcmp(maskType,'dsmm32')
        maskDisplay='disp(''MM-32\nDiamond\n';
        maskDescription=['MM-32',10,'Diamond Systems',10];
        baseAddress= baseAddress+12;
    elseif strcmp(maskType,'dsrubymm')
        maskDisplay='disp(''Ruby-MM\nDiamond\n';
        maskDescription=['Ruby-MM',10,'Diamond Systems',10];
        baseAddress= baseAddress+12;
    elseif strcmp(maskType,'dsrubymm416')
        maskDisplay='disp(''Ruby-MM-416\nDiamond\n';
        maskDescription=['Ruby-MM-416',10,'Diamond Systems',10];
        baseAddress= baseAddress+12;
    elseif strcmp(maskType,'dsrubymm1612')
        maskDisplay='disp(''Ruby-MM-1612\nDiamond\n';
        maskDescription=['Ruby-MM-1612',10,'Diamond Systems',10];
        baseAddress= baseAddress+4;
    elseif strcmp(maskType,'dsonyxmm')
        maskDisplay='disp(''Onyx-MM\nDiamond\n';
        maskDescription=['Onyx-MM',10,'Diamond Systems',10];
        baseAddress= baseAddress + (chip-1)*4 ;
    elseif strcmp(maskType,'dsonyxmmdio')
        maskDisplay='disp(''Onyx-MM-DIO\nDiamond\n';
        maskDescription=['Onyx-MM-DIO',10,'Diamond Systems',10];
        baseAddress= baseAddress + (chip-1)*4 ;
    elseif strcmp(maskType,'dsgarnetmm')
        maskDisplay='disp(''Garnet-MM\nDiamond\n';
        maskDescription=['Garnet-MM',10,'Diamond Systems',10];
        baseAddress= baseAddress + (chip-1)*4 ;
    elseif strcmp(maskType,'dsprometheus')
        maskDisplay='disp(''Prometheus\nDiamond\n';
        maskDescription=['Prometheus',10,'Diamond Systems',10];
        baseAddress= baseAddress + 8;
    else
        error(['The generic ISA 8255 driver does not recognize the mask type ' maskType]);
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

    if direction == 2 % if output, check reset and initValue parameters
        if ~isa(reset, 'double')
          error('Reset vector parameter must be of class double');
        end
        if size(reset) == [1 1]
          reset = reset * ones(size(channels));
        elseif ~all(size(reset) == size(channels))
          error('Reset vector must be a scalar or have the same number of elements as the Channel vector');
        end
        reset = round(reset);
        if ~all(ismember(reset, [0 1]))
          error('Reset vector elements must be 0 or 1');
        end

        if ~isa(initValue, 'double')
          error('Initial value vector parameter must be of class double');
        end
        if size(initValue) == [1 1]
          initValue = initValue * ones(size(channels));
        elseif ~all(size(initValue) == size(channels))
          error('Initial value must be a scalar or have the same number of elements as the Channel vector');
        end
        initValue = round(initValue);
        if ~all(ismember(initValue, [0 1]))
          error('Initial value vector elements must be 0 or 1');
        end
    end


    control= get_param(gcb, 'UserData');
    if isempty(control)
        control=155;
    end

    if strcmp(maskType,'dsmm32')
        control= control + 15000;
    end

end
