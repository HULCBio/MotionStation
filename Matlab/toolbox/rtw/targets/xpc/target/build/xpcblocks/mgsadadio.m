function [maskdisplay, bcrinit, init, cal, dachans, dareset, daival, ...
          dochans, doreset, doival ]= mgsadadio(phase,pcislot)

% phase == 1 means this is called as an initfcn, only the first parameter, 'phase', is defined.
% phase == 2 means this is called as a mask init function.  All three parameters
%  are defined.  The find_system calls used to do cross block checking can only
%  be used in phase 1.  The value of bcrinit determined during phase 1 is saved
%  as UserData in the block and recalled during mask init processing.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/08 21:03:03 $
  
  if phase == 1
    %disp('Enter phase 1');
    % parameter pcislot is not defined in phase 1.  Get it directly from the mask.
    
    slot = evalin( 'caller', get_param( gcb, 'pcislot' ) );

    ADStartBlocks = checkblocks( 'PMC_ADADIO-adstart', slot );
    ADReadBlocks = checkblocks( 'PMC_ADADIO-adread', slot );
    DAWriteBlocks = checkblocks( 'PMC_ADADIO-dawrite', slot );
    DAUpdateBlocks = checkblocks( 'PMC_ADADIO-daupdate', slot );
    DINBlocks = checkblocks( 'PMC_ADADIO-din', slot );
    DOUTBlocks = checkblocks( 'PMC_ADADIO-dout', slot );

