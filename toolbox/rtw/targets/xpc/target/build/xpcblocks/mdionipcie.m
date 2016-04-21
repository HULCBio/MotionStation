function [control, reset, initValue]=mdionipcie(flag, channel, ref, direct, boardType, reset, initValue)

% MDIONIPCIE - InitFcn and Mask Initialization for NI PCI-E series digital I/O section
% The final two parameters (reset and initValue) are used only when direct = 2 (Output)  

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision $ $Date: 2004/03/02 03:04:50 $

persistent dionipcie

if flag==1
  dionipcie=[];
end

if flag==2

  switch boardType

   case 1
    maskdisplay='disp(''PCI-6023E\nNational Instr.\n';
    description='PCI-6023E';
   case 2
    maskdisplay='disp(''PCI-6024E\nNational Instr.\n';
    description='PCI-6024E';
   case 3
    maskdisplay='disp(''PCI-6025E\nNational Instr.\n';
    description='PCI-6025E';
   case 4
    maskdisplay='disp(''PCI-6070E\nNational Instr.\n';
    description='PCI-6070E';
   case 5
    maskdisplay='disp(''PCI-6040E\nNational Instr.\n';
    description='PCI-6040E';
   case 6
    maskdisplay='disp(''PXI-6070E\nNational Instr.\n';
    description='PXI-6070E';
   case 7
    maskdisplay='disp(''PXI-6040E\nNational Instr.\n';
    description='PXI-6040E';
   case 8
    maskdisplay='disp(''PCI-6071E\nNational Instr.\n';
    description='PCI-6071E';
   case 9
    maskdisplay='disp(''PCI-6052E\nNational Instr.\n';
    description='PCI-6052E';
   case 10
    maskdisplay='disp(''PCI-6030E\nNational Instr.\n';
    description='PCI-6030E';
   case 11
    maskdisplay='disp(''PCI-6031E\nNational Instr.\n';
    description='PCI-6031E';
   case 12
    maskdisplay='disp(''PXI-6071E\nNational Instr.\n';
    description='PXI-6071E';
   case 13
    maskdisplay='disp(''PCI-6713 \nNational Instr.\n';
    description='PCI-6713 ';
   case 14
    maskdisplay='disp(''PXI-6713 \nNational Instr.\n';
    description='PXI-6713 ';
   case 15
    maskdisplay='disp(''PCI-6711 \nNational Instr.\n';
    description='PCI-6711 ';
  end


  if direct==1
    maskdisplay=[maskdisplay,'Digital Input'');'];
    maskdescription=[description,10,'National Instruments',10,'Digital Input'];
    for i=1:length(channel)
      maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
    end
  elseif direct==2
    maskdisplay=[maskdisplay,'Digital Output'');'];
    maskdescription=[description,10,'National Instruments',10,'Digital Output'];
    for i=1:length(channel)
      maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
    end
    %%% check reset vector parameter
    if ~isa(reset, 'double')
        error('Reset vector parameter must be of class double');
    end
    if size(reset) == [1 1]
        reset = reset * ones(size(channel));
    elseif ~all(size(reset) == size(channel))
        error('Reset parameter must be a scalar or the same shape as the Channel parameter');
    end
    reset = round(reset);
    if ~all(ismember(reset, [0 1]))
        error('Reset vector elements must be 0 or 1');
    end

    %%% check initValue vector parameter
    if ~isa(initValue, 'double')
        error('Initial value vector parameter must be of class double');
    end
    if size(initValue) == [1 1]
        initValue = initValue * ones(size(channel));
    elseif ~all(size(initValue) == size(channel))
        error('Initial value parameter must be a scalar or the same shape as the Channel parameter');
    end
    initValue = round(initValue);
    if ~all(ismember(initValue, [0 1]))
        error('Initial value vector elements must be 0 or 1');
    end
  end
  set_param(gcb,'MaskDisplay',maskdisplay);
  set_param(gcb,'MaskDescription',maskdescription);

  boardtype=['btype',num2str(boardType)];
  boardref='ref';
  if length(ref)==2
    ref=1000*ref(1)+ref(2);
  end
  if ref>=0
    boardref=[boardref,num2str(ref)];
  end

  % construct structure dionipcie.boardtype.boardref.chUsed
  % .control

  if ~isfield(dionipcie,boardtype)
    eval(['dionipcie.',boardtype,'=[];']);
  end
  level1=getfield(dionipcie,boardtype);
  if ~isfield(level1,boardref)
    eval(['level1.',boardref,'.chUsed=zeros(1,8);']);
    eval(['level1.',boardref,'.control=0;']);
  end
  level2=getfield(level1,boardref);

  for i=1:length(channel)
    chan=channel(i);
    if chan>8 | chan < 1
      error('channel elements have to be in the range: 1..8');
    end
    if level2.chUsed(chan)
      error(['channel ',num2str(chan),' already in use']);
    end
    level2.chUsed(chan)=direct;
    if direct==2
      level2.control=bitset(level2.control,chan);
    end
  end

  control=level2.control;
  level1=setfield(level1,boardref,level2);
  dionipcie=setfield(dionipcie,boardtype,level1);

end
