function hFig_printprev = vqcopyaxes(hMainFig)
% COPY the axes of both the figures.
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:05:35 $


	h = guidata(hMainFig);
	ud=get(hMainFig,'UserData');
    
	hFig_printprev = figure('Number','off',...
                            'visible','off');
	
	hax1 = subplot(2,1,1);
	haxc1 = copyobj(h.plotErrIter, hFig_printprev);
	set(haxc1, 'units', get(hax1, 'units'), 'position', get(hax1, 'position'));
    delete(hax1);
	
        hax2 = subplot(2,1,2);
        haxc2 = copyobj(h.plotEntropyIter, hFig_printprev);
        set(haxc2, 'units', get(hax2, 'units'), 'position', get(hax2, 'position'));
        delete(hax2);

% [EOF]
