function [range, reset, initValue]=mdanipcie(flag, channel, range, reset, initValue, ref, boardType)

% MADNIPCIE - InitFcn and Mask Initialization for NI PCI-E series D/A section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.11.6.1 $ $Date: 2004/03/02 03:04:44 $

persistent danipcie

if flag==1
  danipcie=[];
end

if flag==2

  maxChannel=2;

  switch boardType
   case 1
    maskdisplay='disp(''PCI-6023E\nNational Instr.\n';
    description='PCI-6023E';
    supRange=[];
    supRangeStr='';
    range=-10*ones(1,length(channel));
   case 2
    maskdisplay='disp(''PCI-6024E\nNational Instr.\n';
    description='PCI-6024E';
    supRange=[-10];
    supRangeStr='-10';
    range=-10*ones(1,length(channel));
   case 3
    maskdisplay='disp(''PCI-6025E\nNational Instr.\n';
    description='PCI-6025E';
    supRange=[-10];
    supRangeStr='-10';
    range=-10*ones(1,length(channel));
   case 4
    maskdisplay='disp(''PCI-6070E\nNational Instr.\n';
    description='PCI-6070E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 5
    maskdisplay='disp(''PCI-6040E\nNational Instr.\n';
    description='PCI-6040E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 6
    maskdisplay='disp(''PXI-6070E\nNational Instr.\n';
    description='PXI-6070E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 7
    maskdisplay='disp(''PXI-6040E\nNational Instr.\n';
    description='PXI-6040E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 8
    maskdisplay='disp(''PCI-6071E\nNational Instr.\n';
    description='PCI-6071E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 9
    maskdisplay='disp(''PCI-6052E\nNational Instr.\n';
    description='PCI-6052E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 10
    maskdisplay='disp(''PCI-6030E\nNational Instr.\n';
    description='PCI-6030E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 11
    maskdisplay='disp(''PCI-6031E\nNational Instr.\n';
    description='PCI-6031E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
   case 12
    maskdisplay='disp(''PXI-6071E\nNational Instr.\n';
    description='PXI-6071E';
    supRange=[-10, 10];
    supRangeStr='-10, 10';
  end

  maskdisplay=[maskdisplay,'Analog Output'');'];
  for i=1:length(channel)
    maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
  end
  set_param(gcb,'MaskDisplay',maskdisplay);

  maskdescription=[description,10,'National Instruments',10,'Analog Output'];
  set_param(gcb,'MaskDescription',maskdescription);


  boardtype=['btype',num2str(boardType)];
  boardref='ref';
  if length(ref)==2
    ref=1000*ref(1)+ref(2);
  end
  if ref>=0
    boardref=[boardref,num2str(ref)];
  end

  if ~isfield(danipcie,boardtype)
    eval(['danipcie.',boardtype,'=[];']);
  end
  level1=getfield(danipcie,boardtype);
  if ~isfield(level1,boardref)
    eval(['level1.',boardref,'.chUsed=zeros(1,64);']);
  else
    error('only one block per physical board allowed');
  end
  level2=getfield(level1,boardref);

  if size(channel,1)~=1
    error('Channel Vector must be a row vector');
  end
  if size(range,1)~=1
    error('Range Vector must be a row vector');
  end
  if length(range)~=length(channel)
    error('Range Vector must have the same numbers of elements as the Channel Vector');
  end

  for i=1:length(channel)
    chan=round(channel(i));
    rng=range(i);
    if chan < 1 | chan > maxChannel
      error(['Channel Vector elements have to be in the range: 1..',maxChannel]);
    end
    if level2.chUsed(chan)
      error(['channel ',num2str(chan),' already in use']);
    else
      level2.chUsed(chan)=1;
    end
    if ~ismember(rng,supRange)
      error(['Range Vector elements have to be in the range: ',supRangeStr]);
    end
  end

  level1=setfield(level1,boardref,level2);
  danipcie=setfield(danipcie,boardtype,level1);

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

end
