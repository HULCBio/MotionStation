function sbresize(create_flag,fig)
%SBRESIZE Resize function for Signal Browser.
%   SBRESIZE will resize only those objects which need resizing.
%   SBRESIZE(1) will resize every object.  Use this syntax at creation
%   of the figure.
%
%   SBRESIZE(create_flag,fig) resizes the browser with figure handle fig.
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

%   TPK, 12/2/95

    if nargin == 0
        create_flag = 0;
    end

    if nargin <= 1
        fig = gcbf;
    end
    
    ud = get(fig,'userdata');
    sz = ud.sz;

    fp = get(fig,'position');   % in pixels already

    toolbar_ht = 0;% sz.ih;

    ruler_port = [0 0 fp(3) sz.rh*ud.prefs.tool.ruler];
    panner_port = [0 ruler_port(4) ...
                    fp(3) sz.ph*ud.prefs.tool.panner];
    mainaxes_port = [0 panner_port(4)+ruler_port(4) fp(3) ...
                     fp(4)-(toolbar_ht+panner_port(4)+ruler_port(4))];

    mainaxes_pos = mainaxes_port + ...
               [sz.as(1) sz.as(2) -(sz.as(1)+sz.as(3)) -(sz.as(2)+sz.as(4))];

    if mainaxes_pos(3)<ud.prefs.minsize(1)  ...
         | mainaxes_pos(4)<ud.prefs.minsize(2)
       %disp('    SIGBROWSE: figure too small - resizing')
       
       % minsize(1)   - minimum width of main axes in pixels
       % minsize(2)   - minimum height of main axes in pixels

       w = sz.rw*ud.prefs.tool.ruler+sz.as(1)+...
             sz.as(3)+ud.prefs.minsize(1);
       w = max(w,fp(3));
       h = panner_port(4)+sz.as(2)+sz.as(4)+ud.prefs.minsize(2)+toolbar_ht;
       h = max(h,fp(4));
       fp = [fp(1) fp(2)+fp(4)-h w h];
       set(fig,'position',fp)
       % return
    end

% recompute these with new figure position:
    ruler_port = [0 0 fp(3) sz.rh*ud.prefs.tool.ruler];
    panner_port = [0 ruler_port(4) ...
                    fp(3) sz.ph*ud.prefs.tool.panner];
    mainaxes_port = [0 panner_port(4)+ruler_port(4) fp(3) ...
                     fp(4)-(toolbar_ht+panner_port(4)+ruler_port(4))];

    mainaxes_pos = mainaxes_port + ...
               [sz.as(1) sz.as(2) -(sz.as(1)+sz.as(3)) -(sz.as(2)+sz.as(4))];

    %hand = ud.hand;

    % Tweak position & size of uicontrols: [horz_pos ver_pos width height]
    switch computer
    case 'MAC2'
        popTweak = [0 -8 0  1];
        btnTweak = [0 -3 0 -2];
    case 'PCWIN'
        popTweak = [0 -2 0  0];
        btnTweak = [0 -1 0 -2];
    otherwise  % UNIX
        popTweak = [0 -4 0 -1];
        btnTweak = [0 -4 0  0];
    end
 
    % 1-by-4 position vectors
    pos = {
    ud.mainaxes        mainaxes_pos
    ud.mainaxes_border mainaxes_pos+[-1 -1 2 2]
    };

%    hand.complexpopup  [mainaxes_pos(1) mainaxes_pos(2)+mainaxes_pos(4)+3 ...
%                          110 sz.uh]
%    hand.arraybutton   [sz.fus fp(4)-sz.ih/2-sz.uh/2 sz.bw sz.uh]

    set([pos{:,1}],{'position'},pos(:,2))

    ut = get(ud.toolbar.whatsthis,'parent');
    tbfillblanks(ut,ud.toolbar.lineprop,ud.toolbar)

