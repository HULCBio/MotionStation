function hout = clabelm(varargin)

%CLABELM	Add contour labels to a map contour plot.
%
%  CLABELM(CS,H) adds value labels to the current map contour
%  plot.  The labels are rotated and inserted within the contour
%  lines.  CS and H are the contour matrix and object handle
%  outputs from CONTORM or CONTOR3M.
%
%  CLABELM(CS,H,V) labels just those contour levels given in the
%  vector V.  The default action is to label all known contours.
%  The label positions are selected randomly.
%
%  CLABELM(CS,H,'manual') places contour labels at the locations
%  determined by a mouse click.  Pressing the return key terminates
%  labeling.  Use the space bar to enter contours and the arrow
%  keys to move the crosshair if no mouse is available.
%
%  CLABELM(CS) or CLABELM(CS,V) or CLABELM(CS,'manual') places
%  contour labels as above, except that the labels are drawn as
%  plus signs on the contour with a nearby height value.
%
%  H = CLABELM(...) returns handles to the TEXT (and possibly LINE)
%  objects created.
%
%  See also CONTOURM, INPUTM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.13.4.1 $ $Date: 2003/08/01 18:17:52 $
%  Written by:  E. Byrns, E. Brown




checknargin(1,inf,nargin,mfilename);
if ~ismap   
   eid = sprintf('%s:%s:invalidMapAxes', getcomp, mfilename);
   error(eid,'%s','Map axes are not current');    
end

c = varargin{1};   %  Get the contour matrix


%  Get the current map structure

[mstruct,msg] = gcm;
if ~isempty(msg);   
    eid = sprintf('%s:%s:invalidGCM', getcomp, mfilename);
    error(eid,'%s',msg);   
end

%  Project each contour level in the input c matrix.  Then,
%  use this updated c matrix in a clabel call.

i=0;
startpt = 1;
newc = [];
while (startpt < size(c,2))

	i=i+1;	
	npoints = c(2,startpt);

 	z_level = c(1,startpt);
	npoints = c(2,startpt);
    lon = c(1,startpt+1:startpt+npoints)';
    lat = c(2,startpt+1:startpt+npoints)';

    if ~strcmp(mstruct.mapprojection,'globe')
         [x,y] = feval(mstruct.mapprojection,mstruct,...
		               lat,lon,'line','forward');
	else
         eid = sprintf('%s:%s:invalidGlobeProjection', getcomp, mfilename);
         error(eid,'%s','CLABELM can not apply labels to globe projection')
	end

% 	c(1,startpt+1:startpt+npoints) = x';
% 	c(2,startpt+1:startpt+npoints) = y';

	newc = [ newc [  [z_level x(:)'] ; [length(x) y(:)'] ] ];
    
	startpt = startpt + npoints + 1;

end


%  Apply the contour labels

varargin{1} = newc;

% Save the current view (to undo an unwanted view3 in clabel)

[az,el] = view;

% Apply the label

h = clabel(varargin{:});

% Adjust the z level of text for filled contours. To make the stacking come
% out right, we had to distribute the contour patches in Z. Since the text
% gets drawn at the same level as the patch, parts of the text are obscured.
% This whole business with zlevels on CONTOURFM patches and text z levels can
% potentially be removed if the renderer stacking order problems with frames 
% turn out to be transitory.

if nargin >= 2 
	hndls = varargin{2};
	if ishandle(hndls(1)) & strcmp(get(hndls(1),'type') , 'patch')
		zdatam(h,0)
	end
end

% Adjust the text label to avoid clabel's ugly exponential format.
% Numbers may disagree with clegendm because clabel shows fewer 
% significant figures.

for i = 1:length(h)
   if strcmp(get(h(i),'type'),'text')
        num = str2num(get(h(i),'String'));
        set(h(i),'String',num)
   end
end
refresh

%  Set the user data of the new map text objects

savepts.trimmed = [];
savepts.clipped = [];
set(h,'UserData',savepts,'ButtonDownFcn','uimaptbx','Tag','Clabels')


%  Set the output arguments

if nargout == 1;   hout = h;   end

% Make sure the view hasn't changed. Clabel sets view(3) if hold is on. 

view(az,el)
