function constants = dlg_constants( fig, constants)
%CONSTANTS = DLG_CONSTANTS( FIG, CONSTANTS )

%   E. Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:56:49 $

	tmp = uicontrol('Parent',fig,'Style','text','String','ABCDEFGHIJKLMNOPQRSTgjqy ','Visible','off');
	extent = get(tmp,'extent');
	delete(tmp);
	constants.textHeight = extent(4);

	fontSize = get(fig,'defaultUicontrolFontSize');
   constants.fontSize = fontSize;
	constants.xmargin = fontSize;
	constants.ymargin = fontSize;
%	constants.buff = fontSize*0.75;
	constants.buff = fontSize*.6;
	constants.smallBuff = fontSize*0.3;
	constants.reallySmallBuff = fontSize*0.2;
	constants.buttonW = 5*fontSize;
	constants.buttonH = 2*fontSize;
	constants.editH = 1.8*fontSize;
   constants.popupH = 1.8*fontSize;
   constants.popupWO = 2.5*fontSize;
	constants.boxWidth = 8*fontSize;

