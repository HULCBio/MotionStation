function [maskdisplay, maskdescription] = ...
    mdiortddm64x0(phase, boardType, type, channel, port)

% MDIORTDDM64x0 - Mask Initialization for RTD DM64x0 DIO section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.5.6.1 $ $Date: 2004/03/02 03:04:51 $

  if phase == 1
    % cross-block checking
    maskType = 'd[i o]rtddm64[2 3]0'; 
    blocks = find_system(bdroot, ...
                         'FollowLinks', 'on', ...
                         'LookUnderMasks', 'all', ...
                         'RegExp', 'on', ...
                         'MaskType', maskType);
    sigs = [];
    for i = 1:length(blocks)
      port = get_param(blocks{i}, 'port'); 
      addr = get_param(blocks{i}, 'baseAddr'); 
      try
        base = hex2dec(addr(3:end));
      catch
        error(['Can''t evaluate base address for ' blocks{i}]);
      end
      sig = port - '0' + 10 * base;
      if ismember(sig, sigs)
        error(['More than one DM64x0 series Digital I/O block in the model uses the settings port = ' port ', base address = ' addr]);
      end
      sigs = union(sig, sigs);
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
    % check for channel elements smaller than 1 or greater than 8
    if ~isempty(find(channel<1)) | ~isempty(find(channel>8))
      error('Channel Vector elements must be in the range 1..8');
    end
    % check for channelsalready used
    tmp=zeros(1,8);
    for i=channel
      if tmp(i)
        error(['Channel ',num2str(i),' already in use']);
      end
      tmp(i)=1;
    end

    % construct Mask icon
    switch type
     case 1
      xpos=0.95;
      al='right';
      display=[];
      switch boardType
       case 1
        tmp='DM6420';
       case 2
        tmp='DM6430';
      end
      display=[display,'text(',num2str(xpos),',0.75,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='RTD';
      display=[display,'text(',num2str(xpos),',0.50,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='DigitalOut';
      maskdisplay=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      for i=1:length(channel)
        chan=num2str(channel(i));
        switch port
         case 1, chan=[chan,' (P0)'];
         case 2, chan=[chan,' (P1)'];
        end
        maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',chan,''');'];
      end
      switch boardType
       case 1
        maskdescription=['DM6420',10,'RTD',10,'Digital Output'];
       case 2
        maskdescription=['DM6430',10,'RTD',10,'Digital Output'];
      end
      %set_param(gcb,'MaskDisplay',maskdisplay);
      %set_param(gcb,'MaskDescription',maskdescription);
     case 2
      xpos=0.05;
      al='left';
      display=[];
      switch boardType
       case 1
        tmp='DM6420';
       case 2
        tmp='DM6430';
      end
      display=[display,'text(',num2str(xpos),',0.75,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='RTD';
      display=[display,'text(',num2str(xpos),',0.50,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='DigitalIn';
      maskdisplay=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      for i=1:length(channel)
        chan=num2str(channel(i));
        switch port
         case 1, chan=[chan,' (P0)'];
         case 2, chan=[chan,' (P1)'];
        end
        maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',chan,''');'];
      end
      switch boardType
       case 1
        maskdescription=['DM6420',10,'RTD',10,'Digital Input'];
       case 2
        maskdescription=['DM6430',10,'RTD',10,'Digital Input'];
      end
    end
  end
  