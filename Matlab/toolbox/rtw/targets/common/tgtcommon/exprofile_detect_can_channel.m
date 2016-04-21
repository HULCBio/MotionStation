function channel = exprofile_detect_can_channel
% EXPROFILE_DETECT_CAN_CHANNEL automatically detects a CAN channel CHANNEL =
  
%    CHANNEL = EXPROFILE_DETECT_CAN_CHANNEL automatically detects a CAN channel
%    for use by execution profiling. If successful, a CHANNEL number is returned
%    that corresponds to either Vector Informatik CAN hardware, either CanAc2Pci
%    1 or CanCardX 1.
  
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/19 01:21:50 $
  
% Channel Param = 1 (Virtual 1)
% Channel Param = 2 (Virtual 2)
% Channel Param = 3 (CanAc2Pci 1)
% Channel Param = 4 (CanAc2Pci 2)
% Channel Param = 5 (CanAc2 1)
% Channel Param = 6 (CanAc2 2)
% Channel Param = 7 (CanCardX 1)
% Channel Param = 8 (CanCardX 2)
% Channel Param = 9 (CanPari)
  channels_to_try = [7 3];
  
  for i=1:length(channels_to_try)
    channel = channels_to_try(i);
    disp(' ')
    disp(['Testing channel ' num2str(channel) ':'])
    err = vector_can_interface('validatechannel', channel);
    if err==0
      [err, channelName] = vector_can_interface('getchannelname', channel);
      disp(['CAN channel ' num2str(channel) ' (' channelName  ') OK.'])
      break;
    else 
      channel = [];
    end
  end
  
  if isempty(channel)
    % display available channels
    err = vector_can_interface('listchannels');
    
    disp('Attempted to use one of channels')
    disp(channels_to_try)
    
    % error out
    error(['None of the channels that were checked could be validated. It may be that '...
           'no channel is available. You must check that your CAN hardware is '...
           'correctly installed']);
  end
    