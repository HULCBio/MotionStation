function mrtddm6604(flag, channel, range, ref)

% MRTDDN6604 - InitFcn and Mask Initialization for Real Time Devices DM6604 D/A board 

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 03:58:33 $


persistent rtddm6604 

if flag==1
   rtddm6604=[];
end

if flag==2
       
	maskdisplay='disp(''DM6604\nRTD\nAnalog Output'');';
   	for i=1:length(channel)
      	maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
   	end   
   	set_param(gcb,'MaskDisplay',maskdisplay);
      
   	if length(channel)~=length(range)
      	error('channel vector and range vector must have the same number of elements');      
      end
      
   
   boardref='ref';    
   boardref=[boardref,num2str(ref)];
   
   if ~isfield(rtddm6604,boardref)
      eval(['rtddm6604.',boardref,'.daChUsed=zeros(1,8);']);
   else
      error('only one block per physical board supported');
   end
   tmp=getfield(rtddm6604,boardref);
   
   maxDAChannels=8;
   
  	for i=1:length(channel)
   	schannel=channel(i);
      srange=range(i);
      if schannel>maxDAChannels
        	error(['channel number cannot be greater than ',num2str(maxADChannels)]);
      end
      if tmp.daChUsed(schannel)
        	error(['channel ',num2str(schannel),' already in use']);
      end
      tmp.daChUsed(schannel)=1;
      if srange~=-10 & srange~=-5 & srange~=10 & srange~=5
        	error('range values can only be -10, -5, 10 and 5');
      end
   end
      
      
   rtddm6604=setfield(rtddm6604,boardref,tmp);

end



   