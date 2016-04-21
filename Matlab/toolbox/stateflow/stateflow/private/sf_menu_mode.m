function sf_menu_mode(mode, fig)
%SF_MENU_MODE( MODE, FIG )

%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:59:42 $

	editH	= findobj(fig, 'type','uimenu','label','&Edit');
	addH	= findobj(fig, 'type','uimenu','label','&Add');

	switch(mode),
		case 'iced',	set([editH addH], 'enable','off');
		case 'normal',	set([editH addH], 'enable','on');
		otherwise, error('Bad mode passed to sf_menu_mode()');
	end;






			

