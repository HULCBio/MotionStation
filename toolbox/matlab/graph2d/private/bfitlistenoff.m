function bfitlistenoff(fig)
% BFITLISTENOFF Disable listeners for Basic Fitting GUI. 

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/29 03:39:48 $

if ~isempty(findprop(handle(fig), 'bfit_FigureListeners'))
    listeners = get(handle(fig), 'bfit_FigureListeners');
    set(listeners.childadd,'Enabled','off');
    set(listeners.childremove,'Enabled','off');
    set(listeners.figdelete,'Enabled','off');
end

lineL = findobj(fig, 'type', 'line');
for i = lineL'
    if ~isempty(findprop(handle(i), 'bfit_CurveListeners'))
	listeners = get(handle(i), 'bfit_CurveListeners');
        set(listeners.tagchanged,'Enabled','off');
    end
    if ~isempty(findprop(handle(i), 'bfit_CurveDisplayNameListeners'))
	listeners = get(handle(i), 'bfit_CurveDisplayNameListeners');
        set(listeners.displaynamechanged,'Enabled','off');
    end
end

axesL = findobj(fig, 'type', 'axes');
for i = axesL'
    if ~isempty(findprop(handle(i), 'bfit_AxesListeners'))
        listeners = get(handle(i), 'bfit_AxesListeners');
        if isequal(get(i,'tag'),'legend')
            set(listeners.userDataChanged,'Enabled','off');
        else
            set(listeners.lineAdded,'Enabled','off');
            set(listeners.lineRemoved,'Enabled','off');
        end
    end
end

