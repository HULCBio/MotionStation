function disp(obj)
%DISP Display method for data acquisition objects.
%
%    DISP(OBJ) dynamically displays information pertaining to data
%    acquisition object OBJ.
%

%    CP 5-18-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:40:14 $

% Use the default display for a daqchild object.
if strcmp(class(obj), 'daqchild');
   builtin('disp', obj);
   return
end

% If all the channels or lines are invalid, create the property listing
% and then loop through the number of channels or lines and display
% a message that the channel or line is invalid.  Otherwise call 
% childdisp.
if (sum(~isvalid(obj)) == length(obj))
   if strcmp(class(obj),'aichannel')
      fprintf('   Index:   ChannelName:   HwChannel:   InputRange:   SensorRange:   UnitsRange:   Units:\n');
      child = 'Channel';
   elseif strcmp(class(obj), 'aochannel')  
      fprintf('   Index:   ChannelName:   HwChannel:   OutputRange:   UnitsRange:   Units:\n');
      child = 'Channel';
   elseif strcmp(class(obj), 'dioline')
      fprintf('   Index:   LineName:   HwLine:   Port:   Direction: \n');
      child = 'Line';
   end
   
   for i = 1:length(obj)
      fprintf('   Element #%d is an invalid %s.\n',i,child);
   end
   fprintf('\n');
else
   daqgate('childdisp',obj);
end