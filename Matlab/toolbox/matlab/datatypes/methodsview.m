function methodsview(qcls)
%METHODSVIEW  View the methods for a class.
%   METHODSVIEW(CLASSNAME) displays the methods of a class along with
%   the properties of each method.
%
%   METHODSVIEW(OBJECT) displays the methods of OBJECT's class along
%   with the properties of each method.
%
%   METHODSVIEW is a visual representation of the information returned
%   by methods -full.
%
%   Examples
%     methodsview java.lang.Double;
%
%   See also METHODS, WHAT, WHICH, HELP.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/26 23:20:49 $

if (nargin < 1)
  error('MATLAB:methodsview:nargin', 'Not enough input arguments.');
end

notChar = ~ischar(qcls);

% Make sure input is a string or object (MATLAB or opaque).
if notChar && ~isobject(qcls) && ~isa(qcls,'opaque') || (size(qcls,1) > 1)
  error('MATLAB:methodsview:InvalidInput','Input must be a string or object.');
end

% If input is an object, then get the class.
if notChar
  qcls = class(qcls);
end
  
[m,d] = methods(qcls,'-full');
callers_import = evalin('caller','import');

if size(m,1) == 0 && ~isempty(callers_import),
  for i=1:size(callers_import, 1),
    cls = callers_import{i};
    if cls(end) == '*',
      cls = cls(1:end-1);
      cls = [cls qcls];
      [m,d] = methods(cls,'-full');
      if size(m,1) > 0,
        break;
      end;
    else
      scls = ['.' qcls];
      if size(cls,2) > size(scls,2) & strcmp(scls, cls(end-size(scls,2)+1:end)),
        [m,d] = methods(cls,'-full');
        if size(m,1) > 0,
          break;
        end
      end;
    end;
  end;
end;

if size(m,1) == 0,
  error(['No class ' qcls ' can be located or no methods for class ' qcls]);
end;

clear(mfilename);
import com.mathworks.mwt.* java.awt.*
dflag = 1;
ncols = 6;

if isempty(d),
  dflag = 0;
  d = cell(size(m,1), ncols);
  for i=1:size(m,1),
    t = max(find(m{i}=='%'));
    if ~isempty(t),
      d{i,3} = m{i}(1:t-2);
      d{i,6} = m{i}(t+17:end);
    else
      d{i,3} = m{i};
    end;
  end;
end;

scls = qcls(max(find(qcls=='.'))+1:end);

if isempty(scls),
  scls = qcls;
end;

r = size(m,1);
t = d(:,4);
d(:,4:ncols-1) = d(:,5:ncols);
d(:,ncols) = t;
[y,x] = sort(d(:,3));
cls = '';
clss = 0;

for i=1:ncols,
    w{i} = 0;
end;

for i=1:r,
  if isempty(cls) && ~isempty(d{i,6}),
    t = max(find(d{i,6}=='.'));
    if ~isempty(t),
      if strcmp(d{i,3},d{i,6}(t+1:end)),
	cls = d{i,6};
        clss = length(cls);
      end;
    end;
  end;
  for j=1:ncols
    if isnumeric(d{i,j}),
      d{i,j} = '';
    end;
    if j==4 && strcmp(d{i,j},'()'),
      d{i,j} = '( )';
    else
      if j==6,
        d{i,6} = deblank(d{i,6});
        if clss > 0 && strncmp(d{i,6},cls,clss) &&...
             (length(d{i,6}) == clss ||...
               (length(d{i,6}) > clss && d{i,6}(clss+1) == '.')),
          d{i,6} = '';
        else
	  if ~isempty(d{i,6}),
            t = max(find(d{i,6}=='.'));
            if ~isempty(t),
	      d{i,6} = d{i,6}(1:t-1);
            end;
          end
        end;
      end;
    end;
  end;
end;

if ~dflag,
  for i=1:r,
    d{i,6} = d{i,5};
    d{i,5} = '';
  end;
end;

if isempty(cls),
  cls = qcls;
  clss = length(cls);
end;

for i=1:ncols
  datacol(i) = 0;
end;

for i=1:r,
  for j=1:ncols
    if ~isempty(d{i,j}),
      datacol(j) = 1;
      w{j} = max(w{j},length(d{i,j}));
    end;
  end;
end;

ndatacol = sum(datacol);

f = MWFrame(['Methods of class ' cls]);
dz = f.getToolkit.getScreenSize;
b = MWListbox;
b.setColumnCount(ndatacol);
wb = 0;
ch = {};
hdrs = {'Qualifiers', 'Return Type', 'Name', 'Arguments', 'Other', 'Inherited From'};

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
    if datacol(j),
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
