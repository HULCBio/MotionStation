function delete(obj)

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

obj = struct(obj);
for i = 1:length(obj)
    fig = get(obj(i).h,'parent');
    ud = get(fig,'userdata');
    
    ind = find(obj(i).h == [ud.Objects.fdspec.h]);
    if isempty(ind)
        error('Not a valid object')
    end
        
    objud = get(obj(i).h,'userdata');
    
    delete(objud.hlabel)
    delete(obj(i).h)
    
    ud.Objects.fdspec(ind) = [];
    
    set(fig,'userdata',ud)
end

