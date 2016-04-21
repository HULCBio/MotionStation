function wtxttitl(axe,txtStr,tag)
%WTXTTITL Set a text as a super title in an axes.
%    WTXTTITL(AXE,TXTSTR,TAG)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 17-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin==2 , tag = ''; end
newtxt = 1;
if ~isempty(tag)
    h_txt = findobj(axe,'type','text','tag',tag);
    if ~isempty(h_txt) , newtxt = 0; end
end

axes(axe);
if newtxt
    u_axe = get(axe,'Units');
    h_tit = get(axe,'title');
    u_tit = get(h_tit,'Units');
    u_txt = 'pixels';
    set(h_tit,'Units',u_txt);
    h_txt  = text(0,0,txtStr,                  ...
               'Parent',axe,                   ...
               'Units',u_txt,                  ...
               'Color',wtbutils('colors','title'), ...
               'FontWeight','bold',            ...
               'HorizontalAlignment','center', ...
               'Visible','off',                ...
               'Tag',tag                       ...
               );
    e_tit  = get(h_tit,'Extent');
    p_tit  = get(h_tit,'Position');
    px_txt = p_tit(1);
    if e_tit(4)>0
        py_txt = e_tit(2)+1.33*e_tit(4);
    else
        py_txt = e_tit(2)-0.32*e_tit(4);
    end
    set(h_txt,'Position',[px_txt py_txt+3],'Visible','on');
    set([h_txt,h_tit],'Units',u_axe);
else
    set(h_txt,'String',txtStr,'Visible','on');
end
drawnow
