function libfunctionsview(qcls)
%LIBFUNCTIONSVIEW View the functions in an external library.
%   LIBFUNCTIONSVIEW(LIBNAME) displays the names of the functions 
%   in the external shared library, LIBNAME, that has been loaded 
%   into MATLAB with the LOADLIBRARY function.
%
%   MATLAB creates a new window in response to the LIBFUNCTIONSVIEW
%   command. This window displays all of the functions defined in 
%   the specified library. For each of these functions, the following 
%   information is supplied:
%
%     - Data type returned by the function
%     - Name of the function
%     - Arguments passed to the function
%
%   An additional column entitled "Inherited From" is displayed at
%   the far right of the window. The information in this column is 
%   not useful for external libraries.
%
%   See also LIBFUNCTIONS, CALLLIB, LOADLIBRARY, UNLOADLIBRARY.

%   Copyright 2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2004/01/02 18:03:35 $

if (nargin < 1)
  error('MATLAB:LIBFUNCTIONSVIEW:NumberOfInputArguments','Not enough input arguments.');
end
notChar = ~ischar(qcls);

% Make sure input is a string or object (MATLAB or opaque).
if notChar  && ~isa(qcls,'opaque') || (size(qcls,1) > 1)
  error('MATLAB:LIBFUNCTIONSVIEW:InputType','Input must be a string or object.');
end

% If input is an object, then get the class.
if notChar
  qcls = class(qcls);
else  
  qcls=['lib.' qcls];
end

libname=strrep(qcls,'lib.','');

[m,d] = methods(qcls,'-full');

if size(m,1) == 0
  error('MATLAB:LIBFUNCTIONSVIEW:LibraryName', ...
         ['No library ' libname ' can be located or no functions for library ' libname]);
end;

import com.mathworks.mwt.*
dflag = 1;
ncols = 3;

r = size(m,1);

d = d(:,[2 3 5]);
[y,x] = sort(d(:,2));
cls = '';
clss = 0;

w = cell(1,ncols);
for i=1:ncols,
    w{i} = 0;
end;

if isempty(cls),
  cls = qcls;
  clss = length(cls);
end;

datacol = zeros(1,ncols);

for i=1:r,
  for j=1:ncols
    if ~isempty(d{i,j}),
      datacol(j) = 1;
      w{j} = max(w{j},length(d{i,j}));
    end;
  end;
end;

ndatacol = sum(datacol);

f = MWFrame(['Functions in library ' libname]);
dz = f.getToolkit.getScreenSize;
b = MWListbox;
b.setColumnCount(ndatacol);
wb = 0;
ch = {};
hdrs = { 'Return Type', 'Name', 'Arguments'};

for i=ncols:-1:1,
  if datacol(i),
    datacol(i) = sum(datacol(1:i));
    ch{datacol(i)} = hdrs{i};
  end;
end;

for i=1:ncols,
    if datacol(i),
      wc = 7.5*max([length(ch{datacol(i)}),w{i}]);
      b.setColumnWidth(datacol(i)-1,wc);
      b.setColumnHeaderData(datacol(i)-1,ch{datacol(i)});
      wb = wb+wc;
      end;
end;

co = b.getColumnOptions;
set(co, 'HeaderVisible', 'on');
set(co, 'Resizable', 'on');
b.setColumnOptions(co);

ds = javaArray('java.lang.String', ncols);

for i=1:r,
  for j=1:ncols,
    if datacol(j) && ~isempty(d{x(i),j})
      ds(datacol(j)) = java.lang.String(d{x(i),j});
    end;
  end;
  b.addItem(ds);
end;

b.setVisible(1);
f.add(b);
f.addWindowListener(window.MWWindowActivater(f));
f.setSize(min([dz.width-100,wb+45]),min([dz.height-100,2000,r*26]));
f.setVisible(1);
