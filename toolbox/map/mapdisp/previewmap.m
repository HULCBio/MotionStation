function previewmap
% PREVIEWMAP view map at printed size
% 
%   PREVIEWMAP changes the size of the current figure to match the printed 
%   output.  This provides an accurate display of the relative placement and 
%   size of objects as they will be printed.  If the resulting figure size 
%   exceeds the screen size, the figure will be enlarged as much as possible.
%   
%   See also PAGEDLG, PAPERSCALE, AXESSCALE

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%   $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:19:18 $

h = gcf;

figureunits = get(h,'units');
paperunits = get(h,'paperunits');paperpos = get(h,'paperpos');
set(h,'units',paperunits,'pos',paperpos)

pos = get(h,'Position');


if max(abs(pos(3:4) - paperpos(3:4))) > 0.05
	set(h,'units',paperunits,'pos',[0 0 paperpos(3:4)])
	if max(abs(pos(3:4) - paperpos(3:4))) > 0.05
		warning('Figure window larger than screen size. Enlarging as much as possible')
	end
end

set(h,'units',figureunits)

shiftwin(gcf)

figure(gcf)

