function disp(obj)
%DISP Display method for device group objects.
%
%   DISP(OBJ) dynamically displays information pertaining to device
%   group object, OBJ. OBJ can be a device group object array.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:45 $

% The object display is based on the number of objects
% in the array.
try
	jobject = igetfield(obj, 'jobject');
catch
	builtin('display', obj);
	return;
end

localArrayDisplay(obj);

% **********************************************************************
% Create the display for an array of objects.
function localArrayDisplay(obj)

% Create the index.
dispLength = length(obj);

% Initialize variables.
hwIndexValues = cell(dispLength,1);
typeValues    = cell(dispLength,1);
nameValues    = cell(dispLength,1);
hwnameValues  = cell(dispLength,1);

% Get all the values for the display.
jobj = igetfield(obj, 'jobject');
for i = 1:dispLength
    if isvalid(jobj(i))
        hwIndexValues{i} = get(jobj(i), 'HwIndex');
		typeValues{i}    = get(jobj(i), 'Type');
  		nameValues{i}    = get(jobj(i), 'Name');
  		hwnameValues{i}  = get(jobj(i), 'HwName');
    else
        hwIndexValues{i} = get(jobj(i), 'HwIndex');
        typeValues{i}    = get(jobj(i), 'Type');
        nameValues{i}    = 'Invalid';
  		hwnameValues{i}  = get(jobj(i), 'HwName');
    end
end

% Calculate spacing information.
typeLength   = max(max(cellfun('length', typeValues)),   length('Type:'));
hwnameLength = max(max(cellfun('length', hwnameValues)), length('HwName:'));
nameLength   = max(max(cellfun('length', nameValues)),   length('Name:'));
maxSpacing   = 4;

% Write out the header.
fprintf('\n');
fprintf([blanks(3) 'HwIndex:' blanks(maxSpacing) ...
        'HwName:' blanks(maxSpacing + hwnameLength-7)...
        'Type:' blanks(maxSpacing + typeLength-5)...
        'Name:  \n']);

% Write out the property values.
for i = 1:dispLength
   fprintf([blanks(3) num2str(hwIndexValues{i})...
         blanks(8 + maxSpacing - length(num2str(hwIndexValues{i}))) hwnameValues{i}...   
         blanks(hwnameLength + maxSpacing - length(hwnameValues{i})) typeValues{i}...
         blanks(typeLength + maxSpacing - length(typeValues{i})) nameValues{i}...   
         '\n']);
end	

fprintf('\n');