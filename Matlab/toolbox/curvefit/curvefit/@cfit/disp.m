function disp(obj)
%DISP   DISP for CFIT object.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:39:08 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

objectname = inputname(1);
if isempty(objectname)
   objectname = 'ans';
end

[line1,line2,line3,line4] = makedisplay(obj,objectname);

if (isLoose)
   fprintf('\n');
end
fprintf('     %s\n', line2);
fprintf('     %s\n', line3);
if ~isempty(line4), fprintf('     %s\n', line4); end
if (isLoose)
   fprintf('\n');
end

