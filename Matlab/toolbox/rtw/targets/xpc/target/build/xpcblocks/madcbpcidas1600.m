function [gain, offset, control]=madcbpcidas1600(flag, channel, range, mux, ref, boardType)

% MADCBPCIDAS1600 - InitFcn and Mask Initialization for CB PCI-DAS 1600 series A/D section

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/03/25 04:08:19 $

persistent pool

if flag==1
  pool=[];
  return
end

if flag==2

  maxChannel=16;

  switch boardType
   case 1
    maskdisplay='disp(''PCI-DAS1602/12\nComputerBoards\n';
    description='PCI-DAS1602/12';
    supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
    supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
    supControl=[0, 1, 2, 3, 8, 9, 10, 11];
    resolution=4096;
   case 2
    maskdisplay='disp(''PCI-DAS1602/16\nComputerBoards\n';
    description='PCI-DAS1602/16';
    supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
    supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
    supControl=[0, 1, 2, 3, 8, 9, 10, 11];
    resolution=65536;
   case 3
    maskdisplay='disp(''PCIM-DAS1602/16\nComputerBoards\n';
    description='PCIM-DAS1602/16';
    supRange=[-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25];
    supRangeStr='-10, -5, -2.5, -1.25, 10, 5, 2.5, 1.25';
    supControl=[0, 1, 2, 3, 0, 1, 2, 3];
    resolution=65536;
  end

  maskdisplay=[maskdisplay,'Analog Input'');'];
  for i=1:channel
    maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i),''');'];
  end
  set_param(gcb,'MaskDisplay',maskdisplay);

  maskdescription=[description,10,'ComputerBoards',10,'Analog Input'];
  set_param(gcb,'MaskDescription',maskdescription);


  boardtype=['btype',num2str(boardType)];
  boardref='ref';
  if length(ref)==2
    ref=1000*ref(1)+ref(2);
  end
  if ref>=0
    boardref=[boardref,num2str(ref)];
  end

  if ~isfield(pool,boardtype)
    eval(['pool.',boardtype,'=[];']);
  end
  level1=getfield(pool,boardtype);
  if ~isfield(level1,boardref)
    eval(['level1.',boardref,'.chUsed=0;']);
  else
    error('only one block per physical board allowed');
  end
  level2=getfield(level1,boardref);

  if size(channel,1)~=1
    error('Channel vector must be a row vector');
  end
  if size(range,1)~=1 | size(range,2)~= 1
    error('Range argument must be a scalar');
  end

  if size(mux,1)~=1 | size(mux,2)~= 1
    error('MUX argument must be a scalar');
  end
  if mux==2
    maxChannel=8;
  end

  if channel < 1 | channel > maxChannel
    error(['The number of channels must be in the range 1..',num2str(maxChannel)]);
  end

  if boardType==1 | boardType == 2
    rangeval= supRange(range);
    control= supControl(range);
    if mux==1
      control= bitor(control, 4);
    end
    if rangeval < 0
      gain= -rangeval*2/resolution;
      offset= -rangeval;
    else
      gain= rangeval/resolution;
      offset= 0;
    end
  end
  if boardType==3
    rangeval= supRange(range);
    control= supControl(range);
    if rangeval < 0
      gain= -rangeval*2/resolution;
      offset= -rangeval;
    else
      gain= rangeval/resolution;
      offset= 0;
    end
  end

  level1=setfield(level1,boardref,level2);
  pool=setfield(pool,boardtype,level1);

end
