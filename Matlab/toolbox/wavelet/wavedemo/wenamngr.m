function wenamngr(option,fig)
%WENAMNGR Enable settings for GUI demos in the Wavelet Toolbox.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-96.
%	Last Revision: 01-Oct-97.
%       Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

if isequal(lower(option),'inactive')
	mode = 3;
	uim = wfindobj(fig,'type','uimenu');
	uic = wfindobj(fig,'type','uicontrol');
	switch mode
	    case 1
		enaVal	= 'Inactive';
		hdls	= uic;

	    case 2
		enaVal	= 'Off';
		hdls	= uic;

	    case 3
		enaVal = 'Off';
		% pop = findobj(uic,'style','popupmenu');
		% pus = findobj(uic,'style','pushbutton');
		% rad = findobj(uic,'style','radioButton');
		% chk = findobj(uic,'style','checkBox');
		% edi = findobj(uic,'style','edit');
		% sli = findobj(uic,'style','slider');
		% hdls = [pop ; pus; rad; chk; edi];
		txt	= findobj(uic,'style','text');
		[a,b]	= wcommon(uic,txt);
		hdls	= uic(~a);
	end	

	set(uim,'Enable','Off');
	set(hdls,'Enable',enaVal);

	% Keeping Messages more visible.
	if mode==2
		txt_msg = wwaiting('handle',fig);
		set(txt_msg,'Enable','on');
	end
end
