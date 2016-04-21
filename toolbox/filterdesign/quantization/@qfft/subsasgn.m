function obj = subsasgn(obj,s,rhs);
%SUBSASGN  Subscripted assignment for QFFT object.

%   Thomas A. Bryan, 6 October 1999.  
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:26:07 $

if strcmp(s(1).type,'()') & s(1).subs{1}==1
  % To allow obj(1)...
  s(1)=[];
end

h = get(obj);
for k=1:length(s)
  switch s(k).type
    case '.'
      [field,msg] = qpropertymatch(s(k).subs,fieldnames(h));
      if isempty(msg)
        s(k).subs = field;
      else
        obj = set(obj,s(k).subs,rhs);
        s(k) = [];
      end
    case '{}'
      [subs{1:k-1}] = deal(s(1:k-1).subs);
      v = getfield(h,subs{:});
      % Value should be a cell array.  Now I need to keep indexing into this
      % cell array.
      v{s(k).subs{:}} = cellindex(v{s(k).subs{:}},s(k:end),rhs);
      h = setfield(h,subs{:},v);
      obj = set(obj,h);
      return
  end
end
if ~isempty(s)
  [subs{1:length(s)}] = deal(s(:).subs);
  h = setfield(h,subs{:},rhs);
  obj = set(obj,h);
end


function v = cellindex(v,s,rhs)
if length(s)==1
  v = rhs;
else
  for k=2:length(s)
    switch s(k).type
      case '()'
        v(s(k).subs{:}) = rhs;
      case '{}'
        v{s(k).subs{:}} = cellindex(v{s(k).subs{:}},s(k:end),rhs);
        return
    end
  end
end
  
