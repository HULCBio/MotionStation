function colornone( state, fig )
%COLORNONE Modify figure to have transparent background
%   COLORNONE(STATE,FIG) modifies the color of graphics objects to print
%   or export them with a transparent background STATE is
%   either 'save' to set up colors for a transparent background or 'restore'.
%
%   COLORNONE(STATE) uses the current figure.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:28:38 $

persistent SaveTonerOriginalColors;

if nargin == 0 ...
        | ~isstr( state ) ...
        | ~(strcmp(state, 'save') | strcmp(state, 'restore'))
    error('COLORNONE needs to know if it should ''save'' or ''restore''')
elseif nargin ==1
    fig = gcf;
end


%for use in sub-functions

if strcmp( state, 'save' )
    origFigColor = get(fig,'color');
	if isequal( get(fig,'color'), 'none')
    	origFigColor = [NaN NaN NaN];
	end
    set(fig,'color', 'none');
    storage.figure = [fig origFigColor];
    SaveTonerOriginalColors = storage;
    
    
else % Restore colors
    
    orig = SaveTonerOriginalColors;
    
    origFig = orig.figure(1);
    origFigColor = orig.figure(2:4);
	if (sum(isnan(origFigColor)) == 3)
		origFigColor = 'none';
	end
    set(origFig,'color',origFigColor);
    
end



