function [tctype, gain, format, maskdisplay, maskdescription] = ...
    mtccb(phase, nchannels, tctypein, gainin, formatin, cjc)

% MTCCB - Mask Initialization function for ComputerBoards TC driver blocks

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.4.4.1 $ $Date: 2004/03/02 03:04:54 $

  if phase == 1
    masktype = get_param( gcb, 'MaskType' );
    blocks=find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', masktype );
    tmp=0;
    for i=1:length(blocks)
      block= blocks{i};
      slot= evalin( 'caller', get_param(block,'pcislot') ) + 2;
      if length(slot) == 2  % create a unique single number from bus,slot
        pcislot = slot(1)*256 + slot(2);
      else
        pcislot = slot
      end
      if length(tmp)<pcislot
	tmp(pcislot)=0;
      end
      if tmp(pcislot)
	error('Only one instance of the CB PCI-DAS-TC block per physical board allowed in a model');
      else
	tmp(pcislot)=1;
      end
    end
  end
  
  if phase == 2
    maskdisplay='disp(''PCI-DAS-TC\nComputerBoards\n';
    description='PCI-DAS-TC';
    maskdisplay=[maskdisplay,'Thermocouple'');'];
    for i=1:nchannels
      maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i),''');'];
    end
    if cjc
      maskdisplay=[maskdisplay,'port_label(''output'',',num2str(nchannels+1),',''CJC'');'];
    end
    maskdescription=[description,10,'ComputerBoards',10,'Thermocouple Input'];


    if ~isa(tctypein,'cell')
      error('Thermocouple type parameter must be a cell array');
    end
    if size(tctypein,1)~=1
      error('Thermocouple type parameter must be a row vector cell');
    end
    if length(tctypein)>1
      if length(tctypein)~=nchannels
	error('Thermocouple type vector parameter must have an element for each channel to be acquired');
      end
    end
    tctype=zeros(1,nchannels);
    for i=1:length(tctypein)
      tct= tctypein{i};
      if ~isa(tct,'char')
	error('Thermocouple type parameter elements must be of type char');
      end
      switch tct
       case 'B'
	tctype(i)=1;
       case 'E'
	tctype(i)=2;
       case 'J'
	tctype(i)=3;
       case 'K'
	tctype(i)=4;
       case 'R'
	tctype(i)=5;
       case 'S'
	tctype(i)=6;
       case 'T'
	tctype(i)=7;
       case 'NC'
	tctype(i)=8;
       otherwise
	error('Thermocouple type parameter elements must be either ''B'',''E'',''J'',''K'',''R'',''S'',''T'', or ''NC'' (not connected)');
      end
    end
    if length(tctypein)<nchannels % we do scalar expansion
      tctype(:)=tctype(1);
    end

    if ~isa(gainin,'double')
      error('Input gain parameter must be a double array');
    end
    if size(gainin,1)~=1
      error('Input gain parameter must be a row vector');
    end
    if length(gainin)>1
      if length(tctypein)~=nchannels
	error('Input gain vector parameter must have an element for each channel to be acquired');
      end
    end
    gain=zeros(1,nchannels);
    for i=1:length(gainin)
      g= gainin(i);
      switch g
       case 1
	gain(i)=1;
       case 125
	gain(i)=2;
       case 166.7
	gain(i)=3;
       case 400
	gain(i)=4;
       otherwise
	error('Input gain parameter elements must be either 1, 125, 166.7 , or 400');
      end
    end
    if length(gainin)<nchannels % we do scalar expansion
      gain(:)=gain(1);
    end

    if ~isa(formatin,'cell')
      error('Temperature format parameter must be a cell array');
    end
    if size(formatin,1)~=1
      error('Temperature format parameter must be a row vector cell');
    end
    if length(formatin)>1
      if length(formatin)~=nchannels
	error('Temperature format vector parameter must have an element for each channel to be acquired');
      end
    end
    format=zeros(1,nchannels);
    for i=1:length(formatin)
      f= formatin{i};
      if ~isa(f,'char')
	error('Temperature format parameter elements must be of type char');
      end
      switch f
       case 'C'
	format(i)=1;
       case 'F'
	format(i)=2;
       case 'K'
	format(i)=3;
       otherwise
	error('Temperature format parameter elements must be either ''C'' (Centigrade), ''F'' (Fahrenheit), or ''K'' (Kelvin)');
      end
    end
    if length(formatin)<nchannels % we do scalar expansion
      format(:)=format(1);
    end
  end
  

  
	
	
	
	
	
	
	

	
  

  
  
  




