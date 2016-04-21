function hFig_printprev = sqcopyaxes(hMainFig)
% COPY the axes of both the figures.
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:12 $


	h = guidata(hMainFig);
	
	hFig_printprev = figure('Number','off',...
                            'visible','off');
	
	hax1 = subplot(2,1,1);
	haxc1 = copyobj(h.plotErrIter, hFig_printprev);
	set(haxc1, 'units', get(hax1, 'units'), 'position', get(hax1, 'position'));
	
	hax2 = subplot(2,1,2);
	haxc2 = copyobj(h.plotStepFcn, hFig_printprev);
	set(haxc2, 'units', get(hax2, 'units'), 'position', get(hax2, 'position'));
	
	delete(hax2);
	delete(hax1);

% [EOF]
