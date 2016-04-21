function display(obj)
%DISPLAY Compact display method for data acquisition objects.
%
%    DISPLAY(OBJ) calls OBJ's DISP method.
%

%    MP 12-22-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:41:09 $

isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

fprintf(newline);

if length(obj) ==1
   disp(obj)
else
   localMultiDisp(obj);
end

% ***********************************************************************
% Display method for device array objects.
function localMultiDisp(obj)

% Initialize variables.
dispLength = length(obj);
subsystem = cell(dispLength,1);
Name = cell(dispLength,1);
index = num2cell([1:dispLength]');

% Build up the necessary information - subsystem and device name.
for i = 1:dispLength
   structinfo = struct(obj);
   if ~daqmex('IsValidHandle', structinfo.handle(i))
      subsystem{i} = structinfo.info(i).objtype;
      Name{i} = 'Invalid';
   else
      subsystem{i} = daqmex(structinfo.handle(i), 'get', 'Type');
      Name{i} = daqmex(structinfo.handle(i), 'get', 'Name');
   end
end
totalStr = [index subsystem Name];

% Write out the index, subsystem and device name.
fprintf([blanks(3) 'Index:' blanks(4) 'Subsystem:' blanks(9) 'Name:\n']);

for i = 1:dispLength % number of objects.
   fprintf([blanks(3) num2str(totalStr{i,1})... 
      blanks(10-length(num2str(totalStr{i,1}))) totalStr{i,2}...
      blanks(19-length(totalStr{i,2})) totalStr{i,3}]);
   fprintf('\n');
end

fprintf('\n');
