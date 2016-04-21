function profile_data = exprofile_getdata_serial(port, bitrate, first_data_timeout)
%EXPROFILE_GETDATA_SERIAL retrieves execution profiling data via SERIAL
%   EXPROFILE_GETDATA_SERIAL(PORT, BITRATE, FIRST_DATA_TIMEOUT) requests
%   execution profiling data by sending a message over serial and then uploads the
%   returned data. PORT is a string containing the name of the serial port
%   to receive data over: for example, 'COM1'. BITRATE is the serial bit
%   rate in bits per second. FIRST_DATA_TIMEOUT is the length of time, in
%   seconds, to wait for data to be returned from the target processor.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
  
  startbyte = 201;

  ser = serial(port, 'BaudRate', bitrate);
  try
      fopen(ser);
  catch
      localBailout(ser, sprintf(['Failed to validate port ' port '. It may be '...
          'that this serial port is not available or locked by another '...
          'program. Error returned:\n' lasterr]));
      % lasterr contains info on which serial ports are available
  end
  
  % Transmit a start command byte
  try
      fwrite(ser, startbyte, 'uint8');
  catch
      localBailout(ser, sprintf(['Failed to transmit start byte over port ' ...
          port '. Error returned:\n' lasterr]));
  end
  
  disp(' ')
  disp(['Sent start byte with value ' num2str(startbyte) ' via ' port '\n'...
        'to request upload of execution profiling data.']);
  disp(' ')
  disp(['Waiting to receive execution profiling data ...'])

  % Collect the data in groups of 8 bytes
  try
      [data, count, msg] = fread(ser, 8, 'uint8');
      data = data';
  catch
      localBailout(ser, sprintf(['Error while receiving start of execution ' ...
          'profiling data:\n' lasterr]));
  end  
  if count==0
    msg = localIncompleteDataMsg;
    localBailout(ser, msg);
  end
  
  disp(' ')
  disp('Received start of execution profiling data.')
  disp(' ')
  disp('Uploading data, please wait ...')
  disp(' ')

  % Note the start time
  tic
  
  finished = 0;
  timeout = first_data_timeout;
  first_data_received = 0;
  profile_data = [];  
  
  while toc < timeout
    
      timeout = toc + 4;
      
      profile_data = [profile_data; data];
      
      try
          [data, count, msg] = fread(ser, 8, 'uint8');
          data = data';
      catch
          localBailout(ser, sprintf(['Error while receiving execution ' ...
              'profiling data:\n' lasterr]));
      end

  end
  
  try
      fclose(ser);
  catch
      localBailout(ser, ['Error closing serial port ' port ': ' lasterr]);
  end
  
  % Return the data as a column vector
  profile_data = profile_data';
  profile_data = profile_data(:);
  
  % --------------------------------------------------------------------

function msg = localIncompleteDataMsg
  msg = sprintf([...
      'Timeout occurred. No execution profiling data was received from\n'...
      'the target. You should check the following:\n\n'...
      '   1. The serial port on the target is connected to the serial\n '...
      '      port on the host machine.\n'...
      '   2. The application on the target is running.\n'...
      '   3. The target and host serial ports must both be configured\n'...
      '      for the same bit rate (N.B. default for host-side is 57600\n'...
      '      bits per second).\n'...
      '   4. The application on the target is properly configured to\n'...
      '      provide execution profiling data.\n'...
      ' \n'...
      'If you are performing execution profiling over a long period of time '...
      'it may be necessary to increase the timeout value.']);
  
  
  
  function localBailout(serialport, message)
  try
      fclose(serialport);
  catch
      % Already bailing out, so no further action required
  end
  error(message);