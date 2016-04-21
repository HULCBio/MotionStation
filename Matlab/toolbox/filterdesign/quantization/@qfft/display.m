function display(F)
%DISPLAY   Default display of QFFT object.
%   DISPLAY(F) displays a QFFT object in the same way as leaving off the
%   semicolon. 
%
%   See also QFFT.

%   Thomas A. Bryan, 24 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:26:55 $

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
disp(F);
