function [board, boardType, devName, gain, gainVal, mux, ...
          framesize, freq, frametime, scanfreq, sh, maskdisplay, ...
          maskdescription, burst, nbursts, sampletime ] = ...
    madueipd2mfxframe( boardtype, channel, gain, mux, ...
                 framesize, freq, burst, scantime, sampletime, ...
                 frametime, pciSlot )

% if this is a library open, just quit.  Makes for faster library display.
%if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
%  return
%end

  maskType= get_param(gcb,'MaskType');
  index= find(maskType=='_');
  maskType= maskType(4:index(1)-1);

  [maskdisplay, description, devName, boardType, maxADChannel, maxDAChannel, ...
   maxDIChannel, maxDOChannel gains, sh, maxCVClock ]= mgetueideviceframe(maskType, boardtype);

  maskdisplay=[maskdisplay,'Frame Analog Input'');'];
  for i=1:length(channel)
    maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
  end
  maskdescription=[description,10,'United Electronic Industries',10,'Analog Input'];

  board= get_param(gcb, 'UserData');
  if isempty(board)
    board=0;
  end

  % check parameters
  % channel


  %   Copyright 2002-2003 The MathWorks, Inc.
  %   $Revision: 1.1.6.2 $  $Date: 2003/12/01 04:26:01 $
  if isempty(channel)
    error('Channel vector parameter cannot be empty');
  end
  if ~isa(channel,'double')
    error('Channel vector parameter must be of class double');
  end
  if size(channel,1)>1
    error('Channel vector parameter must be a row vector');
  end
  % round channel vector
  channel= round(channel);
  % check for channel elements smaller than 1 or greater than maxADChannel
  if ~isempty(find(channel<1)) | ~isempty(find(channel>maxADChannel))
    error(['Channel Vector elements must be in the range 1..',num2str(maxADChannel)]);
  end
  % gain
  if isempty(gain)
    error('Gain vector parameter cannot be empty');
  end
  if ~isa(gain,'double')
    error('Gain vector parameter must be of class double');
  end
  % if the parameter is a scalar, apply scalar expansion
  if size(gain,1)==1 & size(gain,2)==1
    gain= gain * ones(1,length(channel));
  end
  if size(gain,1)>1
    error('Gain vector parameter must either be a scalar (scalar expansion applies) or a row vector');
  end
  if length(gain)~=length(channel)
    error('Gain vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
  end
  % round gain vector
  gain= round(gain);
  % check for gain elements (must be either 1,2,4,8,16 or 32)
  index= find(ismember(gain,gains)==0);
  if ~isempty(index)
    error(['Gain Vector elements must be in the set [', num2str(gains), ']']);
  end
  gainVal= gain;
  for i=1:length(gainVal)
    gain(i)=find(gains==gain(i))-1;
  end
  % mux
  if isempty(mux)
    error('Mux vector parameter cannot be empty');
  end
  if ~isa(mux,'double')
    error('Mux vector parameter must be of class double');
  end
  % if the parameter is a scalar, apply scalar expansion
  if size(mux,1)==1 & size(mux,2)==1
    mux= mux * ones(1,length(channel));
  end
  if size(mux,1)>1
    error('Mux vector parameter must either be a scalar (scalar expansion applies) or a row vector');
  end
  if length(mux)~=length(channel)
    error('Mux vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
  end
  % round mux vector
  mux= round(mux);
  % check for mux elements smaller than 0 or greater than 1
  if ~isempty(find(mux<0)) | ~isempty(find(mux>1))
    error('Mux vector elements must be either 0 (fast) or 1 (slow)');
  end

  % Check framesize, scantime and frametime variables for consistancy.
  % This is a bit complicated.
  %
  % if frametime == -1, then frametime = framesize * scantime
  % if scantime  == -1, then scantime  = frametime / framesize 
  % if framesize == -1, then framesize = frametime / scantime

  % if freq = -1, then freq is set to continuous (max for the board)
  %               and is legal as long as framesize / frametime <=
  %               maxCVClock

  nchans = length(channel);

  if freq == -1  % Run CV clock at maximum for the board.
    freq = maxCVClock;
  end

  icount = 0;  % count the number of items that are -1
  if frametime == -1
    icount = icount + 1;
  end
  if scantime == -1
    icount = icount + 1;
  end
  if framesize == -1
    icount = icount + 1;
  end

  if icount == 0  % all three are set, insist that at least one must be computed
    error(['At least one of Frame size, Scan time or Frame time must be ' ...
           'left unspecified']);
  elseif icount == 1  % only one is set, compute it
    if frametime == -1
      frametime = framesize * scantime;
    elseif scantime == -1
      scantime = frametime / framesize;
    elseif framesize == -1
      framesize = frametime / scantime;
    end
  else
    error(['At most one of Frame size, Scan time or Frame time can be set ' ...
           'to -1 (unspecified)']);
  end

  if nchans / freq > scantime
    error(['Can''t acquire a ',num2str(framesize),' sample frame on ', ...
           num2str(nchans), ' channels at ', ...
           num2str(freq), ' Hz in ', num2str(frametime), ' seconds']);
  end

  scanfreq = 1 / scantime;

  % coming in, sampletime is boolean, 1 if the block is in an ISR, else 0
  if sampletime == 1  % in ISR, inherit block sample time
    sampletime = -1;
  else
    sampletime = frametime; % Set the block sampletime to the frame time.
  end

  if freq > maxCVClock
    error(['The sample clock frequency (',num2str(freq), ...
           ') exceeds the maximum clock frequency (', num2str(maxCVClock), ...
           ') for this board' ]);
  end

  framelength = nchans * framesize;
  % Adjust this test when the board supports more samples per frame.
  if framelength > 512
    error(['A frame of ', num2str(nchans), 'channels * ', num2str(framesize), ...
           ' samples results in a total frame size of ', num2str(framelength), ...
           ' samples which is larger than the permitted 512 samples']);
  end

  switch burst
   case 1
    burst = 32;
   case 2
    burst = 16;
   case 3
    burst = 8;
  end

  % compute the number of burst length packets that the DMA engine
  % will transfer.  Round up with ceil() so the remainder take the
  % first part of a new burst.
  nbursts = ceil( framelength / burst );

  %disp(['framesize = ',num2str(framesize),', freq = ', num2str(freq), ...
  %      ', frametime = ', num2str(frametime), ...
  %      ', scanfreq = ', num2str(scanfreq)]);
  %disp(['Burst size = ', num2str(burst),', number of bursts = ', ...
  %      num2str(nbursts)]);
