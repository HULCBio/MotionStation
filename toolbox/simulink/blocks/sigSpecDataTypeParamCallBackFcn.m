function sigSpecDataTypeParamCallBackFcn
% sigSpecDataTypeParamCallBackFcn : Callback function for the data type
% dialog parameter in the Signal Specification block.


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2002/09/23 16:27:29 $
  
  
% If Data Type is set to Specify via dialog then turn the 
% mask visibilities of Output data type and Output scaling on.  

LocalDataType = get_param(gcb,'DataType');

if strcmp(LocalDataType,'Specify via dialog')
  set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on','on'});
else
  set_param(gcb,'MaskVisibilities',{'on','on','on','off','off','on','on'});
end
