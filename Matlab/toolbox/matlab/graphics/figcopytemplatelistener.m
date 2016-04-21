function figcopytemplatelistener(action, object)
%FIGCOPYTEMPLATELISTENER
%   FIGCOPYTEMPLATELISTENER(action, object) will add or remove listeners that will signal when 
%   a figure is added or removed, and when the current figure is changed.
%   
%   action is 'add' or 'remove' 
%   
%   object is the interested party
%   

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 17:08:24 $

if strcmp(action, 'add')
	hgp = findpackage('hg');
	rootC = findclass(hgp, 'root');
	hProp = findprop(rootC, 'CurrentFigure');

	FigCTListeners.figureAdded = handle.listener(0, 'ObjectChildAdded', {@rootChildAdded, object});
	FigCTListeners.figureRemoved = handle.listener(0, 'ObjectChildRemoved', {@rootChildRemoved, object});
	FigCTListeners.GCFChanged = handle.listener(0, hProp, 'PropertyPostSet', {@gcfChanged, object});

	setappdata(0, 'Fig_CT_Listener', FigCTListeners);

elseif strcmp(action, 'remove')
	if isappdata(0, 'Fig_CT_Listener') 
		rmappdata(0, 'Fig_CT_Listener');
	end
end 

%-------------------------------------------------------------------------------------

% Listen for figures being added.  Only act if a figure is added.
function rootChildAdded(hSrc, event, javaObj)
	if isa(event.child, 'hg.figure')
		if isappdata(0,'Fig_CT_Listener')
			javaObj.CurrentFigureChanged;
		end
	end

%-------------------------------------------------------------------------------------

% Listen for figures being removed.  Only act if a figure is removed.
function rootChildRemoved(hSrc, event, javaObj)
	if isa(event.child, 'hg.figure')
		if isappdata(0,'Fig_CT_Listener')
			fig = double(event.child);
			cf = get(0, 'CurrentFigure');
			nextcf = cf;
			if (fig == cf)	%current figure is being deleted
				h = findobj(0, 'type', 'figure');
				if (length(h) == 1)
					nextcf = 0;  %this is the last figure
				else
				   	if (h(1) == fig)
				   		nextcf = h(2);
				   	else
				   		nextcf = h(1);
				   	end	
				end
			end
			javaObj.FigureRemoved(fig, cf, nextcf);
		end
	end

%-------------------------------------------------------------------------------------

% Listen for GCF being changed. 
function gcfChanged(hSrc, event, javaObj)
	if isappdata(0, 'Fig_CT_Listener')
		javaObj.CurrentFigureChanged;
	end

