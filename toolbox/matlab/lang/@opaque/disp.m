function disp(opaque_array)
%DISP DISP for a Java object.

%   Chip Nylander, August 1999
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.22 $  $Date: 2002/04/15 04:14:19 $

%
% For opaque types other than those programmed here, just run the default
% builtin display function.
%
if ~isjava(opaque_array),
    builtin('disp', opaque_array);
    return;
end

%
% Check that there is a toString Java method for Java objects.
%
ts_error = 0;
eval('toString(opaque_array);', 'ts_error = 1;');

if (ts_error ~= 0)
  builtin('disp', opaque_array);
  return;
end;

cls = class(opaque_array);

if cls(end) ~= ']'
  desc = char(toString(opaque_array));
else
  disp([cls ':']);
  desc = cell(opaque_array);
end;

if ~ischar(desc) & ~iscell(desc)
  builtin('disp', opaque_array);
else
  name = evalin('caller','inputname(1);','[]');
  if  isempty(findstr(cls, '[][][]')) &...
      strncmp('java.lang.String[]',cls,length('java.lang.String[]')),
    disp(' ');
  end;
  if iscell(desc) & ~isempty(findstr(evalc('disp(desc)'), '{[]}')),
    desc = '    []';
  end;
  if iscell(desc),
    if ~isempty(name),
      eval([name '= desc;']);
    else,
      name = 'ans';
      ans = desc;
    end;
    desc = evalc(['builtin(''disp'',' name ')']);
    if isempty(desc),
        desc = ['    [0 element array]' 10 10];
    end;
    if strcmp(desc(1:5), '    {'),
        desc(1:5) = '    [';
    end;
    desc = strrep(desc, [10 '    {'], [10 '    [']);
    desc = strrep(desc, ['x1 cell}' 10], [' element array]' 10]);
    desc = strrep(desc, [' cell}' 10], [' array]' 10]);
    desc = strrep(desc, '[1x1 ', '[');
  end;
  if ~isempty(name),
    eval([name '= desc;']);
  else,
    name = 'ans';
    ans = desc;
  end;
  eval(['builtin(''disp'',' name ')'])
end;

if strcmp(get(0, 'FormatSpacing'), 'loose')
    disp(' ');
end;

