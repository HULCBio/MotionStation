function display(d)
%DISPLAY Database Toolbox objects display method.

%   Author(s): C.F.Garvin, 10-30-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $   $Date: 2004/04/06 01:05:28 $

%Trap current last error
[lastmsg,lastid] = lasterr;

tmp = struct(d);   %Extract the structure for display

if ~strcmp(class(d),'dbtbx')  %dbtbx field is a dummy field used for
  tmp = rmfield(tmp,'dbtbx'); %inheritance only, do not display it
end

%Database connection and cursor objects have properties in displayed information
if any(strcmp(class(d),{'database','cursor'}))
  flds = fieldnames(tmp);
  for i = 1:length(flds)
    try
      eval(['newtmp.' flds{i} ' = get(d,flds{i});'])
    catch
      eval(['newtmp.' flds{i} ' = tmp.' flds{i} ';'])
    end
  end
  
  tmp = newtmp;
  
end

if isequal(get(0,'FormatSpacing'),'compact')  %Display based on formatting
  disp([inputname(1) ' =']);
  disp(tmp)
else
  disp(' ')
  disp([inputname(1) ' =']);
  disp(' ')
  disp(tmp)
end

%Reset lasterr
lasterr(lastmsg,lastid);