function travel(action)
%TRAVEL Traveling salesman problem demonstration.
%   This demo animates the solution of the          
%   so-called "Traveling Salesman" problem.         
%   The problem is to form a closed circuit of a    
%   number of cities while traveling the shortest   
%   total distance along the way.                   
%                                                   
%   The algorithm this demo uses is very simple,    
%   and so the emphasis here is more on the         
%   animation than on rapid, efficient solution.    
%                                                  
%   Use the "Cities" popup menu to determine the    
%   number of cities to be visited. The "Start"     
%   and "Stop" buttons control the animation. Cities
%   are chosen completely at random.         

%   Ned Gulley, 6-21-93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.21.4.2 $  $Date: 2004/04/10 23:25:50 $

% Information regarding the play status will be held in
% the axis user data according to the following table:
play= 1;
stop=-1;

if nargin<1,
   action='initialize';
end;

switch action
case 'initialize',
   oldFigNumber=watchon;
   
   figNumber=figure( ...
      'Name','Travel: The Traveling Salesman Problem', ...
      'NumberTitle','off', ...
      'Visible','off', ...
      'DoubleBuffer','on', ...
      'Color', [0 0 0], ...
      'BackingStore','off');
   axes( ...
      'Units','normalized', ...
      'Position',[0.05 0.05 0.75 0.90], ...
      'Visible','off', ...
      'NextPlot','add');
   
   text(0,0,'Press the "Start" button to see the Traveling Salesman demo', ...
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
      'BackgroundColor',[0.50 0.50 0.50]);
   
   %====================================
   % The START button
   btnNumber=1;
   yPos=0.90-(btnNumber-1)*(btnHt+spacing);
   labelStr='Start';
   cmdStr='start';
   callbackStr='travel(''start'');';
   
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
   % The CITIES popup button
   btnNumber=2;
   yPos=0.90-(btnNumber-1)*(btnHt+spacing);
   textStr='Cities';
   popupStr=reshape(' 15  20  25  30  35  40  45  50 ',4,8)';
   
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
      'Value',4, ...t
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
   callbackStr='travel(''info'')';
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
   set(figNumber, ...
      'Visible','on', ...
      'UserData',hndlList);
   watchoff(oldFigNumber);
   figure(figNumber);
   
case 'start',
   WNumber=watchon;
   axHndl=gca;
   figNumber=gcf;
   hndlList=get(figNumber,'Userdata');
   startHndl=hndlList(1);
   popupHndl=hndlList(2);
   stopHndl=hndlList(3);
   infoHndl=hndlList(4);
   closeHndl=hndlList(5);
   set([startHndl closeHndl infoHndl],'Enable','off');
   set(stopHndl,'Enable','on');
   set(axHndl,'Userdata',play);
   set(popupHndl, 'Enable', 'off');
   % ====== Start of Demo
   % Travel problem
   % This is the main program for the Traveling Salesman Problem.
   % This function makes use of the following other functions:
   % inside
   
   % Lay down a picture of the United States for graphic appeal.
   load('usborder.mat','x','y','xx','yy');
   % The file usborder.mat contains a map of the US in the variables
   % x and y, and a geometrically simplified version of the same map
   % in the variables xx and yy.
   cla;
   plot(x,y,'Color','cyan');
   axis off;
   axis([-0.1 1.5 -0.2 1.2]);
   set(axHndl,'Drawmode','Fast');
   hold on;
   drawnow;
   
   nptsStr=get(popupHndl,'String');
   nptsVal=get(popupHndl,'Value');
   
   npts=str2double(nptsStr(nptsVal,:));
   set(popupHndl, 'Enable', 'off');
   % ...else generate the random cities to visit
   X=[];
   Y=[];
   % Form the US border in imaginary coords for the INSIDE routine
   w=xx+i*yy;
   n=0;
   while n<npts,
      a=rand*1.4+i*rand;
      if inside(a,w),
         X=[X; real(a)];
         Y=[Y; imag(a)];
         n=n+1;
      end;
   end;
   xy=[X Y];
   
   % Calculate the distance matrix for all of the cities
   distmatrix = zeros(npts);
   for count1=1:npts,
      for count2=1:count1,
         x1 = xy(count1,1);
         y1 = xy(count1,2);
         x2 = xy(count2,1);
         y2 = xy(count2,2);
         distmatrix(count1,count2)=sqrt((x1-x2)^2+(y1-y2)^2);
         distmatrix(count2,count1)=distmatrix(count1,count2);
      end;
   end;
   
   % Generate an initial random path between those cities
   p=randperm(npts);
   
   newxy=xy(p,:);
   newxy=[newxy; newxy(1,:)];
   xdata=newxy(:,1);
   ydata=newxy(:,2);
   watchoff(WNumber);
   plot(xdata,ydata,'r.','Markersize',24);
   plothandle=plot(xdata,ydata,'yellow','LineWidth',2);
   axis off;
   drawnow;
   
   len=LocalPathLength(p,distmatrix);
   lenhist=len;
   
   while get(axHndl,'Userdata')==play,
      drawnow;
      drawFlag=0;
      
      % Try a point for point swap
      % ========================
      swpt1=floor(npts*rand)+1;
      swpt2=floor(npts*rand)+1;
      
      swptlo=min(swpt1,swpt2);
      swpthi=max(swpt1,swpt2);
      
      order=1:npts;
      order(swptlo:swpthi)=order(swpthi:-1:swptlo);
      pnew = p(order);
      
      lennew=LocalPathLength(pnew,distmatrix);
      if lennew<len,
         p=pnew;
         len=lennew;
         drawFlag=1;
      end;
      % ========================
      
      % Try a single point insertion
      % ========================
      swpt1=floor(npts*rand)+1;
      swpt2=floor((npts-1)*rand)+1;
      
      order=1:npts;
      order(swpt1)=[];
      order=[order(1:swpt2) swpt1 order((swpt2+1):(npts-1))];
      pnew = p(order);
      
      lennew=LocalPathLength(pnew,distmatrix);
      if lennew<len,
         p=pnew;
         len=lennew;
         drawFlag=1;
      end
      
      if drawFlag,
         newxy=xy(p,:);
         newxy=[newxy; newxy(1,:)];
         xdata=newxy(:,1);
         ydata=newxy(:,2);
         set(plothandle,'XData',xdata,'YData',ydata);
         drawnow;
      end;
      % ========================
   end;
   
   % ====== End of Demo
   set([startHndl closeHndl infoHndl],'Enable','on');
   set(stopHndl,'Enable','off');
   set(popupHndl, 'Enable', 'on');
case 'info',
   helpwin(mfilename)
   
end;    % if strcmp(action, ...

function total=LocalPathLength(p,distmatrix)
% Calculate current path length for traveling salesman problem.
% This function calculates the total length of the current path
% p in the traveling salesman problem.

npts = size(p,2);
% This is a vectorized distance calculation
%
% We're creating two vectors: p and p([end 1:(end-1)]
% The first is the list of first cities in any leg, and the second
% is the list of destination cities for that same leg.
% (the second vector is an element-shift-right version of the first)
% 
% We then use column indexing into distmatrix to create a vector of
% lengths of each leg which can then be summed.
total=sum(distmatrix((p-1)*npts + p([end 1:(end-1)])));

