function mvsbc6(flag, arg1, arg2, ref, ioType)

% MVSBC6 - InitFcn and Mask Initialization for Versalogic VSBC-6  I/O-sections 

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 03:58:42 $

persistent vsbc6 

if flag==1
   vsbc6 =[];
end

if flag==2
   
   if ioType==1
      
      channel=arg1;
      range=arg2;
   
   	maskdisplay='disp(''VSBC-6\nVersalogic\nAnalog Input'');';
   	for i=1:length(channel)
      	maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
   	end   
   	set_param(gcb,'MaskDisplay',maskdisplay);
      
   	if length(channel)~=length(range)
      	error('channel vector and range vector must have the same number of elements');      
      end
      
   elseif ioType==3
      
      enable=arg1;
      reset=arg2;
      
      maskdisplay='disp(''VSBC-6\nVersalogic\nWatchdog'');';
      if enable
         maskdisplay=[maskdisplay,'port_label(''input'',1,''E'');'];
         if reset
            maskdisplay=[maskdisplay,'port_label(''input'',2,''R'');'];
         end
      else
         if reset
            maskdisplay=[maskdisplay,'port_label(''input'',1,''R'');'];
         end
      end
      
      set_param(gcb,'MaskDisplay',maskdisplay);
      
  	elseif ioType==4
        
      dioChannel=arg1;
   
   	maskdisplay='disp(''VSBC-6\nVersalogic\nDigital Input'');';
   	for i=1:length(dioChannel)
      	maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(dioChannel(i)),''');'];
   	end   
      set_param(gcb,'MaskDisplay',maskdisplay);
      
  	elseif ioType==5
        
      dioChannel=arg1;
   
   	maskdisplay='disp(''VSBC-6\nVersalogic\nDigital Output'');';
   	for i=1:length(dioChannel)
      	maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(dioChannel(i)),''');'];
   	end   
   	set_param(gcb,'MaskDisplay',maskdisplay);

      
   end
   
   boardref='ref';    
   boardref=[boardref,num2str(ref)];
   
   if ~isfield(vsbc6,boardref)
      eval(['vsbc6.',boardref,'.adChUsed=zeros(1,8);']);
      eval(['vsbc6.',boardref,'.wdUsed=0;']);
      eval(['vsbc6.',boardref,'.dioChUsed=zeros(1,16);']);
      eval(['vsbc6.',boardref,'.dioLow=0;']);
      eval(['vsbc6.',boardref,'.dioHigh=0;']);      
   end
   tmp=getfield(vsbc6,boardref);
   
   
   if ioType==1	% ADC
      
      maxADChannels=8;
   
   	for i=1:length(channel)
      	schannel=channel(i);
      	srange=range(i);
      	if schannel>maxADChannels
         	error(['channel number cannot be greater than ',num2str(maxADChannels)]);
      	end
      	if tmp.adChUsed(schannel)
         	error(['channel ',num2str(schannel),' already in use']);
      	end
      	tmp.adChUsed(schannel)=1;
      	if srange~=-10 & srange~=-5 & srange~=10 & srange~=5
         	error('range values can only be -10, -5, 10 and 5');
      	end
      end
      
   elseif ioType==3	% Watchdog
      
      if (tmp.wdUsed)==1
         error('only one block per model allowed');
      else
         tmp.wdUsed=1;
      end
      
   elseif ioType==4	% Digital Input
      
      maxDIOChannels=16;
   	for i=1:length(dioChannel)
      	schannel=dioChannel(i);
      	if schannel>maxDIOChannels
         	error(['channel number cannot be greater than ',num2str(maxDIOChannels)]);
         end
      	if tmp.dioChUsed(schannel)
         	error(['channel ',num2str(schannel),' already in use']);
      	end
         tmp.dioChUsed(schannel)=1;
         if (schannel<9)
            if tmp.dioLow==0
               tmp.dioLow=1;
            else
               if tmp.dioLow==2
               	error('the lower channel group already has been defined as an output');
               end
            end
         else
         	if tmp.dioHigh==0
               tmp.dioHigh=1;
            else
               if tmp.dioHigh==2
               	error('the higher channel group already has been defined as an output');
               end
            end
         end         
      end
      
 	elseif ioType==5	% Digital Output
      
      maxDIOChannels=16;
   	for i=1:length(dioChannel)
      	schannel=dioChannel(i);
      	if schannel>maxDIOChannels
         	error(['channel number cannot be greater than ',num2str(maxDIOChannels)]);
         end
      	if tmp.dioChUsed(schannel)
         	error(['channel ',num2str(schannel),' already in use']);
      	end
         tmp.dioChUsed(schannel)=1;
         if (schannel<9)
            if tmp.dioLow==0
               tmp.dioLow=2;
            else
               if tmp.dioLow==1
               	error('the lower channel group already has been defined as an input');
               end
            end
         else
         	if tmp.dioHigh==0
               tmp.dioHigh=2;
            else
               if tmp.dioHigh==1
               	error('the higher channel group already has been defined as an input');
               end
            end
         end         
      end
      
   end
      
   vsbc6=setfield(vsbc6,boardref,tmp);

end



   