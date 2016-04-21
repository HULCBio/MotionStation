function truss(action)
%TRUSS  Animation of a bending bridge truss.
%   This demo animates 12 natural bending modes  
%   of a two-dimensional truss. These bending    
%   modes are the results of eigenvalue analysis.
%   They have been ordered by natural frequency, 
%   with one being the slowest (and easiest to   
%   excite) mode and 12 being the fastest.       
%                                                
%   Use the "Mode" popup menu to select among    
%   the various modes. The "Start" and "Stop"    
%   buttons control the animation.               

%   Ned Gulley, 6-21-93
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.13.4.3 $  $Date: 2004/04/10 23:25:51 $

% Information regarding the play status will be held in
% the axis user data according to the following table:
play= 1;
stop=-1;

if nargin<1,
   action='initialize';
end;

if strcmp(action,'initialize'),
   oldFigNumber=watchon;
   
   figNumber=figure( ...
      'Name','Bending Truss', ...
      'NumberTitle','off', ...
      'Visible','off', ...
      'DoubleBuffer','on', ...
      'BackingStore','off', ...
      'Colormap',[]);
   axes( ...
      'Units','normalized', ...
      'Position',[0.05 0.05 0.75 0.90], ...
      'Visible','off', ...
      'NextPlot','add');
   
   text(0,0,xlate('Press the "Start" button to see the Bending Truss demo'), ...
      'HorizontalAlignment','center');
   axis([-1 1 -1 1]);
   
   %===================================
   % Information for all buttons
   labelColor=[0.8 0.8 0.8];
   yInitPos=0.90;
   xPos=0.85;
   btnWid=0.10;
   btnHt=0.10;
   % Spacing between the button and the next command's label
   spacing=0.05;
   
   %====================================
   % The CONSOLE frame
   frmBorder=0.02;
   yPos=0.05-frmBorder;
   frmPos=[xPos-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
   h=uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',[0.5 0.5 0.5]);
   
   %====================================
   % The START button
   btnNumber=1;
   yPos=0.90-(btnNumber-1)*(btnHt+spacing);
   labelStr='Start';
   cmdStr='start';
   callbackStr='truss(''start'');';
   
   % Generic button information
   btnPos=[xPos yPos-spacing btnWid btnHt];
   startHndl=uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Interruptible','on', ...
      'Callback',callbackStr);
   
   %====================================
   % The MODE popup button
   btnNumber=2;
   yPos=0.90-(btnNumber-1)*(btnHt+spacing);
   textStr='Mode';
   popupStr=reshape(' 1  2  3  4  5  6  7  8  9 10 11 12 ',3,12)';
   
   % Generic button information
   btnPos1=[xPos yPos-spacing+btnHt/2 btnWid btnHt/2];
   btnPos2=[xPos yPos-spacing btnWid btnHt/2];
   popupHndl=uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',btnPos1, ...
      'String',textStr);
   btnPos=[xPos yPos-spacing btnWid btnHt/2];
   popupHndl=uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos2, ...
      'String',popupStr);
   
   %====================================
   % The STOP button
   btnNumber=3;
   yPos=0.90-(btnNumber-1)*(btnHt+spacing);
   labelStr='Stop';
   % Setting userdata to -1 (=stop) will stop the demo.
   callbackStr='set(gca,''Userdata'',-1)';
   
   % Generic button information
   btnPos=[xPos yPos-spacing btnWid btnHt];
   stopHndl=uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'Enable','off', ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %====================================
   % The INFO button
   labelStr='Info';
   callbackStr='truss(''info'')';
   infoHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[xPos 0.20 btnWid 0.10], ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %====================================
   % The CLOSE button
   labelStr='Close';
   callbackStr='close(gcf)';
   closeHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[xPos 0.05 btnWid 0.10], ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   % Uncover the figure
   hndlList=[startHndl popupHndl stopHndl infoHndl closeHndl];
   set(figNumber,'Visible','on', ...
      'UserData',hndlList);
   
   watchoff(oldFigNumber);
   figure(figNumber);
   
elseif strcmp(action,'start'),
   wnumber=watchon;
   axHndl=gca;
   figNumber=gcf;
   hndlList=get(figNumber,'UserData');
   startHndl=hndlList(1);
   popupHndl=hndlList(2);
   stopHndl=hndlList(3);
   infoHndl=hndlList(4);
   closeHndl=hndlList(5);
   set([startHndl closeHndl infoHndl],'Enable','off');
   set(stopHndl,'Enable','on');
   
   % ====== Start of Demo
   load('truss.mat','a','x0','xy');
   n=get(popupHndl,'Value');
   set(axHndl,'Userdata',play);
   numframes=15;
   del= x0(:,n);
   del=reshape([del' zeros(1,4)] ,2,10)';
   [xd,yd]=gplot(a,xy);
   cla;
   axis([-0.5 5.5 -2 2]);
   h=plot(xd,yd);
   % Draw green embankment next to the bridge truss.
   patch([-0.5 0 0.5 -0.5],[0 0 -2 -2],[0 0.7 0]);
   patch([5 5.5 5.5 4.5],[0 0 -2 -2],[0 0.7 0]);
   text(2.5,1.7,xlate('Bending Modes of a Truss'), ...
      'HorizontalAlignment','center');
   axis off;
   set(gca,'Drawmode','Fast');
   
   t=linspace(0,2*pi,numframes+1);
   watchoff(wnumber);
   while get(axHndl,'Userdata')==play,
      for count=1:numframes,
         if get(axHndl,'Userdata')~=play, break; end;
         
         if n~=get(popupHndl,'Value'),
            n=get(popupHndl,'Value');
            del= x0(:,n);
            del=reshape([del' zeros(1,4)] ,2,10)';
         end;
         
         delnow=del*sin(t(count));
         [xd,yd]=gplot(a,xy+delnow);
         set(h,'xdata',xd,'ydata',yd);
         drawnow;
         pause(0.01)
      end;    % for count=...
   end;    % while get(axHndl,...
   
   % ====== End of Demo
   set([startHndl closeHndl infoHndl],'Enable','on');
   set(stopHndl,'Enable','off');
   
elseif strcmp(action,'info');
   helpwin(mfilename)
   
end;    % if strcmp(action, ...
