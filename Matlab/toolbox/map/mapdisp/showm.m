function showm(object)

%SHOWM  Displays identified graphic objects
%
%  SHOWM('str') shows the object on the current axes specified
%  by the string 'str', where 'str' is any string recognized by HANDLEM.
%  Showing an object is accomplished by setting its visible property to on.
%
%  SHOWM will display a Graphical User Interface prompting for the
%  objects to be shown from the current axes.
%
%  SHOWM(h) shows the objects specified by the input handles h.
%
%  See also CLMO, HIDE, HANDLEM, NAMEM, TAGM

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0;   object = 'taglist';   end

%  Get the appropriate object handles

msg = [];
if isstr(object) &  strmatch('scaleruler',object,'exact') % strip trailing numbers
	hndl = [];
	for i=1:20 % don't expect more than 20 distinct scalerulers
		tagstr = ['scaleruler' num2str(i)];
		hexists = findall(gca,'tag',tagstr,'HandleVisibility','on');
		if ~isempty(hexists); hndl = [hndl hexists]; end
	end
	for i=1:length(hndl)
		s = get(hndl(i),'Userdata'); % Get the properties structure
		childtag = s.Children; % Handles of all elements of scale ruler
		hchild = findall(gca,'tag',childtag);
		set(hchild,'Visible','on');
	end
	return
elseif isstr(object) &  strmatch('scaleruler',object) % strip trailing numbers	
	hndl = findall(gca,'tag',object);
else
	[hndl,msg] = handlem(object);
end

%  Show the identified graphics objects

set(hndl,'Visible','on')

