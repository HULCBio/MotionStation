function [board, boardType, devName, reset, initValue, maskdisplay, maskdescription]= mdouei(boardtype, channel, reset, initValue, pciSlot)

maskType= get_param(gcb,'MaskType');
index= find(maskType=='_');
maskType= maskType(4:index(1)-1);

[maskdisplay, description, devName, boardType, maxADChannel, maxDAChannel, maxDIChannel, maxDOChannel gains]= mgetueidevice(maskType, boardtype);

maskdisplay=[maskdisplay,'Digital Output'');'];
for i=1:length(channel)
	maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(channel(i)),''');'];
end
maskdescription=[description,10,'United Electronic Industries',10,'Digital Output'];

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
% check for channel elements smaller than 1 or greater than maxDOChannel
if ~isempty(find(channel<1)) | ~isempty(find(channel>maxDOChannel))
  error(['Channel Vector elements must be in the range 1..',num2str(maxDOChannel)]);
end

% reset
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
if ~strcmp(maskType,'pd2ao16')
    if length(reset)==2
        if reset(1)~=reset(2)
            error('Reset vector must have the same value for each element');
        end
    end
end
               
%initValue
if ~isa(initValue, 'double')
    error('Initial value vector parameter must be of class double');
end
if size(initValue) == [1 1]
    initValue = initValue * ones(size(channel));
elseif ~all(size(initValue) == size(channel))
    error('Initial value must be a scalar or have the same number of elements as the Channel vector');
end
















	
	
	
	
	
	
	

	
  

  
  
  




