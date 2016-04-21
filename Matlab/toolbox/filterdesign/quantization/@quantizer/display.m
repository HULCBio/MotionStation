function display(q)
%DISPLAY   Default display of QUANTIZER object.
%   DISPLAY(Q) displays a quantizer object in the same way as leaving off the
%   semicolon.
%
%   See also QUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:35:15 $

name = inputname(1);
if isempty(name)
  name = 'ans';
end

isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

fprintf(newline);
disp([name, ' = ']);
fprintf(newline);
disp(q);
