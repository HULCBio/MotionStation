function [board, boardType, devName, gain, gainVal, mux, maskdisplay, maskdescription]= madueipd2mfx(boardtype, channel, gain, mux, pciSlot)

maskType= get_param(gcb,'MaskType');
index= find(maskType=='_');
maskType= maskType(4:index(1)-1);

[maskdisplay, description, devName, boardType, maxADChannel, maxDAChannel, maxDIChannel, maxDOChannel gains]= mgetueidevice(maskType, boardtype);

maskdisplay=[maskdisplay,'Analog Input'');'];
for i=1:length(channel)
	maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
end
maskdescription=[description,10,'United Electronic Industries',10,'Analog Input'];

board= get_param(gcb, 'UserData');
if isempty(board)
    board=0;
end

% check parameters
% channel


%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2004/04/08 21:02:43 $
if isempty(channel)
  error('Channel vector parameter cannot be empty');
end
if ~isa(channel,'double')
  error('Channel vector parameter must be of class double');
end
if size(channel,1)>1
  error('Channel vector parameter must be a row vector');
end
% round channel vector
channel= round(channel);
% check for channel elements smaller than 1 or greater than maxADChannel
if ~isempty(find(channel<1)) | ~isempty(find(channel>maxADChannel))
  error(['Channel Vector elements must be in the range 1..',num2str(maxADChannel)]);
end
% gain
if isempty(gain)
  error('Gain vector parameter cannot be empty');
end
if ~isa(gain,'double')
  error('Gain vector parameter must be of class double');
end
% if the parameter is a scalar, apply scalar expansion
if size(gain,1)==1 & size(gain,2)==1
  gain= gain * ones(1,length(channel));
end
if size(gain,1)>1
  error('Gain vector parameter must either be a scalar (scalar expansion applies) or a row vector');
end
if length(gain)~=length(channel)
  error('Gain vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
end
% round gain vector
gain= round(gain);
% check for gain elements
index= find(ismember(gain,gains)==0); 
if ~isempty(index)
  error(['Gain Vector elements must be either ',createGainString(gains)]);
end
gainVal= gain;
for i=1:length(gainVal)
    gain(i)=find(gains==gain(i))-1;
end
% mux
if isempty(mux)
  error('Mux vector parameter cannot be empty');
end
if ~isa(mux,'double')
  error('Mux vector parameter must be of class double');
end
% if the parameter is a scalar, apply scalar expansion
if size(mux,1)==1 & size(mux,2)==1
  mux= mux * ones(1,length(channel));
end
if size(mux,1)>1
  error('Mux vector parameter must either be a scalar (scalar expansion applies) or a row vector');
end
if length(mux)~=length(channel)
  error('Mux vector parameter must either be a scalar (scalar expansion applies) or a row vector with the same number of elements than the Channel Vector parameter');
end
% round mux vector
mux= round(mux);
% check for mux elements smaller than 0 or greater than 1
if ~isempty(find(mux<0)) | ~isempty(find(mux>1))
  error('Mux vector elements must be either 0 (fast) or 1 (slow)');
end

function gainString=createGainString(gains)
gainString=[];
for i=1:length(gains)-1
    gainString=[gainString,[num2str(gains(i)),', ']];
end
gainString=[gainString,['or ',num2str(gains(end))]];

























	
	
	
	
	
	
	

	
  

  
  
  