%    '***************************************************'
%    ADStartBlocks
%    ADReadBlocks
%    DAWriteBlocks
%    DAUpdateBlocks

    bcrinittemp = hex2dec('028C0781');
    autocal = 0;
    
    % get 
    %    number of A/D channels to activate
    %    coupling
    %    autocal setting
    if isempty(ADReadBlocks)
      nChannels=1;
      coupling=1;
    else
      nchcell = get_param( ADReadBlocks, 'nchannels' );
      nChannels = str2num( nchcell{1} );
      if strcmp( get_param( ADReadBlocks, 'coupling' ), 'Single-ended' )
        coupling=1;
      else
        coupling=3;
      end
      if strcmp( get_param( ADReadBlocks, 'autocal' ), 'on' )
        autocal = autocal + 1;
      end
    end
    
    if isempty(DAWriteBlocks)
      dareset = 0;
      daival = 0;
      dachans = 0;
    else
      acal = get_param( DAWriteBlocks, 'autocal' );
      if strcmp( acal, 'on' )
        autocal = autocal + 1;
      end
      temp = get_param( DAWriteBlocks, 'reset' );
      dareset = str2num(temp{1});
      temp = get_param( DAWriteBlocks, 'ival' );
      daival  = str2num(temp{1});
      temp = get_param( DAWriteBlocks, 'channel' );
      dachans = str2num(temp{1});
      darange = get_param( DAWriteBlocks, 'range' );
      switch darange{1}
       case ('+-10V')
        daival = fix(daival * 32768.0/10.0);
       case ('+-5V')
        daival = fix(daival * 32768.0/5.0);
       case ('+-2.5V')
        daival = fix(daival * 32768.0/2.5);
      end
    end
    bcrinittemp = bitor( bcrinittemp, bitshift( nChannels - 1, 15 ));
    bcrinittemp = bitor( bcrinittemp, coupling );
   
    masktype = get_param( gcb, 'MaskType' );
    % the MaskType is in the form: PMC_ADADIO-adread, find the part past the '-'
    idx = findstr( masktype, '-' );
    type = masktype( idx+1:end );

    if strcmp('din', type ) || strcmp('dout', type )
      if ~isempty(DINBlocks) && ~isempty(DOUTBlocks)
        error(['Digital input and digital output cannot be used at ' ...
               'the same time on the same ADADIO board.']);
      end
    end
    
    % Choose the block that does the initialization
    if ~isempty(ADStartBlocks)
      initblock = 1;
    elseif ~isempty(ADReadBlocks)
      initblock = 2;
    elseif ~isempty(DAWriteBlocks)
      initblock = 3;
    elseif ~isempty(DAUpdateBlocks)
      initblock = 4;
    elseif ~isempty(DINBlocks)
      initblock = 5;
    elseif ~isempty(DOUTBlocks)
      initblock = 6;
    end
     
    % Save variables for phase 2.
    temp = {bcrinittemp, initblock, autocal, dachans, dareset, daival };
    set_param( gcb, 'UserData', temp );
    %disp('Exit phase 1');
  end % phase 1
  
  if phase == 2
    reset = 0;
    ival = 0;
    %disp('Enter phase 2');
    %['phase = ', num2str(phase), ', pcislot = ', num2str(pcislot), ']
    masktype = get_param( gcb, 'MaskType' );
    % the MaskType is in the form: PMC_ADADIO-adread, find the part past the '-'
    idx = findstr( masktype, '-' );
    type = masktype( idx+1:end );
    blocktype = 0;
    switch type
     case 'adstart'
      blocktype = 1;
     case 'adread'
      blocktype = 2;
     case 'dawrite'
      blocktype = 3;
     case 'daupdate'
      blocktype = 4;
     case 'din'
      blocktype = 5;
     case 'dout'
      blocktype = 6;
    end

    t1 = get_param( gcb, 'UserData' );
    if ~isempty(t1)
      bcrinit = t1{1};
      initblock = t1{2};
      cal = t1{3};
      dachans = t1{4};
      dareset = t1{5};
      daival = t1{6};
    else
      bcrinit = 0;
      initblock = 0;
      cal = 0;
      dareset = 0;
      daival = 0;
      dachans = 0;
    end

    % define for non DO block, all need them, only DO block actually uses them.
    dochans = 0;
    doreset = 0;
    doival = 0;
    
    in_enable = get_param( gcb, 'in_enable');
    out_enable = get_param( gcb, 'out_enable');
    
    % Prepare the DA reset information here since all blocks
    % need this information.  Only the one marked as the init
    % block actually uses it.  Mainly perform scaler expansion.
    ldachans = length(dachans);
    ldareset = length(dareset);
    ldaival = length(daival);
    if ldareset ~= ldachans
      if ldareset == 1
        dareset = dareset * ones(1,ldachans);
      else
        if blocktype == 3  % if this is the DA write block
          error(['The length of the D/A reset vector must be either the ' ...
                 'same length as the channel vector or have length 1.']);
        end
      end
    end
    if ldaival ~= ldachans
      if ldaival == 1
        daival = daival * ones(1,ldachans);
      else
        if blocktype == 3  % if this is the DA write block
          error(['The length of the D/A initial value vector must be ' ...
                 'either the same length as the channel vector or have ' ...
                 'length 1.']);
        end
      end
    end

    % Check that the values are in bounds of [-32768, 32767]
    upbnd  =  32767 * ones(1, length(daival));
    lowbnd = -32768 * ones(1, length(daival));
    daival = max( daival, lowbnd );
    daival = min( daival, upbnd );

    maskdisplay = 'disp(''PMC-ADADIO\nGeneral Stds\n';
    %blocktype
    if blocktype == 1  % ad start block
      maskdisplay = [maskdisplay,'AD Start'');'];
      if strcmp( in_enable, 'on' )
        inport = 'port_label(''input'',1,''E'');';
        maskdisplay = [maskdisplay, inport];
      end
      if strcmp( out_enable, 'on' )
        outport = 'port_label(''output'',1,''E'');';
        maskdisplay = [maskdisplay, outport];
      end
    end

    if blocktype == 2  % ad read block
      maskdisplay = [maskdisplay,'AD Read'');'];
      nchannels = str2num( get_param( gcb, 'nchannels' ) );
      if nchannels < 1 | nchannels > 8
        error('The number of input channels must be between 1 and 8.');
      end
      if strcmp( in_enable, 'on' )
        inport = 'port_label(''input'',1,''E'');';
        maskdisplay = [maskdisplay,inport];
      end
      outstart = 0;
      outport = '';
      if strcmp( out_enable, 'on' )
        outport = 'port_label(''output'',1,''E'');';
        outstart = 1;
      end
      for i = 1:nchannels
        outport = [outport,'port_label(''output'',',num2str(i+outstart),',''',num2str(i),''');'];
      end    
      maskdisplay = [maskdisplay,outport];
    end

    if blocktype == 3  % da write block
      maskdisplay = [maskdisplay,'DA Write'');'];
      channel = str2num( get_param( gcb, 'channel' ) );
      instart = 0;
      inport = '';
      if strcmp( in_enable, 'on' )
        inport = 'port_label(''input'',1,''E'');';
        instart = 1;
      end
      lth = length(channel);
      if lth < 1 | lth > 4
        error('The number of output channels must be in the range 1..4');
      end
      test = zeros(1,4);
      for i = 1:length(channel)
        chan = channel(i);
        if chan < 1 | chan > 4
          error('Output channels must be in the range 1..4');
        end
        if test(chan)
          error(['Attempting to use output channel ',num2str(chan),' more than once.']);
        end
        test(chan) = 1;
        inport = [inport,'port_label(''input'',',num2str(i+instart),',''',num2str(chan),''');'];
      end    
      maskdisplay = [maskdisplay,inport];
      if strcmp( out_enable, 'on' )
        outport = 'port_label(''output'',1,''E'');';
        maskdisplay = [maskdisplay,outport];
      end
    end

    if blocktype == 4  % da update block
      maskdisplay = [maskdisplay,'DA Update'');'];
      if strcmp( in_enable, 'on' )
        inport = 'port_label(''input'',1,''E'');';
        maskdisplay = [maskdisplay,inport];
      end
      if strcmp( out_enable, 'on' )
        outport = 'port_label(''output'',1,''E'');';
        maskdisplay = [maskdisplay,outport];
      end
    end

    if blocktype == 5  % Digital input block
      maskdisplay = [maskdisplay, 'Digital Input'');'];
      channel = str2num( get_param( gcb, 'channel' ) );
      if strcmp( in_enable, 'on' )
        inport = 'port_label(''input'',1,''E'');';
        maskdisplay = [maskdisplay,inport];
      end
      outstart = 0;
      outport = '';
      if strcmp( out_enable, 'on' )
        maskdisplay=[maskdisplay,'port_label(''output'',1,''E'');'];
        outstart = 1;
      end
      for i=1:length(channel)
        maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i+outstart),',''',num2str(channel(i)),''');'];
      end
      test = zeros(1,8);
      for i = 1:length(channel)
        chan = channel(i);
        if chan < 1 | chan > 8
          error('Digital input channel elements have to be in the range: 1..8');
        end
        if test(chan)
          error(['Digital input channel ',num2str(chan),' already in use']);
        end
        test(chan) = 1;
      end
    end
    
    if blocktype == 6  % Digital output block
      maskdisplay=[maskdisplay,'Digital Output'');'];
      channel = str2num( get_param( gcb, 'channel' ) );
      instart = 0;
      inport = '';
      if strcmp( in_enable, 'on' )
        maskdisplay=[maskdisplay,'port_label(''input'',1,''E'');'];
        instart = 1;
      end
      for i=1:length(channel)
        maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i+instart),',''',num2str(channel(i)),''');'];
      end
      test = zeros(1,8);
      for i = 1:length(channel)
        chan = channel(i);
        if chan < 1 | chan > 8
          error('Digital output channel elements have to be in the range: 1..8');
        end
        if test(chan)
          error(['Digital output channel ',num2str(chan),' already in use']);
        end
        test(chan) = 1;
      end
      if strcmp( out_enable, 'on' )
        outport = 'port_label(''output'',1,''E'');';
        maskdisplay = [maskdisplay,outport];
      end
      
      dochans = channel;
      doreset = str2num( get_param( gcb, 'reset' ) );
      doival = str2num( get_param( gcb, 'ival' ) );

      ldochans = length( dochans );
      ldoreset = length( doreset );
      ldoival = length( doival );
      if ldoreset ~= ldochans
        if ldoreset == 1
          doreset = doreset * ones(1,ldochans);
        else
          error(['The length of the digital output reset vector must ' ...
                 'be either the same length as the channel vector or ' ...
                 'have length 1.']);
        end
      end
      if ldoival ~= ldochans
        if ldoival == 1
          doival = doival * ones(1,ldochans);
        else
          error(['The length of the digital output initial value vector ' ...
                 'must be either the same length as the channel vector ' ...
                 'or have length 1.']);
        end
      end
    end
    
    init = 0;
    if blocktype == initblock
      init = 1;
    end

    if cal > 0
      xpcgate( 'settimeout', 15 ); % set download timeout if autocal
    end
    
    %[maskdisplay, ' ', num2str(blocktype), ' ', num2str(bcrinit), ' ', num2str(init) ]
    %disp('Exit phase 2');
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
