function madnipcie(flag, channel, range, coupling, ref, boardType)

% MADNIPCIE - InitFcn and Mask Initialization for NI PCI-E series A/D section

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.8.6.1 $ $Date: 2004/03/02 03:04:05 $

persistent adnipcie

if flag==1
  adnipcie=[];
end

if flag==2

  maxChannel=16;

  switch boardType
   case 1
    maskdisplay='disp(''PCI-6023E\nNational Instr.\n';
    description='PCI-6023E';
    supRange=[-10, -5, -0.5, -0.05];
    supRangeStr='-10, -5, -0.5, -0.05';
   case 2
    maskdisplay='disp(''PCI-6024E\nNational Instr.\n';
    description='PCI-6024E';
    supRange=[-10, -5, -0.5, -0.05];
    supRangeStr='-10, -5, -0.5, -0.05';
   case 3
    maskdisplay='disp(''PCI-6025E\nNational Instr.\n';
    description='PCI-6025E';
    supRange=[-10, -5, -0.5, -0.05];
    supRangeStr='-10, -5, -0.5, -0.05';
   case 4
    maskdisplay='disp(''PCI-6070E\nNational Instr.\n';
    description='PCI-6070E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
   case 5
    maskdisplay='disp(''PCI-6040E\nNational Instr.\n';
    description='PCI-6040E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
   case 6
    maskdisplay='disp(''PXI-6070E\nNational Instr.\n';
    description='PXI-6070E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
   case 7
    maskdisplay='disp(''PXI-6040E\nNational Instr.\n';
    description='PXI-6040E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
   case 8
    maskdisplay='disp(''PCI-6071E\nNational Instr.\n';
    description='PCI-6071E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
    maxChannel=64;
   case 9
    maskdisplay='disp(''PCI-6052E\nNational Instr.\n';
    description='PCI-6052E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
   case 10
    maskdisplay='disp(''PCI-6030E\nNational Instr.\n';
    description='PCI-6030E';
    supRange=[-10,-5,-2,-1,-0.5,-0.2,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2, -1, -0.5, -0.2, -0.1, 10, 5, 2, 1, 0.5, 0.2, 0.1';
   case 11
    maskdisplay='disp(''PCI-6031E\nNational Instr.\n';
    description='PCI-6031E';
    supRange=[-10,-5,-2,-1,-0.5,-0.2,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2, -1, -0.5, -0.2, -0.1, 10, 5, 2, 1, 0.5, 0.2, 0.1';
    maxChannel=64;
   case 12
    maskdisplay='disp(''PXI-6071E\nNational Instr.\n';
    description='PXI-6071E';
    supRange=[-10,-5,-2.5,-1,-0.5,-0.25,-0.1,-0.05,10,5,2,1,0.5,0.2,0.1];
    supRangeStr='-10, -5, -2.5, -1, -0.5, -0.25, -0.1, -0.05, 10, 5, 2, 1, 0.5, 0.2, 0.1';
    maxChannel=64;
  end

  maskdisplay=[maskdisplay,'Analog Input'');'];
  for i=1:length(channel)
    maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
  end
  set_param(gcb,'MaskDisplay',maskdisplay);

  maskdescription=[description,10,'National Instruments',10,'Analog Input'];
  set_param(gcb,'MaskDescription',maskdescription);


  boardtype=['btype',num2str(boardType)];
  boardref='ref';
  if length(ref)==2
    ref=1000*ref(1)+ref(2);
  end
  if ref>=0
    boardref=[boardref,num2str(ref)];
  end

  if ~isfield(adnipcie,boardtype)
    eval(['adnipcie.',boardtype,'=[];']);
  end
  level1=getfield(adnipcie,boardtype);
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
  if size(coupling,1)~=1
    error('Coupling Vector must be a row vector');
  end

  if length(range)~=length(channel)
    error('Range Vector must have the same numbers of elements as the Channel Vector');
  end

  if length(coupling)~=length(channel)
    error('Coupling Vector must have the same numbers of elements as the Channel Vector');
  end

  for i=1:length(channel)
    chan=round(channel(i));
    rng=range(i);
    cpl=round(coupling(i));
    if ~ismember(cpl,[0,1,2])
      error('Coupling Vector elements have to be either 0, 1 or 2');
    end
    if ~ismember(rng,supRange)
      error(['Range Vector elements have to be in the range: ',supRangeStr]);
    end
    if cpl<2
      if chan < 1 | chan > maxChannel
        error(['Channel Vector elements have to be in the range: 1..',num2str(maxChannel)]);
      end
      if level2.chUsed(chan)
        error(['channel ',num2str(chan),' already in use']);
      else
        level2.chUsed(chan)=1;
      end
    else  
      if chan < 1 | mod(chan,16)>8
        if maxChannel == 16
            tmp='1..8';
        elseif maxChannel == 64
            tmp='1..8,17..24,33..40,49..56';
        end
        error(['for DIFF coupling mode the Channel Vector element has to be in the range: ',tmp]);
      end
      if level2.chUsed(chan)
        error(['channel ',num2str(chan),' already in use']);
      else
        level2.chUsed(chan)=1;
        if level2.chUsed(chan+8)
          error(['channel ',num2str(chan+8),' already in use (needed for DIFF coupling mode']);
        else
          level2.chUsed(chan+8)=1;
        end
      end
    end
  end

  level1=setfield(level1,boardref,level2);
  adnipcie=setfield(adnipcie,boardtype,level1);

end
