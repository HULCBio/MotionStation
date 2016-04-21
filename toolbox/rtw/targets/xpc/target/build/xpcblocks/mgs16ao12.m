function [maskdisplay, reset, ival] = mgs16ao12( phase, pcislot, channel, reset, ival )

% phase == 1 means this is called as an initfcn, only the first parameter,
% only 'phase', is defined.
% phase == 2 means this is called as a mask init function.  All three parameters
%  are defined.  The find_system calls used to do cross block checking can only
%  be used in phase 1.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/23 15:42:48 $
  
  if phase == 1
    %'Enter phase 1'
    % parameter pcislot is not defined in phase 1.  Get it directly from the mask.
    
    slot = evalin( 'caller', get_param( gcb, 'pcislot' ) );

    ADInitBlocks = checkblocks( 'PMC_16AO12-aout', slot );

    %'Exit phase 1'
  end % phase 1
  
  if phase == 2
    %'Enter phase 2'

    masktype = get_param( gcb, 'MaskType' );
    % the MaskType is in the form: PMC_16AO12-aout, find the part past the '-'

    maskdisplay = 'disp(''PMC-16AO-12\nGeneral Stds\nAnalog Output'');';

    channel = str2num( get_param( gcb, 'channel' ) );
    instart = 0;
    inport = '';
    lth = length(channel);
    if lth < 1 | lth > 12
      error('The number of output channels must be in the range 1..12');
    end
    test = zeros(1,12);
    for i = 1:length(channel)
      chan = channel(i);
      if test(chan)
        error(['Attempting to use output channel ',num2str(chan),' more than once.']);
      end
      if chan < 1 | chan > 12
        error('Output channels must be in the range 1..12');
      end
      test(chan) = 1;
      inport = [inport,'port_label(''input'',',num2str(i+instart),',''',num2str(chan),''');'];
    end    
    maskdisplay = [maskdisplay,inport];

% make sure that reset and ival have the same number of elements as channel,
% if not, then do scaler expansion.

    rlength = length(reset);
    ivlength = length(ival);
    if lth > 1
      if rlength == 1
        reset = reset * ones( 1, lth );
      end
      if ivlength == 1
        ival = ival * ones( 1, lth );
      end
    end
    
    rlength = length(reset);
    ivlength = length(ival);

    if lth ~= rlength
      error('Reset vector must have the same length as the channel vector, or length 1');
    end
    
    if lth ~= ivlength
      error('Initial value vector must have the same length as the channel vector, or length 1');
    end
    
    %'Exit phase 2'
  end


function blocks = checkblocks( bltype, slot )

  tmpblocks = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', bltype );
  blcount = 0;
  blocks = cell(0);
  for i = 1 : length(tmpblocks)
    thisslot = eval( get_param(tmpblocks{i}, 'pcislot') );
    if isequal( slot, thisslot )
      blcount = blcount + 1;
      blocks{blcount} = tmpblocks{i};
    end
  end
  if blcount > 1
    mytype = get_param( gcb, 'MaskType' );
    % Suppress error message if the current board is not this type.
    if isequal( mytype, bltype )
      error(['Found more than one ', bltype, 'block that uses the ADADIO board in slot ', num2str(slot) ]);
    end
  end
