function spmotion(varargin)
%spMOTION Windowbuttonmotionfcn for spectrum viewer
%   Inputs:
%      scalar  - figure handle of browser (if not an integer)
%
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

if nargin == 1
% pass a figure handle if you want to quickly update the pointer
    fig = varargin{1};
else  
    fig = findobj(get(0,'children'), 'flat','tag','spectview');
    if isempty(fig)
        return
    end
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

    set(fig,'pointer','arrow')

case 1,  % zoom mode
    fp = get(fig,'position');   % in pixels already
    p = get(fig,'currentpoint');  p = p(1,1:2);
    sz = ud.sz;

    ruler_port = [ud.left_width 0 fp(3)-ud.left_width sz.rh*ud.prefs.tool.ruler];
    mp = [ud.left_width ruler_port(4) fp(3)-ud.left_width fp(4)-ruler_port(4)];

    %mouse is in main panel:
    if pinrect(p,[mp(1) mp(1)+mp(3) mp(2) mp(2)+mp(4)])
        setptr(fig,'cross')
    else
        setptr(fig,'arrow')
    end

case 2,  % help mode 
    setptr(fig,'help'),
end



