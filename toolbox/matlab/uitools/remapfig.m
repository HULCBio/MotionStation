function remapfig(oldpos,newpos,fig,h)
%REMAPFIG  Transform figure objects' positions.
%  REMAPFIG(POS) takes a normalized position vector POS and places the 
%  contents of the current figure into the desired figure subsection.
%
%  REMAPFIG(OLDPOS,NEWPOS) repositions all the children of the figure 
%  into a new rectangle NEWPOS such that whatever was in OLDPOS before 
%  is now in NEWPOS.
%
%  REMAPFIG(OLDPOS,NEWPOS,FIG) does this in FIG, not the gcf (necessarily).
%
%  REMAPFIG(OLDPOS,NEWPOS,FIG,H) will change the positions of only the
%  objects in handle vector H.

%  Author(s): T. Krauss, 9/29/94
%  Copyright 1984-2003 The MathWorks, Inc.
%  $Revision: 1.14.4.3 $  $Date: 2004/04/10 23:34:22 $

if nargin == 1
    pos = oldpos;
elseif nargin >= 2 
    pos = newpos(3:4)./oldpos(3:4);
    pos = [newpos(1:2)-oldpos(1:2).*pos pos];
else
    error(nargchk(1,3,nargin))
end
if nargin < 3
    fig = gcf;
end
if nargin < 4
    h = get(fig,'children');
end

for i = 1:length(h)
    if any(strcmp(get(h(i),'type'),{'uimenu', 'uicontextmenu'}))
       % do nothing
   else
       saveunits = get(h(i),'units');
       set(h(i),'units','normalized');
       isAxes = strcmp(get(h(i),'Type'),'axes');
       if isAxes
         p = get(h(i),get(h(i),'ActivePositionProperty'));
       else
         p = get(h(i),'position');
       end
       p(1:2) = p(1:2).*pos(3:4)+pos(1:2);
       p(3:4) = p(3:4).*pos(3:4);
       if isAxes
         set(h(i),get(h(i),'ActivePositionProperty'),p);
       else
         set(h(i),'position',p);
       end
       set(h(i),'units',saveunits);
    end
end


