function [board, boardType, devName, maskdisplay, maskdescription]= mdiuei(boardtype, channel, pciSlot)

maskType= get_param(gcb,'MaskType');
index= find(maskType=='_');
maskType= maskType(4:index(1)-1);

[maskdisplay, description, devName, boardType, maxADChannel, maxDAChannel, maxDIChannel, maxDOChannel gains]= mgetueidevice(maskType, boardtype);

maskdisplay=[maskdisplay,'Digital Input'');'];
for i=1:length(channel)
	maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(channel(i)),''');'];
end
maskdescription=[description,10,'United Electronic Industries',10,'Digital Input'];

board= get_param(gcb, 'UserData');
if isempty(board)
    board=0;
end

% check parameters
% channel


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/09 19:42:59 $
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
% check for channel elements smaller than 1 or greater than maxDIChannel
if ~isempty(find(channel<1)) | ~isempty(find(channel>maxDIChannel))
  error(['Channel Vector elements must be in the range 1..',num2str(maxDIChannel)]);
end

















	
	
	
	
	
	
	

	
  

  
  
  




