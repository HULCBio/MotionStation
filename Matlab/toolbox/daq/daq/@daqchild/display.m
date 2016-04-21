function display(obj)
%DISPLAY Compact display method for data acquisition objects.
%
%    DISPLAY(OBJ) calls OBJ's DISP method.
%

%    CP 4-13-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:40:15 $

isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

fprintf(newline);
disp(obj)