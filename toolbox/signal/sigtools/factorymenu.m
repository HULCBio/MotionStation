function [h, children] = factorymenu(arg,newparent)
%FACTORYMENU Render default (factory) menus. 
%   FACTORYMENU(MENU_NAME,NEWFIGURE) returns handles to default 
%   figure menus and renders them on NEWFIGURE.

%   Author(s): W. York 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:51:53 $ 

f = figure('Visible','off','menubar','figure');
if ischar(arg)
    arg = [upper(arg(1)) lower(arg(2:end))];
    hlist = findall(f,'type','uimenu','label',arg);
    if isempty(hlist)
        hlist = findall(f,'type','uimenu','label',['&' arg]);
    end
else
    % get the first uimenu with the requested position
    % make sure it's not a child menu.
    hlist = findall(f,'type','uimenu','position',arg);
    indicies = logical(0);
    for i=1:length(hlist)
        indicies(i) = isempty(get(hlist(i),'children'));
    end
    hlist = hlist(indicies);
    hlist = hlist(1);
end

h = copyobj(hlist,newparent);
children = copyobj(flipud(findall(f,'parent',hlist)),h);
close(f);

% [EOF]
