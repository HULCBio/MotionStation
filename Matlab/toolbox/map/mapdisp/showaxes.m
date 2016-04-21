function showaxes(action)

%SHOWAXES  Toggles the display of the current MATLAB cartesian axes
%
%  SHOWAXES ON displays the MATLAB cartesian axes and default axes ticks.
%  SHOWAXES OFF removes the axes ticks from the MATLAB cartesian axes.
%  SHOWAXES alone toggles between ON and OFF.
%
%  SHOWAXES HIDE hides the cartesian axes.
%  SHOWAXES SHOW shows the cartesian axes.
%
%  SHOWAXES RESET sets the cartesian axes to the default map display settings.
%  SHOWAXES BOXOFF removes the axes ticks, axes color and box from
%  the cartesian axes.
%
%  SHOWAXES('colorstr') sets the cartesian axes to the color
%  specified by 'colorstr'.  SHOWAXES(colorvec) uses the RBG triple
%  colorvec to set the cartesian axes color.
%
%  See also AXESM, SET

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
    xtick = get(gca,'Xtick');

	if ~isempty(xtick);    action = 'off';
        else;              action = 'on';
    end

elseif nargin == 1 & isstr(action)
    validstr = strvcat('on','off','hide','show','reset','boxoff',...
                       'white','black','red','green','blue','yellow',...
				       'magenta','cyan');

    action = lower(action);
    indx = strmatch(action,validstr);
    if isempty(indx)
         error('Not a valid SHOWAXES string')
    elseif length(indx) > 1
         error('Non-unique SHOWAXES string.  Supply more characters')
    elseif indx <= 6
         action = deblank(validstr(indx,:));
    else
         action   = 'color';
         colorstr = deblank(validstr(indx,:));
    end

elseif nargin == 1 & ~isstr(action)

	colorstr = action(:)';     action = 'color';

    if length(colorstr) ~= 3 | any(colorstr > 1) | any(colorstr < 0)
	     error('Invalid RGB triple')
	end
end


%  Set the axes property to the appropriate state

switch action
case 'off'
       set(gca,'Visible','on', 'Xtick',[], 'Ytick',[], 'Ztick',[])

case 'on'
       set(gca,'Visible','on', ...
               'XtickMode','auto', 'YtickMode','auto','ZtickMode','auto')

case 'color'
       set(gca,'Visible','on',...
	           'XtickMode','auto','Xcolor',colorstr,...
	           'YtickMode','auto','Ycolor',colorstr,...
			   'ZtickMode','auto','Zcolor',colorstr)

case 'hide'
	   set(gca,'Visible','off');

case 'show'
	   set(gca,'Visible','on');

case 'reset'
       colorstr = get(gca,'Color');
	   if strcmp(colorstr,'none');  colorstr = get(gcf,'Color');  end

	   set(gca,'Visible','on',...
			   'Xtick',[],'Xcolor',~colorstr,...
	           'Ytick',[],'Ycolor',~colorstr,...
			   'Ztick',[],'Zcolor',~colorstr,...
			   'Box','on')

case 'boxoff'
	   colorstr = get(gca,'Color');
	   if strcmp(colorstr,'none');  colorstr = get(gcf,'Color');  end

	   set(gca,'Visible','on',...
			   'Xtick',[],'Xcolor',colorstr,...
	           'Ytick',[],'Ycolor',colorstr,...
			   'Ztick',[],'Zcolor',colorstr,...
			   'Box','off')
end
