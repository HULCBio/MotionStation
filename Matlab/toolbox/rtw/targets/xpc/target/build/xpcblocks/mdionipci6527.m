function [filter, reset, initValue] = mdionipci6527( phase, channel, port, sample, slot, direct, filter, filterinterval, reset, initValue )

% MPCI6527 - InitFcn and Mask Initialization for the National Instruments 
% PCI-6527 and PXI-6527 digital I/O-boards
% The reset and initValue parameters are used only for digital output  

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.4.2.1 $ $Date: 2004/03/02 03:04:49 $

  type = get_param(gcb, 'MaskType' );
  pcipxi = type(5:7);
  switch type(2)
   case 'i' % input
    direct = 1;
   case 'o' % output
    direct = 2;
  end
  
  if phase == 1
    % Sharing Rules: Each Board Has 3 Input Ports With 8 channels each
    % and 3 output ports with 8 channels each.  Each port can be used
    % by at most one block.  In each block, each channel can be used
    % at most once.  Boards in different slots do not interfere with
    % each other.
    
    block = find_system(bdroot, ...
                        'FollowLinks', 'on', ...
                        'LookUnderMasks', 'all', ...
                        'MaskType', type );
    port = get_param( gcb, 'port' );
    slot = evalin( 'caller', get_param( gcb, 'slot' ) );
    if direct == 1  % input, get filter
      filter = get_param( gcb, 'filter' );
      filterinterval = str2num(get_param( gcb, 'filtertime' ));
    end
    if length(block) > 1
      mask = get_param(block, 'MaskValues');

      % Pack the bus and slot for all the blocks into info.slot(i)
      % for block number i.
      for i = 1:length(block)
        tmp = evalin( 'caller', get_param(block{i}, 'slot' ) );
        if length(tmp) == 2   % if tmp is a two component vector, it is
                              % [bus, slot]
          info.slot(i) = tmp(1) * 256 + tmp(2);
        else                  % if tmp has only one component, it is [slot]
                              % on bus 0
          info.slot(i) = tmp(1);
        end
      end

      % Pack the bus and slot in variable slot into packedslot in the
      % same format as info.slot(i).
      if length(slot) == 2
        packedslot = slot(1) * 256 + slot(2);
      else
        packedslot = slot(1);
      end
      
      for i = 1:length(block)
        if ~strcmp(gcb, block{i}) & strcmp( port, mask{i}{2}) & packedslot == info.slot(i)
          if direct == 1
            error(['block ' block{i} ' is also using digital input port ' port ]);
          else
            error(['block ' block{i} ' is also using digital output port ' port ]);
          end
        end

        if direct == 1
          % Check the filter interval for input blocks.  Any port with filtering
          % enabled on any channel must specify the same filter interval or there is
          % an error.
          % filter = vector, filterinterval = duration, seconds.
          if packedslot == info.slot(i) & ~strcmp( gcb, block{i} ) & any(filter)
            if any( str2num( mask{i}{3} ) ) > 0 & filterinterval ~= str2num( mask{i}{4} )
              error('All digital input blocks that use the same board must use the same filter interval.');
            end
          end
        end
      end
    end
  end
  
  if phase == 2  
    switch( pcipxi )
     case 'pci'
      maskdisplay='disp(''PCI-6527\nNational Instr\n';
     case 'pxi'
      maskdisplay='disp(''PXI-6527\nNational Instr\n';
    end
  
    if direct == 1
      maskdisplay=[maskdisplay,'Digital Input'');'];
      for i=1:length(channel)
        maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
      end
    elseif direct == 2
      maskdisplay=[maskdisplay,'Digital Output'');'];
      for i=1:length(channel)
        maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
      end
    end
    set_param(gcb,'MaskDisplay',maskdisplay);
  
    % Since more than one block using the same port has already been eliminated,
    % we just have to check the channel vector for this block for dups.
    test = zeros(1,8);
    for i = 1:length(channel)
      chan = channel(i);
      if chan < 1 | chan > 8
        error('channel elements have to be in the range: 1..8');
      end
      if test(chan)
        error(['channel ',num2str(chan),' already in use']);
      end
      test(chan) = 1;
    end

    % Perform scaler expansion on filter if there is a single element in the vector.
    if length(filter) == 1
      filter = filter * ones( 1, length(channel) );
    end

    % If filter wasn't length 1 and also not the same length as channel, it is an error.
    if length(filter) ~= length(channel)
      error('filter must be either length 1 or the same length as channel');
    end
  
    if direct == 2 % if output, check reset and initValue parameters
      if ~isa(reset, 'double')
        error('Reset vector parameter must be of class double');
      end
      if size(reset) == [1 1]
        reset = reset * ones(size(channel));
      elseif ~all(size(reset) == size(channel))
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
        initValue = initValue * ones(size(channel));
      elseif ~all(size(initValue) == size(channel))
        error('Initial value must be a scalar or have the same number of elements as the Channel vector');
      end
      initValue = round(initValue);
      if ~all(ismember(initValue, [0 1]))
        error('Initial value vector elements must be 0 or 1');
      end
    end
  end
