function bfitlistenon(fig)
% BFITLISTENON Enable listeners for Basic Fitting GUI. 

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/29 03:39:49 $

if ~isempty(findprop(handle(fig), 'bfit_FigureListeners'))
    listeners = get(handle(fig), 'bfit_FigureListeners');
    set(listeners.childadd,'Enabled','on');
	set(listeners.childremove,'Enabled','on');
    set(listeners.figdelete,'Enabled','on');
end

lineL = findobj(fig, 'type', 'line');
for i = lineL'
    if ~isempty(findprop(handle(i), 'bfit_CurveListeners'))
	listeners = get(handle(i), 'bfit_CurveListeners');
        set(listeners.tagchanged,'Enabled','on');
    end
    if ~isempty(findprop(handle(i), 'bfit_CurveDisplayNameListeners'))
	listeners = get(handle(i), 'bfit_CurveDisplayNameListeners');
        set(listeners.displaynamechanged,'Enabled','on');
    end
end

axesL = findobj(fig, 'type', 'axes');
for i = axesL'
    if ~isempty(findprop(handle(i), 'bfit_AxesListeners'))
	listeners = get(handle(i), 'bfit_AxesListeners');
        if isequal(get(i,'tag'),'legend')
            set(listeners.userDataChanged,'Enabled','on');
        else
            set(listeners.lineAdded,'Enabled','on');
            set(listeners.lineRemoved,'Enabled','on');
        end
    end
end

