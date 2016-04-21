function childRemovedCbk(src, evd)

% Copyright 2003-2004 The MathWorks, Inc.

ch = evd.Child;
hgroup = src;

if (strcmpi(ch.type, 'uicontrol'))
    if (strcmpi(ch.style, 'radiobutton') || ...
            strcmpi(ch.style, 'togglebutton'))
        set(ch, 'callback', []);
        listeners = get(hgroup, 'Listeners');
        newlisteners = {};
        for i=1:length(listeners)
            if (ishandle(listeners{i}) == 1 && listeners{i}.Container == ch)
                delete(listeners{i});
            else
                newlisteners{end+1} = listeners{i};
            end
        end
        set(hgroup, 'Listeners', newlisteners);
    end
end
if (ch == get(src, 'SelectedObject'))
    set(hgroup, 'SelectedObject', []);
end
