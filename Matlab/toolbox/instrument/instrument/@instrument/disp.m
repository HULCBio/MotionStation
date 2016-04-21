function disp(obj)
%DISP Display method for instrument objects.
%
%   DISP(OBJ) dynamically displays information pertaining to 
%   instrument object, OBJ.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.4 $  $Date: 2004/01/16 20:00:51 $

% The object display is based on the number of objects
% in the array.
try
	jobject = igetfield(obj, 'jobject');
catch
	builtin('display', obj);
	return;
end

switch (length(jobject))
case 1
   % Single object display.
   fprintf(char(display(jobject)));
otherwise
   % Multiple object display.
   localArrayDisplay(obj);
end

% **********************************************************************
% Create the display for an array of objects.
function localArrayDisplay(obj)

% Create the index.
dispLength = length(obj);
index = num2cell(1:dispLength);

% Initialize variables.
typeValues   = cell(dispLength,1);
statusValues = cell(dispLength,1);
nameValues   = cell(dispLength,1);

% Get all the values for the display.
jobj = igetfield(obj, 'jobject');
for i = 1:dispLength
    if isvalid(jobj(i))
		typeValues{i}   = get(jobj(i), 'Type');
		statusValues{i} = get(jobj(i), 'Status');
		nameValues{i}   = get(jobj(i), 'Name');
    else
        typeValues{i}   = char(jobj(i).getType);
        statusValues{i} = 'Invalid';
        nameValues{i}   = 'Invalid';
    end
end

% Calculate spacing information.
typeLength   = max(cellfun('length', typeValues));
statusLength = max(cellfun('length', statusValues));
nameLength   = max(cellfun('length', nameValues));
maxSpacing   = 4;

% Write out the header.
fprintf('\n');
fprintf([blanks(3) 'Instrument Object Array\n\n']);
fprintf([blanks(3) 'Index:' blanks(maxSpacing) 'Type:' blanks(maxSpacing + typeLength-5)...
        'Status:' blanks(maxSpacing+statusLength-7) 'Name:  \n']);

% Write out the property values.
for i = 1:dispLength
   fprintf([blanks(3) num2str(index{i})...
         blanks(6 + maxSpacing - length(num2str(index{i}))) typeValues{i}...
         blanks(typeLength + maxSpacing - length(typeValues{i})) statusValues{i}...   
         blanks(statusLength + maxSpacing - length(statusValues{i})) num2str(nameValues{i})...
         '\n']);
end	

fprintf('\n');

