function bluetooth_cb
%BLUETOOTH_CB Sets up the Model Mask Parameters in the 
% Bluetooth Voice Transmission demo (bluetooth_voice.mdl)
% and saves it to the workspace

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $  $Date: 2002/04/11 02:29:37 $

% Retrieves user information and assigns packet type
h=get_param('bluetooth_voice/Model Parameters','MaskValues');
if(h{1,1}=='HV1')
    set_param('bluetooth_voice/Model Parameters','MaskVisibilities',{'on','off','off'});
    HV_Type=1;
    assignin('base','HV_Type',1);
    assignin('base','Slot_Pair',1);
elseif(h{1,1}=='HV2')
    HV_Type=2;
    assignin('base','HV_Type',2);
    set_param('bluetooth_voice/Model Parameters','MaskVisibilities',{'on','on','off'});
    if(h{2,1}== '1&2')
        Slot_Pair=1;
        assignin('base','Slot_Pair',1);
    else
        Slot_Pair=2;
        assignin('base','Slot_Pair',2);
    end
    
else
    set_param('bluetooth_voice/Model Parameters','MaskVisibilities',{'on','off','on'});
    HV_Type=3;
    assignin('base','HV_Type',3)
    if(h{3,1}=='1&2')
        Slot_Pair=1;
        assignin('base','Slot_Pair',1);
    elseif(h{3,1}=='3&4')
        Slot_Pair=2;
        assignin('base','Slot_Pair',2);
    else
        Slot_Pair=3;
        assignin('base','Slot_Pair',3);
    end     
end

% Define Slot_Ts and other variables depending on packet type
Slot_Ts=(1/1600);
assignin('base','Slot_Ts', (1/1600));
switch HV_Type
    case 1
        assignin('base','Tx_Ts',Slot_Ts*2);
        assignin('base','Num_Slots_Rate',2);
        assignin('base','Num_Payload_Bits',80);
        assignin('base','Slot_Enable_Phase',0); % Slot Pair
    case 2
        assignin('base','Tx_Ts',Slot_Ts*4);
        assignin('base','Num_Slots_Rate',4);
        assignin('base','Num_Payload_Bits',160);
        if Slot_Pair == 3
            error('Slot 5&6 cannot be used as initial slot for HV2');
        end;
        assignin('base','Slot_Enable_Phase',Slot_Pair*2-2); % Slot Pair
    case 3
        assignin('base','Tx_Ts',Slot_Ts*6);
        assignin('base','Num_Slots_Rate',6);
        assignin('base','Num_Payload_Bits',240);
        assignin('base','Slot_Enable_Phase',Slot_Pair*2-2); % Slot Pair
end







