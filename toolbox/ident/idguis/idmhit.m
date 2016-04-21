function h = idmhit(objtype)
%IDMHIT Determines whether figure is over an object of a certain type.
%   If the pointer is over an object of type objtype, return the handle
%   to that object, else 0. If we're not over a figure, return empty.

%   L. Ljung 9-27-94, Adopted from Joe
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:34 $

f = get(0,'pointerwindow');
if(f == 0)
        h = [];
        return;
end

p = get(0,'pointerloc');
set(f,'units','pixels');
pos = get(f,'pos');
x = (p(1)-pos(1))/pos(3);
y = (p(2)-pos(2))/pos(4);
c = findobj(get(f,'children'),'type',objtype,'vis','on');
set(c,'units','norm');
for h = c'
        r = get(h,'pos');
        if((x > r(1)) & (x < (r(1) + r(3))) &...
           (y > r(2)) & (y < (r(2) + r(4))))
                return;
        end
end
h = [];