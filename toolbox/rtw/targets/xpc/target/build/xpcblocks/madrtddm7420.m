function [channelout, couplingout, rangeout, gainout, maskdisplay, maskdescription]= madrtddm7420(phase, channel, coupling, range, gain)

% MADRTDDM7420 - Mask Initialization for RTD DM7420 A/D section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.5.6.1 $ $Date: 2004/03/02 03:04:07 $

  if phase == 1
    % collect information from all blocks having the same MaskType
    blocks=find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', get_param( gcb, 'MaskType' ) );
    % if only one instance is found skip next step
    if length(blocks)>1
      % loop over all blocks and collect all information for cross-block checking
      info.pci = zeros(1,length(blocks));
      for i = 1:length(blocks)
        % PCI-slot (physical board reference)
        pciData = evalin('caller', get_param(blocks{i},'pciSlot'));
        if size(pciData, 2) == 1
          info.pci(i) = pciData(1);
        else
          info.pci(i) = 256 * pciData(1) + pciData(2);
        end
      end
      % do cross-block checking by using the collected information
      % check for multiple instances using the same physical board
      if length(info.pci) ~= length(unique(info.pci))
        error('only one instance per physical board allowed');
      end
    end
  end

  if phase == 2
    % check parameters
    % channel
    if isempty(channel)
      error('Channel Vector parameter cannot be empty');
    end
    if ~isa(channel,'double')
      error('Channel Vector parameter must be of class double');
    end
    if size(channel,1)>1
      error('Channel Vector parameter must be a row vector');
    end
    % round channel vector
    channel= round(channel);
    % check for channel elements smaller than 1 or greater than 16
    if ~isempty(find(channel<1)) | ~isempty(find(channel>16))
      error('Channel Vector elements must be in the range 1..16');
    end
    % coupling
    if isempty(coupling)
      error('Coupling Vector parameter cannot be empty');
    end
    if ~isa(coupling,'double')
      error('Coupling Vector parameter must be of class double');
    end
    % if the parameter is a scalar, apply scalar expansion
    if size(coupling,1)==1 & size(coupling,2)==1
      coupling= coupling * ones(1,length(channel));
    end
    if size(coupling,1)>1
      error('Coupling Vector parameter must either be a scalar (scalar expansion applies) or a row vector');
    end
    if length(coupling)~=length(channel)
      error('Coupling Vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
    end
    % round coupling vector
    coupling= round(coupling);
    % check for coupling elements smaller than 1 or greater 3
    if ~isempty(find(coupling<1)) | ~isempty(find(coupling>3))
      error('Coupling Vector elements must be either 1 (RSE), 2 (NRSE) or 3 (DIFF)');
    end
    for i=1:length(coupling)
      if coupling(i)==3
        if channel(i)>8
          error('Channel Vector element cannot exceed value 8, if corresponding coupling element defines Differential coupling');
        end
        % check that AIN- channels are not found in channel vector if a channel is in diff mode
        if ~isempty(find(channel==(channel(i)+8)))
          error(['The Coupling Vector element for channel ',num2str(channel(i)),' defines Differential mode, therefore channel ',num2str(channel(i)+8),' cannot be used elsewhere in the Channel Vector']);
        end
      end
    end
    % range
    if isempty(range)
      error('Range Vector parameter cannot be empty');
    end
    if ~isa(range,'double')
      error('Range Vector parameter must be of class double');
    end
    % if the parameter is a scalar, apply scalar expansion
    if size(range,1)==1 & size(range,2)==1
      range= range * ones(1,length(channel));
    end
    if size(range,1)>1
      error('Range Vector parameter must either be a scalar (scalar expansion applies) or a row vector');
    end
    if length(range)~=length(channel)
      error('Range Vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
    end
    % round range vector
    range= round(range);
    % check for range elements (must be either -10, -5, or 10)
    if ~isempty(find(ismember(range,[-10,-5,10])==0))
      error('Range Vector elements must be either -10 (+-10V), -5 (+-5V) or 10 (0-10V)');
    end
    % gain
    if isempty(gain)
      error('Gain Vector parameter cannot be empty');
    end
    if ~isa(gain,'double')
      error('Gain Vector parameter must be of class double');
    end
    % if the parameter is a scalar, apply scalar expansion
    if size(gain,1)==1 & size(gain,2)==1
      gain= gain * ones(1,length(channel));
    end
    if size(gain,1)>1
      error('Gain Vector parameter must either be a scalar (scalar expansion applies) or a row vector');
    end
    if length(gain)~=length(channel)
      error('Gain Vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
    end
    % round gain vector
    gain= round(gain);
    % check for gain elements (must be either 1,2,4,8,16 or 32)
    if ~isempty(find(ismember(gain,[1,2,4,8,16,32])==0))
      error('Gain Vector elements must be either 1, 2, 4, 8, 16 or 32');
    end

    % construct the output values
    channelout=channel-1;
    couplingout=coupling-1;
    rangeout=range;
    rangeout(find(rangeout==-10))=1;
    rangeout(find(rangeout==-5))=0;
    rangeout(find(rangeout==10))=2;
    gainout=log2(gain);

    % construct Mask icon
    description='DM7420';
    xpos=0.05;
    al='left';
    display=[];
    tmp='DM7420';
    display=[display,'text(',num2str(xpos),',0.75,''',tmp,''',''horizontalAlignment'',''',al,''');'];
    tmp='RTD';
    display=[display,'text(',num2str(xpos),',0.50,''',tmp,''',''horizontalAlignment'',''',al,''');'];
    tmp='AnalogIn';
    maskdisplay=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];
    for i=1:length(channel)
      chan=num2str(channel(i));
      switch coupling(i)
       case 1, chan=[chan,' (RSE)'];
       case 2, chan=[chan,' (NRSE)'];
       case 3, chan=[chan,' (DIFF)'];   
      end
      maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',chan,''');'];
    end
    maskdescription=[description,10,'Real Time Devices',10,'Analog Input'];
  end
  