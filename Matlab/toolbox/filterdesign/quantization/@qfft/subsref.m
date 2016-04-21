function v = subsref(obj,s)
%SUBSREF Subscripted reference for QFFT object.

%   Thomas A. Bryan, 6 October 1999.  Based on work by T. Krauss. 
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/14 15:26:04 $

if strcmp(s(1).type,'()')
    obj = get(obj);
    obj = obj(s(1).subs{:});    
    obj = qfft(obj);
    s(1) = [];
end

if isempty(s)
    v = obj;
    return
end

switch s(1).type
case {'()','{}'}
    error('Invalid subscript.')  
case '.'
    v = get(obj,s(1).subs);
end

if length(s)>1
    % subsref into v
    v = mysubsref(v,s(2:end));

end


function v = mysubsref(v,s)

for i=1:length(s)
  switch s(i).type
    case '()'
      v = v(s(i).subs{:});
    case '{}'
      v = {v{s(i).subs{:}}};
      if length(v)==1
        v = v{1};
      end
    case '.'
      % Second dot.  Must be another object.
      v = get(v,s(i).subs);
  end
end
