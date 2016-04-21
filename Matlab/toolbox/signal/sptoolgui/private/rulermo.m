function rulermo(ruler_num)
%RULERMO Windowbuttonmotionfcn for dragging a ruler object
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    fig = gcf;
    ud = get(fig,'userdata');

    p = get(ud.mainaxes,'currentpoint');
    p = p(1,1:2);
    if isnan(p)  % case in which p is outside of axes
        return
    end

    if ud.ruler.type(1) == 'h'     % horizontal dragging
        ylim = get(ud.mainaxes,'ylim');
        val = inbounds(p(2),ylim);
    else
        xlim = get(ud.mainaxes,'xlim');
        val = inbounds(p(1),xlim);
    end

    % now set the ruler values

    % evenlySpaced = (ud.lines(ud.focusIndex).Fs ~= -1);
    evenlySpaced = ud.ruler.evenlySpaced;
    if isfield(ud,'ht')
        ud = setrul(fig,ud,val,ruler_num,evenlySpaced,...
            0,find(ud.mainaxes==ud.ht.a));
    else
        ud = setrul(fig,ud,val,ruler_num,evenlySpaced,0,1);
    end
    
    set(fig,'userdata',ud)
