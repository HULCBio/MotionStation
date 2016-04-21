function [reset, initValue] = mdacbpcidas(flag, channel, range, ref, boardType, reset, initValue)

% MDACBPCIDAS - InitFcn and Mask Initialization for CB PCI-DAS series D/A section

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.7 $ $Date: 2002/03/30 16:23:52 $

persistent pool

if flag==1
   pool=[];
end

if flag==2
   
   maxChannel=2;   

   switch boardType
   case 1   
      maskdisplay='disp(''PCI-DAS1200\nComputerBoards\n';
      description='PCI-DAS1200';
      supRange=[-10, -5, 10, 5];
      supRangeStr='-10, -5, 10, 5';
   end
   
   maskdisplay=[maskdisplay,'Analog Output'');'];
   for i=1:length(channel)
    maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
   end         
   set_param(gcb,'MaskDisplay',maskdisplay);
   
   maskdescription=[description,10,'ComputerBoards',10,'Analog Output'];
    set_param(gcb,'MaskDescription',maskdescription);
   
        
   boardtype=['btype',num2str(boardType)];
   boardref='ref';
   if ref>=0
      boardref=[boardref,num2str(ref)];
   end
     
   if ~isfield(pool,boardtype)
      eval(['pool.',boardtype,'=[];']);
   else
      error('only one block per physical board allowed');
   end
   level1=getfield(pool,boardtype);
   if ~isfield(level1,boardref)
      eval(['level1.',boardref,'.chUsed=zeros(1,64);']);
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
    pool=setfield(pool,boardtype,level1);


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
