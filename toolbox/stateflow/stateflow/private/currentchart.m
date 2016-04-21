function chartId = currentchart(),
%CHARTID = CURRENTCHART

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:56:33 $

	chartId = 0;
	defShowHidden = get(0,'ShowHidden');
	set(0,'ShowHidden','on');

	fig = findobj(get(0,'Children'),'Type','figure','Tag','SFCHART');

	set(0,'ShowHidden',defShowHidden);
	if isempty(fig), return; end;
	chartId = get(fig(1),'UserData');

