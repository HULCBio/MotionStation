function removeevent(h, eventname, eventhandler)
% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/19 01:13:50 $

%find out if property exist, if there are no events
% property should not exist
p = findprop(h, 'MMListeners_Events');
if (isempty(p))
    return
end

p.AccessFlags.Publicget = 'on';
p.AccessFlags.Publicset = 'on';

%dont proceed if no events are registered

list = h.MMListeners_Events;

[row,col] = size(list);
if(row == 0)
    return
end    

for i=1:row
    tempevent = list(i).EventType;
    tempcallback = list(i).Callback(2);

    if (strcmpi(eventname, tempevent))
        if (isa(eventhandler, 'function_handle') && isequal(eventhandler, tempcallback{1})) || ...
                (ischar(eventhandler) && strcmpi(eventhandler, tempcallback))

            list(i) = [];
            h.MMListeners_Events = list;
            %check the size, if 0, delete the property
            [row,col] = size(h.MMListeners_Events);
            if (row == 0)
                p = findprop(h, 'MMListeners_Events');
                if (~isempty(p))
                    delete(p);
                end
            else
                p.AccessFlags.Publicget = 'off';
                p.AccessFlags.Publicset = 'off';
            end

            return;
        end
    end
end

p.AccessFlags.Publicget = 'off';
p.AccessFlags.Publicset = 'off';

str = sprintf('Cannot unregister ''%s''. Invalid event name/handler combination', eventname);
warning(str);

