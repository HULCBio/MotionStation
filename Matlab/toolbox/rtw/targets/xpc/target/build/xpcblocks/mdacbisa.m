function [reset, initValue] = mdacbisa(flag, channel, range, reset, initValue, ref, boardType)

% MDACBISA - InitFcn and Mask Initialization for ComputerBoards ISA D/A sections or boards 

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/03/30 16:23:50 $


persistent dacbisa

if flag==1
   dacbisa=[];
end

if flag==2
   
   switch boardType
   case 1	
      maskdisplay='disp(''CIO-DDA06\nComputerBoards\n';
      description='CIO-DDA06';
      maxChannel=6;
      supRange=[-10,-5,-2.5,-1.67, 10, 5, 2.5, 1.67];
      supRangeStr='-10, -5, -2.5, -1.67, 10, 5, 2.5, 1.67';
   case 2
      maskdisplay='disp(''CIO-DAC08\nComputerBoards\n';
      description='CIO-DAC08';
      maxChannel=8;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 3
      maskdisplay='disp(''CIO-DAC16\nComputerBoards\n';
      description='CIO-DAC16';
      maxChannel=16;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 4
      maskdisplay='disp(''CIO-DDA06/16\nComputerBoards\n';
      description='CIO-DDA06/16';
      maxChannel=6;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 5	
      maskdisplay='disp(''CIO-DAC08/16\nComputerBoards\n';
      description='CIO-DAC08/16';
      maxChannel=8;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 6
      maskdisplay='disp(''CIO-DAC16/16\nComputerBoards\n';
      description='CIO-DAC16/16';
      maxChannel=16;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
  	case 7
      maskdisplay='disp(''PC104-DAC06\nComputerBoards\n';
      description='PC104-DAC06';
      maxChannel=6;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 8
      maskdisplay='disp(''CIO-DAS1601/12\nComputerBoards\n';
      description='CIO-DAS1601/12';
      maxChannel=2;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 9
      maskdisplay='disp(''CIO-DAS1602/12\nComputerBoards\n';
      description='CIO-DAS1602/12';
      maxChannel=2;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 10
      maskdisplay='disp(''CIO-DAS1602/16\nComputerBoards\n';
      description='CIO-DAS1602/16';
      maxChannel=2;
      supRange=[-10,-5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   case 11
      maskdisplay='disp(''AT-AO-6\nNational Instr.\n';
      description='AT-AO-6';
      maxChannel=6;
      supRange=[-10, 10];
      supRangeStr='-10, 10';
   case 12
      maskdisplay='disp(''AT-AO-10\nNational Instr.\n';
      description='AT-AO-10';
      maxChannel=10;
      supRange=[-10, 10];
      supRangeStr='-10, 10';
   end
   
   
   maskdisplay=[maskdisplay,'Analog Output'');'];
   for i=1:length(channel)
   	maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
   end         
   set_param(gcb,'MaskDisplay',maskdisplay);
   
   	if boardType < 11
  		maskdescription=[description,10,'ComputerBoards',10,'Analog Output'];
	else
	  maskdescription=[description,10,'National Instr.',10,'Analog Output'];
	end	
  	set_param(gcb,'MaskDescription',maskdescription);
   
        
   boardtype=['btype',num2str(boardType)];
   boardref='ref';
   if ref>=0
      boardref=[boardref,num2str(ref)];
   end
     
   if ~isfield(dacbisa,boardtype)
      eval(['dacbisa.',boardtype,'=[];']);
   end
   level1=getfield(dacbisa,boardtype);
   if ~isfield(level1,boardref)
      eval(['level1.',boardref,'.chUsed=zeros(1,16);']);
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
  	dacbisa=setfield(dacbisa,boardtype,level1);

    %%% check reset vector parameter
    if ~isa(reset, 'double')
      error('Reset vector parameter must be of class double');
    end
    if size(reset) == [1 1]
      reset = reset * ones(size(channel));
    elseif ~all(size(reset) == size(channel))
      error('Reset vector must be a scalar or have the same number of elements as the Channel vector');
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
      error('Initial value vectorvmust be a scalar or have the same number of elements as the Channel vector');
    end

end



   