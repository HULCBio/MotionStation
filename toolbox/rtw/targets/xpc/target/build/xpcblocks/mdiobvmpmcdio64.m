function [maskDisplay, maskDescription, config, initial, stopaction]= mdiobvmpmcdio64(phase, port, fmt, channels, stopaction, initial, pciSlot)

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/03/25 03:58:07 $

% The following command has to be executed at the Matlab command line
% with either the input or output block in focus in the library to
% set the callback.  This enables or disables the channel item in the
% mask depending on the value of the format.
% The output callback is set up as:
%   set_param( gcb, 'MaskCallbacks', {'maskvalues=get_param(gcb,''MaskValues'');fmt=maskvalues{1};if fmt(1)==''3'', set_param(gcb, ''MaskEnables'',{''on'', ''on'', ''on'', ''on'', ''on'', ''on'', ''on''}); else, set_param(gcb,''MaskEnables'', {''on'', ''off'', ''on'', ''on'', ''on'', ''on'', ''on''}); end','','','','','',''});
% The input callback is slightly different since two of the parameters are disabled all the time:
%   set_param( gcb, 'MaskCallbacks', {'maskvalues=get_param(gcb,''MaskValues'');fmt=maskvalues{1};if fmt(1)==''3'', set_param(gcb, ''MaskEnables'',{''on'', ''on'', ''off'', ''off'', ''on'', ''on'', ''on''}); else, set_param(gcb,''MaskEnables'', {''on'', ''off'', ''off'', ''off'', ''on'', ''on'', ''on''}); end','','','','','',''});
  
  if phase == 1
    
    % collect information accross blocks
    
    maskType=get_param(gcb, 'MaskType');
    idx = findstr( maskType, '-' );
    maskType= maskType(1:idx);
    inBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType', [maskType, 'di']);
    outBlocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType',[maskType, 'do']);
    
    blocks = [inBlocks; outBlocks];
    transition = length(inBlocks);
    
    % With this board, we allow multiple blocks to use the same port
    % for input, or multiple blocks using the same port for output.  We
    % must not allow a port to be used for both input and output.
    % There are 64 bits, where each group of 8 is identified as a port.
    % Each port is either input or output, not both.
    
    % The IO config setup is computed by all blocks.  All blocks will
    % write the config register on the board to select input versus output
    % for the ports.  Since the calculation is the same for all blocks,
    % it won't matter that we may write the config register multiple times.
    
    thisBlock = get_param( gcb, 'MaskValues' );
    thisSlot = eval( [thisBlock{7}, ';'] );
    thisFormat = thisBlock{1};
    
    % Check inputs and outputs for the current block against other
    % blocks that use the same board.  There are 2 ports with 32
    % channels on each.  First index is port, second is channel.
    inputs = zeros( 2, 32 );
    outputs = zeros( 2, 32 );
    
    maskValues= get_param(blocks,'MaskValues');
    for i=1:length(blocks)
      %disp(['block ', num2str(i)]);
      try
        pciSlot= eval([maskValues{i}{7},';']);
      catch
        error('PCI slot cannot be evaluated');
      end
      if pciSlot == thisSlot
        port = str2num( maskValues{i}{5} );
        fmt = maskValues{i}{1};
        
        if i > transition
          direction=2;   % == output
        else
          direction=1;   % == input
        end

        if strcmp( fmt, '32 One bit channels' )
          % check channels
          try
            channels = eval([maskValues{i}{2},';']);
          catch
            error('Channel vector cannot be evaluated');
          end
          for k = 1:length(channels)
            %disp(['k = ',num2str(k)]);
            if channels(k)>0 & channels(k) < 33
              switch direction
               case 1  % input
                if inputs( port, channels(k) ) == 1
                  % inefficient reuse
                  error(['Input channel ',num2str(channels(k)),' on port ', num2str(port), ' is accessed by more than one input block. This introduces unnecessary additional latency by the drivers.']);
                end
                if outputs( port, channels(k) ) == 1
                  % illegal, same channel is both input and output
                  error(['Input channel ',num2str(channels(k)),' on port ', num2str(port), ' is in use as an output channel in another block.']);
                end
                inputs( port, channels(k) ) = 1;
              
               case 2  % output
                if inputs( port, channels(k) ) == 1
                  % illegal, same channel is both input and output
                  error(['Output channel ',num2str(channels(k)),' on port ', num2str(port), ' is in use as an input channel in another block.']);
                end
                if outputs( port, channels(k) ) == 1
                  % inefficient reuse
                  error(['Output channel ',num2str(channels(k)),' on port ', num2str(port), ' is accessed by more than one output block. This introduces unnecessary additional latency by the drivers.']);
                end
                outputs( port, channels(k) ) = 1;
              end  % switch on direction
            end % if on legal channels numbers
          end % for on length of channels for the current block
        else % do stuff to check the single 32 bit port
          switch direction
           case 1  % input
            for chan = 1:32  % must check and mark all 32 'channels' on this port
              if inputs( port, chan ) == 1
                % inefficient reuse
                error(['Input port ', num2str(port), ' is accessed more than once.  This introduces unnecessary additional latency by the drivers.']);
              end
              if outputs( port, chan ) == 1
                % illegal, same channel is both input and output
                error(['Input channel ',num2str(channels(k)),' on port ', num2str(port), ' is in use as an output channel in another block.']);
              end
              inputs( port, chan ) = 1;
            end
           case 2  % output
            for chan = 1:32  % must check and mark all 32 'channels' on this port
              if inputs( port, chan ) == 1
                % illegal, same channel is both input and output
                error(['Input port ', num2str(port), ' is accessed more than once.  This introduces unnecessary additional latency by the drivers.']);
              end
              if outputs( port, chan ) == 1
                % inefficient reuse
                error(['Input channel ',num2str(channels(k)),' on port ', num2str(port), ' is in use as an output channel in another block.']);
              end
              outputs( port, chan ) = 1;
            end % of for on channel number
          end % of switch on direction
        end % of port type checks
      end  % end of if on same slot
    end  % end of the for loop on blocks in model

    % Check inputs() and outputs() to make sure we don't have both
    % input and output on the same port.
    input = 0;   % 4 bits per port
    output = 0;
    for port = 1:2
      for channel = 1:32
        if inputs( port, channel ) == 1
          input = bitor( input, bitshift(15 , 4 * (port - 1) ) );
        end
        if outputs( port, channel ) == 1
          output = bitor( output, bitshift(15, 4 * (port - 1) ) );
        end
      end
    end
    if ~isequal( bitand( input, output ), 0 )
      error('Can''t use the same port for both input and output.');
    end
    
    % output is exactly the value we want to use in the direction
    % configuration register on the board.  Save it for phase 2.
    set_param( gcb, 'UserData', output );
    
  else % phase == 2, mask init

    maskType=get_param(gcb, 'MaskType');
    idx = findstr( maskType, '-' );
    directionStr = maskType(idx+1:idx+2);
    if strcmp(directionStr, 'di')
        direction = 1;
    elseif strcmp(directionStr, 'do')
        direction = 2;
    end    
    maskType = maskType(1:idx);
    
    maskDisplay = 'disp(''PMCDIO64\nBVM\n';
    maskDescription = ['PMCDIO64',10,'BVM',10];
    boardType = 1;
    
    if fmt == 2   % if this block is set to 32 one bit channel
                  % check channel vector
    
      if ~isa(channels,'double')
        error('Channel vector must be of class ''double''');
      end
      if size(channels,1) > 1
        error('Channel vector must be a row vector');
      end
      channels = round(channels);
      occupied = zeros(1,32);
      for i = 1:length(channels)
        channel = channels(i);
        if channel < 1 | channel > 32
          error('Channel vector elements must be in the range 1..32');
        end
        if occupied(channel )== 1
          error('Don''t access a channel more than once because this will introduce unnecessary additional latency by the driver.');
        end
        occupied(channel) = 1;
      end  % end of for on channels
    end  % end of if 32 separate channels
    
    if direction == 1
      maskDisplay = [maskDisplay,'Digital Input'');'];
      if fmt == 1
        maskDisplay = [maskDisplay,'port_label(''output'', 1 ,''1'');'];
      else
        for i=1:length(channels)
          maskDisplay = [maskDisplay,'port_label(''output'',',num2str(i),',''',num2str(channels(i)),''');'];
        end       
      end
      maskDescription = [maskDescription, 'Digital Input'];
    elseif direction == 2
      maskDisplay = [maskDisplay,'Digital Output'');'];
      if fmt == 1
        maskDisplay = [maskDisplay,'port_label(''input'', 1 ,''1'');'];
      else
        for i=1:length(channels)
          maskDisplay = [maskDisplay,'port_label(''input'',',num2str(i),',''',num2str(channels(i)),''');'];
        end
      end
      maskDescription = [maskDescription, 'Digital Output'];
    end

    % 8 bit mask of IO assignments for the 8 ports.
    config = get_param( gcb, 'UserData' );
    
    % Deal with the initial value.  If format is a single 32 bit quantity,
    % then there is only one value.  If the user provided more than one value,
    % then it is an error.
    % If format is 32 one bit channels, then if initial is a single element
    % array, it needs to be scaler expanded.  Else, the user must provide
    % the same number of entries as are in channel.
    % Once in the proper vector format, construct a single 32 bit integer
    % to used in setting the hardware register.
    % initial comes into this routine as a string literal and must be converted
    if direction == 2
      if fmt == 1  % Single 32 bit port
        index = strfind( initial, '[' );
        if length(index) > 0
          findex = strfind( initial, ']' );
          itest = sscanf( initial( index+1:findex-1), '0x%x' );
          itest1 = sscanf( initial( index+1:findex-1), '%d' );
        else
          itest = sscanf( initial, '0x%x' );
          itest1 = sscanf( initial, '%d' );
        end
        if length(itest) == 1
          ivalue = itest;
        else
          if length(itest1) == 1
            ivalue = itest1;
          else
            error('Initial value is not a legal decimal or hexidecimal constant.');
          end
        end
        if length(stopaction) ~= 1
          error('When configured as a single 32 bit port, the ''Reset Action vector'' must have a single element.');
        end
        if stopaction == 1
          saction = 65535;  % Reset all 32 bits
        else
          saction = 0;       % Reset none of the bits
        end
        %disp(['ivalue = ',num2str(ivalue)]);
        
      else  % 32 one bit vectors, assigned by channels[]
        ivec = str2num( initial );
        if length(ivec) == 1 & length(channels) > 1
          ivec = ivec * ones( 1, length(channels) );
        end
        if length(ivec) ~= length(channels)
          error('The initialization vector must be either a vector with a single element, or a vector with the same number of elements as in the channel vector.');
        end
        if length(stopaction) == 1 & length(channels) > 1
          stopaction = stopaction * ones( 1, length(channels) );
        end
        if length(channels) ~= length(stopaction)
          error('The ''Reset Action vector'' must be either a vector with a single element, or a vector with the same number of elements as in the channel vector.');
        end
        ivalue = 0;
        for i = 1:length(ivec)
          if ivec(i) == 1
            ivalue = bitor( ivalue, bitshift(1, i-1));
          end
        end
        saction = 0;
        for i = 1:length(stopaction)
          if stopaction(i) == 1
            saction = bitor( saction, bitshift(1, i-1));
          end
        end
      end
      initial = ivalue;
      stopaction = saction;
    end
  end
