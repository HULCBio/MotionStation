function [reset, initValue] = mdacbpcidda0x12(flag, channel, range, reset, initValue, ref, boardType)

% MDACBPCIDDA0x12 - InitFcn and Mask Initialization for D/A section of CB PCI-DDA0x/12 series boards

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/03/30 16:23:56 $

persistent dacbpcidda0x12 


if flag==1
   dacbpcidda0x12=[];
end

if flag==2
   
   switch boardType
   case 1
      maskdisplay='disp(''PCI-DDA02/12\nComputerBoards\nAnalog Output'');';
   case 2
      maskdisplay='disp(''PCI-DDA04/12\nComputerBoards\nAnalog Output'');';
   case 3
      maskdisplay='disp(''PCI-DDA08/12\nComputerBoards\nAnalog Output'');';
   case 4
      maskdisplay='disp(''PCI-DDA02/16\nComputerBoards\nAnalog Output'');';
   case 5
      maskdisplay='disp(''PCI-DDA04/16\nComputerBoards\nAnalog Output'');';
   case 6
      maskdisplay='disp(''PCI-DDA08/16\nComputerBoards\nAnalog Output'');';
   case 7
      maskdisplay='disp(''PCIM-DDA06/16\nComputerBoards\nAnalog Output'');';
   case 8
      maskdisplay='disp(''PCIM-DAS1602/16\nComputerBoards\nAnalog Output'');';
   end;
   for i=1:length(channel)
      maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
   end   
   set_param(gcb,'MaskDisplay',maskdisplay);
   
   chUsed=zeros(1,8);
      
   switch boardType
   case 1
      maxChannels=2;
   case 2
      maxChannels=4;
   case 3
      maxChannels=8;
   case 4
      maxChannels=2;
   case 5
      maxChannels=4;
   case 6
      maxChannels=8;
   case 7
      maxChannels=6;
   case 8
      maxChannels=2;
   end

   
   if length(channel)~=length(range)
      error('channel vector and range vector must have the same number of elements');
      
   end
            
   for i=1:length(channel)
      schannel=channel(i);
      srange=range(i);
      if schannel>maxChannels
         error(['channel number cannot be greater than ',num2str(maxChannels)]);
      end
      if chUsed(schannel)
         error(['channel ',num2str(schannel),' already in use']);
      end
      chUsed(schannel)=1;
	  if boardType<7
      	if srange~=-10 & srange~=-5 & srange~=-2.5 & srange~=10 & srange~=5 & srange~=2.5
         	error('range values can only be -10, -5, -2.5, 10, 5 and 2.5');
      	end
	  else
		if srange~=-10 & srange~=-5 & srange~=10 & srange~=5 
         	error('range values can only be -10, -5, 10, and 5');
      	end
	  end
  end

   
   boardtype=['btype',num2str(boardType)];

   if ~isfield(dacbpcidda0x12,boardtype)
      eval(['dacbpcidda0x12.',boardtype,'=[];']);
   end
      
   boardref='ref';
   if length(ref)==2
	 ref=1000*ref(1)+ref(2);
   end
   if ref>0
      boardref=[boardref,num2str(ref)];
   end
   
   tmp=getfield(dacbpcidda0x12,boardtype);
   if ~isfield(tmp,boardref)
      eval(['tmp.',boardref,'.chUsed=zeros(1,8);']);
   else
      error('only one block per physical board allowed');
   end
   
   tmp1=getfield(tmp,boardref);
         
   tmp=setfield(tmp,boardref,tmp1);
   dacbpcidda0x12=setfield(dacbpcidda0x12,boardtype,tmp);

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
      error('Initial value must be a scalar or have the same number of elements as the Channel vector');
   end


end



   