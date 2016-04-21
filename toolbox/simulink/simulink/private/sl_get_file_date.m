function y = sl_get_file_date(file)
% get date of the file. return [] if the file does not exist
  
% Copyright 2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $
  d = dir(file);
  if isempty(d)
    y = [];
  else
    y = d.date;
  end
  
%endfunction
