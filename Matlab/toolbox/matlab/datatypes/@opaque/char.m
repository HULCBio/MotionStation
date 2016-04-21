function chr = char(opaque_array)
%CHAR Convert a Java object to CHAR

%   Chip Nylander, June 1998
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/06/17 13:17:43 $

%
% For opaque types other than those programmed here, just run the default
% builtin char function.
%
if ~isjava(opaque_array)
    chr = builtin('char', opaque_array);
    return;
end

%
% Convert opaque array to cell array to get the items in it.
%
err = 0;

try
  cel = cell(opaque_array);
catch
  err = 1;
end

if err
  chr = '';
  return;
end

%
% A java.lang.String object becomes a char array.
%
if isa(opaque_array,'java.lang.String')
  chr = cel{1};
  return;
end

%
% An empty Java array becomes an empty char array.
%
sz = builtin('size', cel);
psz = prod(sz);

if psz == 0
  try
    chr = reshape('',size(cel));
  catch
    chr = '';
  end
  return;
end;

%
% A java.lang.String array becomes a char array.
%
chr = cell(sz);

for i=1:psz
  chr{i} = '';
end

t = opaque_array(1);
c = class(t);

while ~isempty(findstr(c,'[]'))
  t = t(1);
  c = class(t);
end

if psz == 1 & ischar(t) & size(t,1) == 1
  chr = t;
  return;
end

if isa(t,'java.lang.String')
  chr = char(cel);
  return;
end

%
%
% Run toChar on each Java object in the MATLAB array.  This will error
% out if a toChar method is not available for the Java class of the object.
%
% A scalar array becomes a single char array.
%
if psz == 1
  if ~isjava(opaque_array(1))
    chr = builtin('char',opaque_array(1));
  else
    chr = toChar(opaque_array(1));
  end
else
  for i = 1:psz;
    if ~isjava(cel{i})
      chr{i} = builtin('char',cel{i});
    else
      chr{i} = toChar(cel{i});
    end;
  end;
end;

chr=char(chr);


