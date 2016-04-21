function fvmotion(toolnum)
%FVMOTION - Filter Viewer tool motion function for changing pointer.
%   regular mouse motion in figure - update cursor
%     fig - the figure number of the tool
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

    figname = prepender(['Filter Viewer']);
    fig = findobj('name',figname);
    if isempty(fig)
        return
    end    
    ud = get(fig,'userdata');

    switch ud.pointer
    case 0  % normal mode
        ptr = 'arrow';
    if ud.prefs.tool.ruler 
        ruler_curs = ruler('motion',fig);
        if ruler_curs == 1
            setptr(fig,'hand1')
            return
        elseif ruler_curs == 2
            setptr(fig,'hand2')
            return
        end
    end
    
    case 1  % zoom mode
        fp = get(fig,'position');
        sz = ud.sz;
        ruler_port = [ud.left_width 0 fp(3)-ud.left_width sz.rh*ud.prefs.tool.ruler];
        mp = [ud.left_width ruler_port(4) fp(3)-ud.left_width fp(4)-ruler_port(4)];
        pt = get(fig,'currentpoint');
        %mouse is in main panel:
        if pinrect(pt(1,1:2),[mp(1) mp(1)+mp(3) mp(2) mp(2)+mp(4)])
            ptr = 'cross';
        else
            ptr = 'arrow';
        end
    case 2  % help mode
        ptr = 'help';
    case -1  % watch cursor
        ptr = 'watch';
    otherwise
        ptr = 'arrow';
    end
   
    setptr(fig,ptr)

