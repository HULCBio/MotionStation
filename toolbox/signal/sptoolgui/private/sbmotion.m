function sbmotion(varargin)
%SBMOTION Windowbuttonmotionfcn for signal browser
%   Inputs:
%      scalar  - figure handle of browser
%
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

if nargin > 0
% pass a figure handle if you want to quickly update the pointer
    fig = varargin{1};
else
    fig = findobj('type','figure','tag','sigbrowse');
end

ud = get(fig,'userdata');
flag = ud.pointer;
switch flag
case -1,  % wait mode
    setptr(fig,'watch'),
case 0,  % pointer mode
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

    if ud.prefs.tool.panner
        pan_curs = panner('motion',fig);
        if pan_curs == 1
            setptr(fig,'hand')
            return
        end
    end

    set(fig,'pointer','arrow')

case 1,  % zoom mode
    fp = get(fig,'position');   % in pixels already
    p = get(fig,'currentpoint');  p = p(1,1:2);
    sz = ud.sz;
    toolbar_ht = 0; % sz.ih;
    left_width = 0;

    ruler_port = [0 0 fp(3) sz.rh*ud.prefs.tool.ruler];
    panner_port = [0 ruler_port(4) ...
                    fp(3) sz.ph*ud.prefs.tool.panner];
    mp = [0 panner_port(4)+ruler_port(4) fp(3) ...
                     fp(4)-(toolbar_ht+panner_port(4)+ruler_port(4))];

    %mouse is in main panel:
    if pinrect(p,[mp(1) mp(1)+mp(3) mp(2) mp(2)+mp(4)])
        setptr(fig,'cross')
        return
    end
    if ud.prefs.tool.panner
        pan_curs = panner('motion',fig);
        if pan_curs == 1
            setptr(fig,'hand')
            return
        end
    end
    setptr(fig,'arrow')

case 2,  % help mode 
    setptr(fig,'help'),
end



