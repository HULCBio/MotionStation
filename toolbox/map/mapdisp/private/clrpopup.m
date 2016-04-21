function rgbout = clrpopup

%CLRPOPUP  Processes callback from color popup menus
%
%  CLRPOPUP will process a color popup menu used throughout the
%  Mapping Toolbox GUIs.  This function assumes that the popup menu
%  UserData contains a structure with fields .VAL (for the current
%  RGB values) and .RGB (for the RGB codes of all items on the popup
%  menu).  COLORPOPUP will update the .VAL field upon successful
%  completion.  CLRPOPUP will also initialize a color wheel if the
%  Custom option is selected (which must be the first item on the
%  popup menu list).
%
%  C = CLRPOPUP will also return the selected RGB codes in the optional
%  output argument.
%
%  See also  AXESMUI (for an implementation)

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
%  Written by:  E. Byrns, E. Brown



colordata = get(gco,'UserData');   %  Get the needed user data structure (X.val,X.rgb)
popupval  = get(gco,'Value');      %  Color popup menu items
colors    = get(gco,'String');

if popupval ~= 1                    %  Not a custom color
       colordata.val = colordata.rgb(popupval,:);
	   if colordata.val(1) <= 1     %  Valid color (not auto or none)
	          set(gco,'UserData',colordata)

       elseif colordata.val(1) > 1     %  Auto or none
		      colordata.val = colors(popupval,:);
			  set(gco,'UserData',colordata)
	   end
       rgbcodes = colordata.val;

else        %  Custom color
       set(gco,'Interruptible','on')   %  Ensure an interruptible property

	   if isstr(colordata.val);   initcolor = [1 1 1];
	      else;                   initcolor = colordata.val;
	   end
	   rgbcodes = uisetcolor(initcolor,'Custom Color');

	   if length(rgbcodes) == 3
			 colordata.val = rgbcodes;
			 set(gco,'UserData',colordata)
	   else
	         rgbcodes = [];
	   end
end


%  Set the output argument if necessary

if nargout == 1;   rgbout = rgbcodes;   end
