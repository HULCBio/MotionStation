function out1 = txtinaxe(option,in2,in3,in4,in5,in6,in7)
%TXTINAXE Right and left texts for axes.
%   OUT1 = TXTINAXE(OPTION,IN2,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

dlx = 42;
drx = 28;
if nargin==0 , option = 'create'; end
opt = option(1);

switch opt
    case 'c'
        %***********************%
        %** OPTION = 'create' **%
        %***********************%
        if nargin<7
            CurScrPixPerInch = get(0,'ScreenPixelsPerInch');
            StdScrPixPerInch = 72;
            RatScrPixPerInch = StdScrPixPerInch / CurScrPixPerInch;
            fontsize         = floor(16*RatScrPixPerInch);
        else
            fontsize = in7;
        end
        if nargin<6, fonttype = 'bold'; else , fonttype = in6; end
        if nargin<5, vis      = 'on';   else , vis      = in5; end
        if nargin<4, side     = 'l';    else , side     = in4; end
        if nargin<3, axe      = gca;    else , axe      = in3; end
        if nargin<2, txt      = 'txt';  else , txt      = in2; end
        old_units = get(axe,'Units');
        set(axe,'Units','pixels');
        pos_a = get(axe,'Position');
        if side(1)=='l' , xtxt = -dlx; else , xtxt = pos_a(3)+drx; end
        ytxt = pos_a(4)/2;
        out1 = text(...
                    'Parent',axe,                   ...
                    'String',txt,                   ...
                    'FontWeight',fonttype,          ...
                    'FontSize',fontsize,            ...
                    'Unit','pixels',                ...
                    'Position',[xtxt ytxt],         ...
                    'HorizontalAlignment','center', ...
                    'Visible',vis                   ...
                    );
        set(axe,'Units',old_units);
        set(out1,'Units','normalized');

    case 'p'
        %********************%
        %** OPTION = 'pos' **%
        %********************%
        % in2 = hdl_txt;
        %---------------
        axe   = get(in2,'Parent');
        pos_t = get(in2,'Position');
        old_units = get(axe,'Units');
        set(axe,'Units','pixels'); 
        pos_a = get(axe,'Position');
        if pos_t(1)<0 , xtxt = -dlx; else , xtxt = pos_a(3)+drx; end
        set(in2,'Unit','pixels','Position',[xtxt pos_a(4)/2]);
        set(axe,'Units',old_units);
        set(in2,'Units','normalized');
end

