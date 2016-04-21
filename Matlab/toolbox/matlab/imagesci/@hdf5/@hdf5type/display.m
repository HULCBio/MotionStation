function dummy = display(hObj)
%DISPLAY Display method for an hdf5.hdf5type object

%   Copyright 1984-2002 The MathWorks, Inc.

% Use inputname when UDD works with it:
%    name = inputname(1);
%    if isempty(name)
%        name = 'ans';
%    end

isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

fprintf(newline);
disp(hObj);
fprintf(newline)
