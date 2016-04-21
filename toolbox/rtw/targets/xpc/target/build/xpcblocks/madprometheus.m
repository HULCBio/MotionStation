function [gain, offset, control, baseDec, maskDisplay, maskDescription] = madprometheus(phase, firstChannel, numChannels, range, mux, base, showStatus)
% madprometheus - Mask Initialization function for Diamond Systems Prometheus A/D blocks
% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.3.6.1 $  $Date: 2004/04/08 21:02:40 $

    deviceName  = 'Prometheus';
    vendorName  = 'Diamond';
    description = 'Analog Input';
    maskType    = 'adprometheus';
    resolution  = 16;
    maxChannels = 16;
    supRange    = [-10, -5, -2.5, -1.25, 10, 5, 2.5];
    supControl  = [0, 1, 2, 4, 1, 2, 4]; % G0 and G1 setting for analog gain register

    if phase ~= 2  % assume InitFcn unless phase 2
        blocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', maskType);
        if length(blocks) > 1
            error('Only one Diamond Systems Prometheus A/D block per physical board allowed in a model');
        end
        return
    end

    switch mux
        case 1 % 16 single-ended
            maxChannel = 16;
        case 2 % 8 double-ended
            maxChannel = 8;
        otherwise
            error('Bad mux parameter');
    end   

    %%% check firstChannel parameter
    if ~isa(firstChannel, 'double') || any(size(firstChannel) ~= [1 1]) || ~ismember(firstChannel, [1:maxChannel])
        error(['First channel parameter must be an integer between 1 and ' num2str(maxChannel) ' for current mux setting']);
    end
    
    max = maxChannel - firstChannel + 1;
    
    %%% check numChannels parameter
    if ~isa(numChannels, 'double') || any(size(numChannels) ~= [1 1]) || ~ismember(numChannels, [1:max])
        error(['Number of channels parameter must be an integer between 1 and ' num2str(max) ' for current mux and first channel settings']);
    end
    
    %%% check base parameter
    baseMsg = 'Base address parameter must be a hex address of the form ''0xddd''';
    if ~isa(base, 'char') || length(base) ~= 5 || any(base(1:2) ~= '0x')
        error(baseMsg);
    end
    try
        baseDec = hex2dec(base(3:end));
    catch
        error(baseMsg);
    end
    
    
    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
    
    for i = 1 : numChannels
        maskDisplay = sprintf('%s port_label(''output'', %i, ''%i'');', maskDisplay, i, firstChannel + i - 1);
    end  
    
    if (showStatus > 0)
      maskDisplay = [maskDisplay, 10, 'port_label(''output'',', num2str(numChannels+1), ',''E'');'];
    end
       
    maskDescription = [deviceName 10 vendorName 10 description];
    
    rangeval = supRange(range);
    control = supControl(range);
    resolution = 2^resolution;
    
    if rangeval < 0
        gain = -rangeval * 2 / resolution;
        offset = 0;
    else
        gain = rangeval / resolution;
        offset = -rangeval / 2;
    end
