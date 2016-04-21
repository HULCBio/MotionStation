function [out1,out2,out3,out4] = utsetfon(opt,in2,in3,in4,in5,in6)
%UTSETFON Utilities for Setting Fonts.
%   [OUT1,OUT2,OUT3,OUT4] = UTSETFON(OPT,IN2,IN3,IN4,IN5,IN6)
%
%   OPT = 'define' : Construction
%   IN2  = fig is optional
%   IN3  = [XLeft YDown] is optional
%   OUT1 = Handles , out2 = Position
%
%   OPT = 'read'   : read font parameters of an object
%   IN2  = Handles
%   IN3  = Object handle
%
%   OPT = 'write'  : set font parameters of an object
%   IN2  = Handles
%   IN3  = Object handle
%
%   OPT = 'get'   : get font parameters
%   IN2  = Handles
%   OUT1 = Font Name        OUT2 = Font Size
%   OUT3 = Font Weight      OUT4 = Font Angle
%
%   OPT = 'set'   : set font parameters
%   IN2 = Handles
%   IN3 = Font Name         IN4 = Font Size
%   IN5 = Font Weight       IN6 = Font Angle
%
%   OPT = 'pos'   : change position
%   IN2  = [dx dy]
%   OUT1 = newpos

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

% Handles = [ ...
%   Ed_font_name Ed_font_size
%   Pop_font_weight Pop_font_angle  hdls];
%
% Frame = hdls(1) , Large = 340 , Hight = 86

switch opt
  case {'change','get','set','read','write'}
    Ed_font_name    = in2(1);
    Ed_font_size    = in2(2);
    Pop_font_weight = in2(3);
    Pop_font_angle  = in2(4);
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
            xg  = 10;       yb = 10;
        elseif nargin<3
            fig = in2;
            xg  = 10;       yb = 10;
        else
            fig = in2;
            xg  = in3(1);   yb = in3(2);
        end
        but_High   = 22;
        wid1 =  90;   wid2 = 65;    wid3 = 225;
        dx = 5;         dy = 5;
        lcadre = 340;   hcadre = 3*but_High+4*dy;
        out2 = [xg yb lcadre hcadre];

        hdls = zeros(1,9);
        hdls(1) = uicontrol('Parent',fig,'Style','Frame',...
                        'Position',[xg yb lcadre hcadre]);
        xg = xg+2*dx;
        yb = yb+dy;
        hdls(2) = uicontrol('Parent',fig,'Style','Frame',...
                        'BackGroundColor',txt_color,...
                        'Position',[wid1+wid2 yb wid1 but_High]);
        hdls(3) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,...
                        'Position',[wid1+wid2+3,yb+3,wid1-6,but_High-6],...
                        'String','Angle');
        Pop_font_angle = uicontrol('Parent',fig,'Style','Popup',...
                        'Position',[wid1+dx+wid1+wid2,yb,wid1,but_High],...
                        'String','normal|italic|oblique');

        yb = yb+dy+but_High;
        hdls(4) = uicontrol('Parent',fig,'Style','Frame',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg yb wid2 but_High]);
        hdls(5) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg+3,yb+3,wid2-6,but_High-6],...
                        'String','Size');
        Ed_font_size = uicontrol('Parent',fig,'Style','Edit',...
                        'BackGroundColor',Def_EdiBkColor,...
                        'Position',[xg+dx+wid2,yb,50,but_High]);


        hdls(6) = uicontrol('Parent',fig,'Style','Frame',...
                        'BackGroundColor',txt_color,...
                        'Position',[wid1+wid2 yb wid1 but_High]);
        hdls(7) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,...
                        'Position',[wid1+wid2+3,yb+3,wid1-6,but_High-6],...
                        'String','Weight');
        Pop_font_weight = uicontrol('Parent',fig,'Style','Popup',...
                        'Position',[wid1+dx+wid2+wid1,yb,wid1,but_High],...
                        'String','light|normal|demi|bold');

        yb = yb+dy+but_High;
        hdls(8) = uicontrol('Parent',fig,'Style','Frame',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg yb wid1 but_High]);
        hdls(9) = uicontrol('Parent',fig,'Style','Text',...
                        'BackGroundColor',txt_color,...
                        'Position',[xg+3,yb+3,wid1-6,but_High-6],...
                        'String','Font name');
        Ed_font_name = uicontrol('Parent',fig,'Style','Edit',...
                        'BackGroundColor',Def_EdiBkColor,...
                        'Position',[xg+dx+wid1,yb,wid3,but_High]);

        out1 = [Ed_font_name Ed_font_size Pop_font_weight Pop_font_angle hdls];

    case 'read'
        set(Ed_font_name,'String',get(in3,'FontName'));
        set(Ed_font_size,'String',int2str(get(in3,'FontSize')));
        s = get(in3,'FontWeight');
        switch s
            case 'light' ,  val = 1;
            case 'normal' , val = 2;
            case 'demi' ,   val = 3;
            otherwise,      val = 4;
        end
        set(Pop_font_weight,'Value',val);

        s = get(in3,'FontAngle');
        switch s
            case 'normal' , val = 1;
            case 'italic' , val = 2;
            otherwise,      val = 3;
        end
        set(Pop_font_angle,'Value',val);

    case 'write'
        fb = ['light ' ; 'normal' ; 'demi  ' ; 'bold  '];
        fi = ['normal ' ; 'italic ' ; 'oblique'];
        set(in3, ...
                'FontName',get(Ed_font_name,'String'),          ...
                'FontSize',wstr2num(get(Ed_font_size,'String')), ...
                'FontWeight',fb(get(Pop_font_weight,'Value'),:),...
                'FontAngle',fi(get(Pop_font_angle,'Value'),:)   ...
                );

    case 'set'
        set(Ed_font_name,'String',in3);
        set(Ed_font_size,'String',int2str(in4));
        set(Pop_font_weight,'Value',in5);
        set(Pop_font_angle,'Value',in6);

    case 'get'
        out1 = get(Ed_font_name,'String');
        out2 = wstr2num(get(Ed_font_size,'String'));
        out3 = get(Pop_font_weight,'Value');
        out4 = get(Pop_font_angle,'Value');

    case 'pos'
        dx = in3(1);    dy = in3(2);
        set(in2,'Visible','Off');
        for k = 1:length(in2)
            pos  = get(in2(k),'Position');
            npos = [pos(1)+dx pos(2)+dy pos(3:4)];
            set(in2(k),'Position',npos);
        end
        set(in2,'Visible','On');
        out1 = get(in2(5),'Position');  % in2(5) = hdls(1) is the Frame
end
