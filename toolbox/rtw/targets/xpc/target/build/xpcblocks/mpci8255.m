function [boardType, control, maskDisplay, maskDescription, reset, initValue] = mpci8255(action, chip, port, channels, pciSlot, reset, initValue)

% MPCI8255 - Mask Initialization for all PCI boards with DIO supported by 8255
% (reset and initValue parameters are only used for digital output)
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.14.4.1 $ $Date: 2004/04/08 21:03:07 $

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
            pciSlot= evalin('base', [get_param(blocks{i}, 'slot'),';']);
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
            channels= evalin('base',[maskValues{i}{1},';']);
        catch
            error('Channel vector cannot be evaluated');
        end
        eval(['chan= info.',signature,'.channels;']);
        for k=1:length(channels)
            if channels(k)>0 & channels(k)<9
                if chan(port,channels(k))==1
                    error(['Channel ',num2str(channels(k)),' is already accessed by another block. This introduces unnecessary additonal latency by the drivers.']);
                end
            end
        end
        if channels(k)>0 & channels(k)<9
            chan(port, channels(k))=1;
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

    if strcmp(maskType,'cbpcidas160216')
        maskDisplay='disp(''PCI-DAS1602/16\nComputerBoards\n';
        maskDescription=['PCI-DAS1602/16',10,'ComputerBoards',10];
        boardType=1;
    elseif strcmp(maskType,'cbpcidas1200')
        maskDisplay='disp(''PCI-DAS1200\nComputerBoards\n';
        maskDescription=['PCI-DAS1200',10,'ComputerBoards',10];
        boardType=2;
    elseif strcmp(maskType,'cbpcidas1200jr')
        maskDisplay='disp(''PCI-DAS1200/JR\nComputerBoards\n';
        maskDescription=['PCI-DAS1200/JR',10,'ComputerBoards',10];
        boardType=3;
    elseif strcmp(maskType,'cbpcidio48h')
        maskDisplay='disp(''PCI-DIO48H\nComputerBoards\n';
        maskDescription=['PCI-DIO48H',10,'ComputerBoards',10];
        boardType=4;
    elseif strcmp(maskType,'cbpcidda0212')
        maskDisplay='disp(''PCI-DDA02/12\nComputerBoards\n';
        maskDescription=['PCI-DDA02/12',10,'ComputerBoards',10];
        boardType=5;
    elseif strcmp(maskType,'cbpcidda0412')
        maskDisplay='disp(''PCI-DDA04/12\nComputerBoards\n';
        maskDescription=['PCI-DDA04/12',10,'ComputerBoards',10];
        boardType=6;
    elseif strcmp(maskType,'cbpcidda0812')
        maskDisplay='disp(''PCI-DDA08/12\nComputerBoards\n';
        maskDescription=['PCI-DDA08/12',10,'ComputerBoards',10];
        boardType=7;
    elseif strcmp(maskType,'cbpcidio24h')
        maskDisplay='disp(''PCI-DIO24H\nComputerBoards\n';
        maskDescription=['PCI-DIO24H',10,'ComputerBoards',10];
        boardType=8;
    elseif strcmp(maskType,'cbpcidio96h')
        maskDisplay='disp(''PCI-DIO96H\nComputerBoards\n';
        maskDescription=['PCI-DIO96H',10,'ComputerBoards',10];
        boardType=9;
    elseif strcmp(maskType,'cbpcidio24')
        maskDisplay='disp(''PCI-DIO24\nComputerBoards\n';
        maskDescription=['PCI-DIO24',10,'ComputerBoards',10];
        boardType=10;
    elseif strcmp(maskType,'cbpcidas160212')
        maskDisplay='disp(''PCI-DAS1602/12\nComputerBoards\n';
        maskDescription=['PCI-DAS1602/12',10,'ComputerBoards',10];
        boardType=11;
    elseif strcmp(maskType,'nipci6503')
        maskDisplay='disp(''PCI-6503\nNational Instr.\n';
        maskDescription=['PCI-6503',10,'National Instruments',10];
        boardType=12;
    elseif strcmp(maskType,'nipcidio96')
        maskDisplay='disp(''PCI-DIO-96\nNational Instr.\n';
        maskDescription=['PCI-DIO-96',10,'National Instruments',10];
        boardType=13;
    elseif strcmp(maskType,'nipxi6508')
        maskDisplay='disp(''PXI-6508\nNational Instr.\n';
        maskDescription=['PXI-6508',10,'National Instruments',10];
        boardType=14;
    elseif strcmp(maskType,'nipci6025e8255')
        maskDisplay='disp(''PCI-6025E (8255)\nNational Instr.\n';
        maskDescription=['PCI-6025E (8255)',10,'National Instruments',10];
        boardType=15;       
    elseif strcmp(maskType,'cbpcidualac5')
        maskDisplay='disp(''PCI-DUAL-AC5\nComputerBoards\n';
        maskDescription=['PCI-DUAL-AC5',10,'ComputerBoards',10];
        boardType=16;
    elseif strcmp(maskType,'cbpcidda0216')
        maskDisplay='disp(''PCI-DDA02/16\nComputerBoards\n';
        maskDescription=['PCI-DDA02/16',10,'ComputerBoards',10];
        boardType=17;
    elseif strcmp(maskType,'cbpcidda0416')
        maskDisplay='disp(''PCI-DDA04/16\nComputerBoards\n';
        maskDescription=['PCI-DDA04/16',10,'ComputerBoards',10];
        boardType=18;
    elseif strcmp(maskType,'cbpcidda0816')
        maskDisplay='disp(''PCI-DDA08/16\nComputerBoards\n';
        maskDescription=['PCI-DDA08/16',10,'ComputerBoards',10];
        boardType=19;
    elseif strcmp(maskType,'cbpcimdda0616')
        maskDisplay='disp(''PCIM-DDA06/16\nComputerBoards\n';
        maskDescription=['PCIM-DDA06/16',10,'ComputerBoards',10];
        boardType=20;
    elseif strcmp(maskType,'cbpcimdas160216')
        maskDisplay='disp(''PCIM-DAS1602/16\nComputerBoards\n';
        maskDescription=['PCIM-DAS1602/16',10,'ComputerBoards',10];
        boardType=21;
    elseif strcmp(maskType,'cbpcidio96')
        maskDisplay='disp(''PCI-DIO96\nComputerBoards\n';
        maskDescription=['PCI-DIO96',10,'ComputerBoards',10];
        boardType=22;
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
        
        %%% check reset vector parameter
        if ~isa(reset, 'double')
            error('Reset vector parameter must be of class double');
        end
        if size(reset) == [1 1]
            reset = reset * ones(size(channels));
        elseif ~all(size(reset) == size(channels))
            error('Reset vector must be a scalar or the same length as the Channel vector');
        end
        reset = round(reset);
        if ~all(ismember(reset, [0 1]))
            error('Reset vector elements must be 0 or 1');
        end

        %%% check initValue vector parameter
        if ~isa(initValue, 'double')
            error('Initial value vector parameter must be of class double');
        end
        if size(initValue) == [1 1]
            initValue = initValue * ones(size(channels));
        elseif ~all(size(initValue) == size(channels))
            error('Initial value vector must be a scalar or the same size as the Channel vector');
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

end
