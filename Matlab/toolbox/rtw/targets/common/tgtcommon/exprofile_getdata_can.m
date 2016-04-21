function profile_data = exprofile_getdata_can(channel, bitrate, first_data_timeout)
%EXPROFILE_GETDATA_CAN retrieves execution profiling data via CAN
%   EXPROFILE_GETDATA_CAN(CHANNEL, BITRATE, FIRST_DATA_TIMEOUT) requests
%   execution profiling data by sending a message over CAN and then uploads the
%   returned data. CHANNEL is a number that identifies your installed CAN
%   hardware. BITRATE is the CAN bit rate in bits per second. FIRST_DATA_TIMEOUT
%   is the length of time, in seconds, to wait for data to be returned from the
%   target processor.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
  
% Hard-coded CAN message identifiers
  command_id = hex2dec('1FFFFF00');
  command_xtd = 1;
  data_id_std = [];
  data_id_xtd = hex2dec('1FFFFF01');
  
  % Check that the channel exists
  [err] = vector_can_interface('validatechannel', channel);
  if err
    % display available channels
    err = vector_can_interface('listchannels');
    
    % error out
    error(['Failed to validate channel ' num2str(channel) '. It may be that '...
           'this channel is not available. You must use a channel number from the '...
           'the list above that is available on your system.']);
  end
  
  % Find the channel name
  [errorstatus, channelName] = vector_can_interface('getchannelname', channel);
  
  % Configure the bit timing for this channel
  i_set_bit_timing(channel,bitrate);
  
  % Create a master port for this channel to initialize it and allow message transmission
  err = vector_can_interface('createmasterport', channel,'exprofile_master');
  
  % Create a read port for data messages
  err = vector_can_interface('createreadport','exprofile_master',...
                             data_id_std, data_id_xtd, 'data_reader');
  
  % Transmit a start command message
  command_data = 1;
  err = vector_can_interface('transmit', 'exprofile_master', ...
                                       command_id, command_xtd, command_data);
  if err
    error(['Failed to transmit start command message over CAN channel ' channelName '.']);
  else
    disp(' ')
    disp(['Sent CAN message with identifier 0x' dec2hex(command_id) ' to request '...
         'upload of execution profiling data.']);
    disp(' ')
    disp(['Waiting to receive CAN message, identifier 0x' ...
          dec2hex(data_id_xtd) dec2hex(data_id_std) ', containing execution profiling '...
          'data ...'])
  end
  
  % Collect the data
  [err, qstatus, id, xtd, data, timestamp] = ...
      vector_can_interface('receive', 'data_reader');
  if err
    error('Error receiving CAN messsage.');
  end
  
  % Note the start time
  tic
  
  finished = 0;
  timeout = first_data_timeout;
  first_data_received = 0;
  profile_data = [];
  
  while toc < timeout
    
    if ( xtd==1 & id==data_id_xtd ) | (xtd==0 & id==data_id_std)
      if first_data_received == 0
        first_data_received = 1;
        disp(' ')
        disp('Received first CAN message with execution profiling data.')
        disp(' ')
        disp('Uploading data, please wait ...')
        disp(' ')
      end
      timeout = toc + 4;
      profile_data = [profile_data; data];
    end
    
    [err, qstatus, id, xtd, data, timestamp] = ...
        vector_can_interface('receive', 'data_reader');
    if err
      error('Error receiving CAN messsage.');
    end        
    
  end
  
  % Close the master port
  err = vector_can_interface('shutdownport', 'exprofile_master');
  
  % Close the read port
  err = vector_can_interface('shutdownport', 'data_reader');
    
  if isempty(profile_data)
    disp(sprintf([...
        'Timeout occurred. No execution profiling data was received from '...
        'the target. You should check the following:\n\n'...
        '   1. The CAN port on the target is connected to the CAN port on the '...
        'host machine.\n'...
          '   2. The application on the target is running.\n'...
        '   3. The application on the target is properly configured to '...
        'provide execution profiling data.\n'...
        ' \n'...
        'If you are performing execution profiling over a long period of time '...
        'it may be necessary to increase the timeout value.']));
  end
  
  % Return the data as a column vector
  profile_data = profile_data';
  profile_data = profile_data(:);
  
  
  
function i_set_bit_timing(channel, bitrate)  
% Define possible bit timing parameters
% 
% column 1 - bit rate in bits per second
% column 2 - bit rate prescaler
% column 3 - synchronization jump width
% column 4 - time segment 1, tseg1
% column 5 - time segment 2, tseg2
% column 6 - sample mode: 1 or 3 samples per bit [0 or 1]
  br = [
      1000000 1  1  4 3 0
      500000  1  1  8 7 0
      100000  4  4 12 7 1
      10000   32 4 16 8 1
      ];
 
  i = find(br(:,1) == bitrate);
  if isempty(i)
    disp(' ')
    disp('Supported bit rates are:')
    disp(br(:,1))
    disp(' ')
    error(['A bit rate of ' num2str(bitrate) ' is not supported. ' ...
           'You must choose a supported bit rate.']);
  end
  
  err = vector_can_interface('setbittiming', br(i,2), br(i,3), br(i,4), br(i,5), br(i,6),...
                             channel);
  

 