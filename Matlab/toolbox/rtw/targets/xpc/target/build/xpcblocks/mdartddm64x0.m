function [maskdisplay, maskdescription]= ...
    mdartddm64x0(phase, boardType, channel, range)

% MDARTDDM64x0 - Mask Initialization for RTD DM64x0 D/A section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.3.4.1 $ $Date: 2004/03/02 03:04:45 $

  if phase == 1
    % collect information from all blocks having the same MaskType
    blocks=find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', get_param( gcb, 'MaskType' ) );
    % if only one instance is found skip next step
    if length(blocks)>1
      % loop over all blocks and collect all information for cross-block checking
      maskValues= get_param(blocks,'MaskValues');
      info.base= zeros(1,length(blocks));
      for block=1:length(blocks)
        % base address (physical board reference)
	tmp=maskValues{block}{4};
        info.base(block)= hex2dec(tmp(3:end));
      end
      % do cross-block checking by using the collected information
      % check for multiple instances using the same physical board
      %if length(info.base)~=length(unique(info.base))
      %  error('only one instance per physical board allowed');
      %end
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
    if ~isempty(find(channel<1)) | ~isempty(find(channel>2))
      error('Channel Vector elements must be in the range 1..2');
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
    % check for range elements (must be either -5, 10, or 5)
    if boardType==1
      if ~isempty(find(ismember(range,[-5,10,5])==0))
        error('Range Vector elements must be either -5 (+-5V), 10 (0-10V), or 5 (0-5V)');
      end
    end


    % construct Mask icon
    switch boardType
     case 1
      description='DM6420';
     case 2
      description='DM6430';
    end
    xpos=0.95;
    al='right';
    display=[];
    tmp=description;
    display=[display,'text(',num2str(xpos),',0.75,''',tmp,''',''horizontalAlignment'',''',al,''');'];
    tmp='RTD';
    display=[display,'text(',num2str(xpos),',0.50,''',tmp,''',''horizontalAlignment'',''',al,''');'];
    tmp='AnalogOut';
    maskdisplay=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];
    for i=1:length(channel)
      chan=num2str(channel(i));
      chan=[chan,' (SE)'];
      maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',chan,''');'];
    end
    maskdescription=[description,10,'Real Time Devices',10,'Analog Output'];

  end
  