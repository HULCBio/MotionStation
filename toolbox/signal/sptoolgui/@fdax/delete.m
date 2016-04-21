function delete(obj)

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

obj = struct(obj);
for i = 1:length(obj)
    fig = get(obj(i).h,'parent');
    ud = get(fig,'userdata');
    
    ind = find(obj(i).h == [ud.Objects.fdax.h]);
    if isempty(ind)
        error('Not a valid object')
    end
        
    objud = get(obj(i).h,'userdata');
    
    % need to delete any lines which are children of this axes
    lines = ud.Objects.fdline(:).h;
    if length(lines)>1
        lines = [lines{:}];
    end
    for j = 1:length(lines)
        if get(lines(j),'parent') == obj(i).h
            delete(ud.Objects.fdline(j))
        end
    end
    ud = get(fig,'userdata');
    
    delete(obj(i).h)
    
    ud.Objects.fdax(ind) = [];
    
    set(fig,'userdata',ud)
    
    % now adjust enable of ud.ht.overlay button of filtdes:
    if length(ud.Objects.fdax)>0
        allAxes = [ud.Objects.fdax.h];
        enable = 'off';
        for k = 1:length(allAxes)
            tempud = get(allAxes(k),'userdata');
            if strcmp(tempud.overlay,'on')
                enable = 'on';
                break
            end
        end
    else
        enable = 'off';
    end
    set(ud.toolbar.overlay,'enable',enable)
end
if ~isempty(obj)
    setpos(ud.Objects.fdax,fig)
end

