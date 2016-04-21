function display(obj)
%DISPLAY Display a FITTYPE.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:32 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

objectname = inputname(1);
if isempty(objectname)
   objectname = 'ans';
end

[line1,line2] = makedisplay(obj,objectname);

if (isLoose)
   fprintf('\n');
end
fprintf('%s\n', line1);
if (isLoose)
   fprintf('\n');
end
fprintf('     %s\n', line2);
if (isLoose)
   fprintf('\n');
end

