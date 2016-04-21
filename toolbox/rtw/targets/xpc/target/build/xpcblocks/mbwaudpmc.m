function [maskdisplay, framesize, samplerate, sampletime ] = mbwaudpmc( phase, channels, framesize, samplerate, sampletime, slot )

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:02:45 $
  
  if phase == 1  % called as InitFcn
    %disp('Called as InitFcn');

    masktype = get_param( gcb, 'MaskType' );
    slot = get_param( gcb, 'slot' );
    idx = findstr( masktype, '-' );
    aintype = [masktype( 1:idx ), 'ain' ];
    myainblocks = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', aintype, 'slot', slot );
    if length(myainblocks) > 1
      error('Only one BittWare Audio-PMC+ input block allowed in a model for any board.');
    end
    
    aouttype = [masktype( 1:idx ), 'aout' ];
    myaoutblocks = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', aintype, 'slot', slot );
    if length(myainblocks) > 1
      error('Only one BittWare Audio-PMC+ output block allowed in a model for any board.');
    end
    
    % Gather information from all three types and construct the init
    % values.  Only one of them should do the hardware init.
    
  end
  
  if phase == 2  % called as mask init function for analog input
    %disp('Called as mask init function');
    masktype = get_param( gcb, 'MaskType' );
    idx = findstr( masktype, '-' );
    bdtype = masktype( idx+1:end );
    maskdisplay = 'disp(''Audio-PMC\nBittWare\n';
    
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
            error('Channel vector elements must be in the range 1..8.');
        end
        if occupied(channel)==1
            error('Multiple references to the same channel are not allowed.');
        end
        occupied(channel)=1;
    end

    if strcmp( bdtype, 'ain' )
      maskdisplay=[maskdisplay,'Analog Input'');'];
      outport = '';
      for i = 1:length(channels)
        outport = [outport, ' port_label(''output'',',num2str(i),',''', num2str(channels(i)),''');'];
      end
      maskdisplay = [maskdisplay, outport ];
    
    end
    
    if strcmp( bdtype, 'aout' )
      maskdisplay=[maskdisplay,'Analog Output'');'];
      inport = '';
      for i = 1:length(channels)
        inport = [inport, ' port_label(''input'',',num2str(i),',''',num2str(channels(i)),''');'];
      end
      maskdisplay = [maskdisplay, inport ];
    end
    
    if( samplerate < 0 && samplerate ~= -1 )
      rate = -samplerate;
    else
      rate = samplerate;
    end
    
    countderived = 0;
    if framesize == -1
      countderived = countderived + 1;
    end
    if samplerate == -1
      countderived = countderived + 1;
    end
    if sampletime == -1
      countderived = countderived + 1;
    end

    if countderived > 1
      error('At most, one of Frame Size, Sample Rate or Sample Time can be -1, the other two must be specified.');
    end
    if countderived == 0
      error('You must leave at least one of Frame Size, Sample Rate or Sample Time set to -1.  The other 2 must be specified.');
    end
    
    if framesize == -1
      framesize = (rate * sampletime);
    end
    
    if samplerate == -1
      samplerate = (framesize / sampletime );
    end
    
    if sampletime == -1
      sampletime = (framesize / rate );
    end
    
    if( framesize > 256 )
        error(['The maximum allowable frame size is 256 samples perframe.  You are trying to use ', num2str(framesize),' samples per frame.']);
    end
    
    % update the xpc_rtwmakecfg_data parameter of the current model to signal
    % that the audioPMC lib will be needed for the build

    try
        data = get_param(bdroot, 'xpc_rtwmakecfg_data');
    catch
        data = '';
        add_param(bdroot, 'xpc_rtwmakecfg_data', data);
    end

    if isempty( strfind(data, '_xpcaudpmc_') )
        set_param(bdroot, 'xpc_rtwmakecfg_data', [data '_xpcaudpmc_']);
    end

%    disp( framesize );
%    disp( samplerate );
%    disp( sampletime );
    
  end  % end phase 2 code
