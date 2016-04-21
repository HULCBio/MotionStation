function ans = subsref(obj,s)
%SUBSREF Method for fdmeas object

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

if strcmp(s(1).type,'()')
    obj = struct(obj);
    obj = obj(s(1).subs{:});    
    obj = fdmeas(obj);
    s(1) = [];
end

if isempty(s)
    ans = obj;
    return
end

switch s(1).type
case {'()','{}'}
    error('Sorry, I don''t understand this construct.')  
case '.'
    ans = get(obj,s(1).subs);
end

if length(s)>1
    % subsref into ans
    ans = mysubsref(ans,s(2:end));

end


function ans = mysubsref(ans,s)

for i=1:length(s)
    switch s(i).type
    case '()'
        ans = ans(s(i).subs{:});
    case '{}'
        ans = ans{s(i).subs{:}};
    case '.'
        ans = getfield(ans,s(i).subs);
    end
end