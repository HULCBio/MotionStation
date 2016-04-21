function [out1,out2] = utsetcol(opt,in2,in3,in4)
%UTSETCOL Utilities for Setting Color.
%   [OUT1,OUT2] = UTSETCOL(OPT,IN2,IN3,IN4)
%   OPT = 'define' : Construction
%   IN2  = fig is optional
%   IN3  = [XLeft YDown] is optional
%   IN4  = str_title is optional
%   OUT1 = Handles , out2 = Position
%
%   OPT = 'get'   : get color
%   IN2  = Handles
%   OUT1 = [R G B]
%
%   OPT = 'set'   : set color
%   IN2 = Handles
%   IN3 = [R G B]
%
%   OPT = 'pos'   : change position
%   IN2  = [dx dy]
%   OUT1 = newpos
%
%   OPT = 'change' & 'change_txt' : internal options.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

% Handles = [ ...
%    Sl_Color_R Rval_txt
%    Sl_Color_G Gval_txt
%    Sl_Color_B Bval_txt 
%    Frame_col  hdls]
%
% Frame = hdls(1) , Large = 340 , Hight = 72

switch opt
    case {'change','change_txt','get','set'}
        Sl_Color_R = in2(1); Rval_txt = in2(2);
        Sl_Color_G = in2(3); Gval_txt = in2(4);
        Sl_Color_B = in2(5); Bval_txt = in2(6);
        Frame_col  = in2(7);
end

switch opt
    case 'define'
        % Get Globals.
        %--------------
        [Def_TxtBkColor,Def_EdiBkColor,Def_FraBkColor] = ...
           mextglob('get',...
                'Def_TxtBkColor','Def_EdiBkColor','Def_FraBkColor');

        txt_color = Def_TxtBkColor;
        if nargin<2
            fig = gcf;
            xg  = 10;        yb = 10;
            str_title = 'Color';
        elseif nargin<3
            fig = in2;
            xg  = 10;        yb = 10;
            str_title = 'Color';
        elseif nargin<4
            fig = in2;
            xg  = in3(1);    yb = in3(2);
            str_title = 'Color';
        else
            fig = in2;
            xg  = in3(1);    yb = in3(2);
            str_title = in4;
        end
        but_High = 22;
        large = 120;
        ltxt  =  40;    htxt = but_High;
        ljg   =  15;    hjg  = 3*but_High;
        dx = 5;
        lcadre = 2*dx+6*dx+3*ltxt+3*ljg+large+3*dx;
        hcadre = 6+hjg;
        y = yb+3+but_High;

        out2 = [xg yb lcadre hcadre];

        hdls = zeros(1,6);
        hdls(1) = uicontrol('Parent',fig,'Style','Frame',...
                        'Position',[xg yb lcadre hcadre]);
        col = get(hdls(1),'BackGroundColor');

        xg = xg+2*dx;
        hdls(2) = uicontrol('Parent',fig,'Style','Frame',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg y+but_High-5 large but_High]);
        hdls(3) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg+3 y+but_High-2 large-6 but_High-6],...
                        'HorizontalAlignment','center',...
                        'String',str_title);

        Frame_col = uicontrol('Parent',fig,'Style','Frame',...
                        'Position',[xg y-but_High+5 large htxt]);
        xg = xg+large+2*dx;
        hdls(4) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg y+20 ltxt htxt],...
                        'String','R');
        Rval_txt = uicontrol('Parent',fig,'Style','Edit',...
                        'BackGroundColor',Def_EdiBkColor,...
                        'Position',[xg y-20 ltxt htxt],  ...
                        'String','');
        xg = xg+ltxt+dx;
        Sl_Color_R = uicontrol('Parent',fig,'Style','Slider',...
                        'Position',[xg yb+3 ljg hjg]);

        xg = xg+ljg+dx;
        hdls(5) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,    ...
                        'Position',[xg y+20 ltxt htxt], ...
                        'String','G');
        Gval_txt = uicontrol('Parent',fig,'Style','Edit',...
                        'BackGroundColor',Def_EdiBkColor,...
                        'Position',[xg y-20 ltxt htxt],  ...
                        'String','');
        xg = xg+ltxt+dx;
        Sl_Color_G = uicontrol('Parent',fig,'Style','Slider',...
                        'Position',[xg yb+3 ljg hjg]);

        xg = xg+ljg+dx;
        hdls(6) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,    ...
                        'Position',[xg,y+20,ltxt htxt], ...
                        'String','B');
        Bval_txt = uicontrol('Parent',fig,'Style','Edit', ...
                        'BackGroundColor',Def_EdiBkColor, ...
                        'Position',[xg y-20 ltxt htxt],   ...
                        'String','');
        xg = xg+ltxt+dx;
        Sl_Color_B = uicontrol('Parent',fig,'Style','Slider',...
                        'Position',[xg yb+3 ljg hjg]);

        out1 = [Sl_Color_R , Rval_txt , ...
                Sl_Color_G , Gval_txt , ...
                Sl_Color_B , Bval_txt , ...
                Frame_col  , hdls];

        action = [mfilename '(''change'',' num2mstr(out1) ');'];
        set([Sl_Color_R,Sl_Color_G,Sl_Color_B],'CallBack',action);
        set(Sl_Color_R,'Value',col(1));
        set(Sl_Color_G,'Value',col(2));
        set(Sl_Color_B,'Value',col(3));
        action = [mfilename '(''change_txt'',' num2mstr(out1) ');'];
        set([Rval_txt,Gval_txt,Bval_txt],'CallBack',action);
        eval(get(Sl_Color_R,'Callback'));

    case 'set'
        set(Sl_Color_R,'Value',in3(1));
        set(Sl_Color_G,'Value',in3(2));
        set(Sl_Color_B,'Value',in3(3));
        utsetcol('change',in2);

    case 'change'
        R = setValSli(Sl_Color_R,Rval_txt);
        G = setValSli(Sl_Color_G,Gval_txt);
        B = setValSli(Sl_Color_B,Bval_txt);
        set(Frame_col,'BackGroundColor',[R G B]);

    case 'change_txt'
        R = setValTxt(Sl_Color_R,Rval_txt);
        G = setValTxt(Sl_Color_G,Gval_txt);
        B = setValTxt(Sl_Color_B,Bval_txt);
        set(Frame_col,'BackGroundColor',[R G B]);

    case 'get'
        out1(1) = get(Sl_Color_R,'Value');
        out1(2) = get(Sl_Color_G,'Value');
        out1(3) = get(Sl_Color_B,'Value');

    case 'pos'
        dx = in3(1);    dy = in3(2);
        set(in2,'Visible','Off');
        for k = 1:length(in2)
            pos  = get(in2(k),'Position');
            npos = [pos(1)+dx pos(2)+dy pos(3:4)];
            set(in2(k),'Position',npos);
        end
        set(in2,'Visible','On');
        out1 = get(in2(8),'Position');  % in2(8) = hdls(1) is the Frame
end

% Internal function(s).
%----------------------
function val = setValSli(sliHdl,ediHdl)
val = get(sliHdl,'Value');
set(ediHdl,'String',sprintf('%4.2f',val));

function val = setValTxt(sliHdl,ediHdl)
val = wstr2num(get(ediHdl,'String'));
if isempty(val) | (val<0) | (val>1)
    val = get(sliHdl,'Value');
end
set(ediHdl,'String',sprintf('%4.2f',val));
set(sliHdl,'Value',val);
