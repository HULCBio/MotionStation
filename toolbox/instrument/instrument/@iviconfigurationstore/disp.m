function disp(obj)
%DISP Display method for IVI Configuration Store objects.
%
%   DISP(OBJ) dynamically displays information pertaining to 
%   IVI Configuration Store object, OBJ.
%

%   PE 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/03/05 18:10:18 $


if (length(obj) == 1)
  localDisplay(obj);
else
   localArrayDisplay(obj);
end

% **********************************************************************
% Create the display for an object.
function localDisplay(obj)

fprintf('\n   IVI Configuration Store Object\n');
   
fprintf('\n   Server\n');
fprintf('      Name:                 %s\n', obj.cobject.Name);
fprintf('      Vendor:               %s\n', obj.cobject.Vendor);
fprintf('      Revision:             %s\n', obj.cobject.Revision);
fprintf('      SpecificationVersion: %d.%d\n', obj.cobject.SpecificationMajorVersion, ...
    obj.cobject.SpecificationMinorVersion);

fprintf('\n   Configuration Store\n');
fprintf('      MasterLocation:       %s\n', obj.cobject.MasterLocation);
fprintf('      ProcessLocation:      %s\n', obj.cobject.ProcessDefaultLocation);
fprintf('      ActualLocation:       %s\n', obj.cobject.ActualLocation);
fprintf('\n');

% **********************************************************************
% Create the display for an array of objects.
function localArrayDisplay(obj)

% Create the index.
dispLength = length(obj);
index = num2cell(1:dispLength);

% Initialize variables.
locationValues   = cell(dispLength,1);

% Get all the values for the display.
for i = 1:dispLength
    locationValues{i} = get(obj(i), 'ActualLocation');
end

% Calculate spacing information.
locationLength   = max(cellfun('length', locationValues));
maxSpacing   = 4;

% Write out the header.
fprintf('\n');
fprintf([blanks(3) 'IVI Configuation Store Object Array\n\n']);
fprintf([blanks(3) 'Index:' blanks(maxSpacing) 'Actual Location:  \n']);

% Write out the property values.
for i = 1:dispLength
   fprintf([blanks(3) num2str(index{i})...
         blanks(6 + maxSpacing - length(num2str(index{i}))) '%s'...
         '\n'], locationValues{i});
end	

fprintf('\n');