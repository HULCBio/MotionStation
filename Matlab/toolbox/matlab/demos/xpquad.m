function xpquad(action)
%XPQUAD Superquadrics plotting demonstration.
%   This demo shows plots of various versions of    
%   Barr's "superquadrics" ellipsoid. The shapes  
%   are defined by two parameters, known as         
%   vertical roundness and horizontal roundness.    
%   These two parameters are, in turn, controlled   
%   by the sliders on the side panel of the     
%   Superquadrics window.      
%                                                        
%   By adjusting these parameters, you can make     
%   a cube, a sphere, a cylinder, and dozens of     
%   curious generalized ellipsoids.   

%   Ned Gulley, 6-21-93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/10 23:25:58 $

if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize'),
    figNumber=figure( ...
        'Name','Superquadrics', ...
        'NumberTitle','off', ...
        'Visible','off', ...
        'Color',0.8*[1 1 1], ...
        'BackingStore','off');
    colordef(figNumber,'white')
    axes( ...
        'Units','normalized', ...
        'Position',[0.05 0.05 0.70 0.90], ...
        'Visible','off');

    %===================================
    % Information for all buttons
    labelColor=[0.8 0.8 0.8];
    top=0.95;
    bottom=0.05;
    btnWid=0.15;
    btnHt=0.10;
    right=0.95;
    left=right-btnWid;
    % Spacing between the button and the next command's label
    spacing=0.02;
    
    %====================================
    % The CONSOLE frame
    frmBorder=0.02;
    yPos=bottom-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.50 0.50 0.50]);

    %====================================
    % The first slider
    btnNumber=1;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    callbackStr='xpquad(''build'');';

    % Generic button information
    sldPos=[left yPos-2*btnHt btnWid btnHt];
    labelPos1=[left yPos-btnHt/2 btnWid btnHt/2];
    labelPos2=[left yPos-btnHt btnWid btnHt/2];
    sld1Hndl=uicontrol( ...
        'Style','slider', ...
        'Tag','vertical', ...
        'Units','normalized', ...
        'Position',sldPos, ...
        'Callback',callbackStr);

    uicontrol( ...
        'Style','text', ...
        'String','Vertical', ...
        'Units','normalized', ...
        'Position',labelPos1);
    uicontrol( ...
        'Style','text', ...
        'String','Roundness', ...
        'Units','normalized', ...
        'Position',labelPos2);

    %====================================
    % The second slider
    btnNumber=3;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    callbackStr='xpquad(''build'');';

    % Generic button information
    sldPos=[left yPos-2*btnHt btnWid btnHt];
    labelPos1=[left yPos-btnHt/2 btnWid btnHt/2];
    labelPos2=[left yPos-btnHt btnWid btnHt/2];
    sld2Hndl=uicontrol( ...
        'Style','slider', ...
        'Tag','horizontal', ...
        'Units','normalized', ...
        'Position',sldPos, ...
        'Callback',callbackStr);

    uicontrol( ...
        'Style','text', ...
        'String','Horizontal', ...
        'Units','normalized', ...
        'Position',labelPos1);
    uicontrol( ...
        'Style','text', ...
        'String','Roundness', ...
        'Units','normalized', ...
        'Position',labelPos2);

    %====================================
    % The HELP button
    labelStr='Help';
    callbackStr=['helpwin ' mfilename];
    uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Close';
    callbackStr='close(gcf)';
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    % Uncover the figure
    set(figNumber, ...
        'Visible','on');

    % Make the sliders 16 pixels tall so it looks good on a Mac
    set([sld1Hndl sld2Hndl],'Units','pixel')
    sld1Pos=get(sld1Hndl,'Position');
    sld2Pos=get(sld2Hndl,'Position');
    set(sld1Hndl,'Position',[sld1Pos(1) sld1Pos(2)+sld1Pos(4)-16 sld1Pos(3) 16])
    set(sld2Hndl,'Position',[sld2Pos(1) sld2Pos(2)+sld2Pos(4)-16 sld2Pos(3) 16])
    set([sld1Hndl sld2Hndl],'Units','normalized')

    % Draw the initial superquadric
    n=5*get(sld1Hndl,'Value');
    e=5*get(sld2Hndl,'Value');
    [x,y,z]=superquad(n,e,20);
    surfHndl=surf(x,y,z);
    set(surfHndl,'Tag','surface');
    light('Position',[2 -1 10]);
    light('Position',[-3 -1 -5]);
    lighting phong
    axis off;
    shading interp;
    colormap([0 0 1])
    drawnow

elseif strcmp(action,'build'),
    %====================================
    axHndl=gca;
    figNumber=gcf;
    sld1Hndl=findobj(gcf,'Tag','horizontal');
    sld2Hndl=findobj(gcf,'Tag','vertical');

    % Xpquad problem
    n=5*get(sld1Hndl,'Value');
    e=5*get(sld2Hndl,'Value');
    [x,y,z]=superquad(n,e,20);
    surfaceHndl=findobj(gcf,'Tag','surface');
    set(surfaceHndl,'XData',x,'YData',y,'ZData',z)
    drawnow

end;    % if strcmp(action, ...
