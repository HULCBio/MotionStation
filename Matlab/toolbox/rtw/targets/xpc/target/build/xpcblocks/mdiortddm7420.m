function [maskdisplay, maskdescription]= mdiortddm7420(phase, type, channel)

% MDIORTDDM7420 - Mask Initialization for RTD DM7420 DIO section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.7.6.1 $ $Date: 2004/03/02 03:04:52 $

  if phase == 1
    blocks = find_system(bdroot, ...
                         'FollowLinks', 'on', ...
                         'LookUnderMasks', 'all', ...
                         'RegExp', 'on', ...
                         'MaskType', 'd[i o]rtddm7420');
    settings = [];
    for i = 1:length(blocks)
      port = get_param(blocks{i}, 'port'); 
      try
        slot = evalin('caller', get_param(blocks{i},'pciSlot')); 
      catch
        error(['Can''t evaluate PCI slot for ' blocks{i}]);
      end
      if size(slot, 2) == 1
        pci = slot(1);
      else
        pci = 256 * slot(1) + slot(2);
      end
      setting = 256 * pci + port;
      if ismember(setting, settings)
        error(['More than one DM7420 Digital I/O block in the model uses the settings port = ' num2str(port) ', PCI slot = ' num2str(slot)]);
      end
      settings = union(setting, settings);
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
      tmp='DM7420';
      display=[display,'text(',num2str(xpos),',0.75,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='RTD';
      display=[display,'text(',num2str(xpos),',0.50,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='DigitalOut';
      maskdisplay=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      for i=1:length(channel)
        chan=num2str(channel(i));
        maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',chan,''');'];
      end
      maskdescription=['DM7420',10,'RTD',10,'Digital Output'];
      %set_param(gcb,'MaskDisplay',maskdisplay);
      %set_param(gcb,'MaskDescription',maskdescription);
     case 2
      xpos=0.05;
      al='left';
      display=[];
      tmp='DM7420';
      display=[display,'text(',num2str(xpos),',0.75,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='RTD';
      display=[display,'text(',num2str(xpos),',0.50,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      tmp='DigitalIn';
      maskdisplay=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];
      for i=1:length(channel)
        chan=num2str(channel(i));
        maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',chan,''');'];
      end
      maskdescription=['DM7420',10,'RTD',10,'Digital Input'];
      %set_param(gcb,'MaskDisplay',maskdisplay);
      %set_param(gcb,'MaskDescription',maskdescription);
    end
  end
  