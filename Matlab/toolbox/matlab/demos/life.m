function life(action)
%LIFE   MATLAB's version of Conway's Game of Life.
%   "Life" is a cellular automaton invented by John
%   Conway that involves live and dead cells in a  
%   rectangular, two-dimensional universe. In      
%   MATLAB, the universe is a sparse matrix that   
%   is initially all zero.                         
%                                                  
%   Whether cells stay alive, die, or generate new 
%   cells depends upon how many of their eight     
%   possible neighbors are alive. By using sparse  
%   matrices, the calculations required become     
%   astonishingly simple. We use periodic (torus)  
%   boundary conditions at the edges of the        
%   universe. Pressing the "Start" button          
%   automatically seeds this universe with several 
%   small random communities. Some will succeed    
%   and some will fail.     

%   C. Moler, 7-11-92, 8-7-92.
%   Adapted by Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 03:34:09 $

% Possible actions:
% initialize
% start

% Information regarding the play status will be held in
% the axis user data according to the following table:
play= 1;
stop=-1;

if nargin<1,
   action='initialize';
end;

if strcmp(action,'initialize'),
   figNumber=figure( ...
      'Name','Life: Conway''s Game of Life', ...
      'NumberTitle','off', ...
      'DoubleBuffer','on', ...
      'Visible','off', ...
      'Color','white', ...
      'BackingStore','off');
   axes( ...
      'Units','normalized', ...
      'Position',[0.05 0.05 0.75 0.90], ...
      'Visible','off', ...
      'DrawMode','fast', ...
      'NextPlot','add');
   
   text(0,0,'Press the "Start" button to see the Game of Life demo', ...
      'HorizontalAlignment','center');
   axis([-1 1 -1 1]);
   
   %===================================
   % Information for all buttons
   labelColor=[0.8 0.8 0.8];
   yInitPos=0.90;
   xPos=0.85;
   btnLen=0.10;
   btnWid=0.10;
   % Spacing between the button and the next command's label
   spacing=0.05;
   
   %====================================
   % The CONSOLE frame
   frmBorder=0.02;
   yPos=0.05-frmBorder;
   frmPos=[xPos-frmBorder yPos btnLen+2*frmBorder 0.9+2*frmBorder];
   h=uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',[0.50 0.50 0.50]);
   
   %====================================
   % The START button
   btnNumber=1;
   yPos=0.90-(btnNumber-1)*(btnWid+spacing);
   labelStr='Start';
   cmdStr='start';
   callbackStr='life(''start'');';
   
   % Generic button information
   btnPos=[xPos yPos-spacing btnLen btnWid];
   startHndl=uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Interruptible','on', ...
      'Callback',callbackStr);
   
   %====================================
   % The STOP button
   btnNumber=2;
   yPos=0.90-(btnNumber-1)*(btnWid+spacing);
   labelStr='Stop';
   % Setting userdata to -1 (=stop) will stop the demo.
   callbackStr='set(gca,''Userdata'',-1)';
   
   % Generic button information
   btnPos=[xPos yPos-spacing btnLen btnWid];
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
   callbackStr='life(''info'')';
   infoHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[xPos 0.20 btnLen 0.10], ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %====================================
   % The CLOSE button
   labelStr='Close';
   callbackStr='close(gcf)';
   closeHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[xPos 0.05 btnLen 0.10], ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   % Uncover the figure
   hndlList=[startHndl stopHndl infoHndl closeHndl];
   set(figNumber,'Visible','on', ...
      'UserData',hndlList);
   
elseif strcmp(action,'start'),
   cla;
   axHndl=gca;
   figNumber=gcf;
   hndlList=get(figNumber,'Userdata');
   startHndl=hndlList(1);
   stopHndl=hndlList(2);
   infoHndl=hndlList(3);
   closeHndl=hndlList(4);
   set([startHndl closeHndl infoHndl],'Enable','off');
   set(stopHndl,'Enable','on');
   
   % ====== Start of Demo
   set(axHndl, ...
      'UserData',play, ...
      'DrawMode','fast', ...
      'Visible','off');
   m = 101;
   X = sparse(m,m);
   
   p = -1:1;
   for count=1:15,
      kx=floor(rand*(m-4))+2; ky=floor(rand*(m-4))+2; 
      X(kx+p,ky+p)=(rand(3)>0.5);
   end;
   
   % The following statements plot the initial configuration.
   % The "find" function returns the indices of the nonzero elements.
   [i,j] = find(X);
   figure(gcf);
   plothandle = plot(i,j,'.', ...
      'Color','blue', ...
      'MarkerSize',12);
   axis([0 m+1 0 m+1]);
   
   % Whether cells stay alive, die, or generate new cells depends
   % upon how many of their eight possible neighbors are alive.
   % Here we generate index vectors for four of the eight neighbors.
   % We use periodic (torus) boundary conditions at the edges of the universe.
   
   n = [m 1:m-1];
   e = [2:m 1];
   s = [2:m 1];
   w = [m 1:m-1];
   
   while get(axHndl,'UserData')==play,
      % How many of eight neighbors are alive.
      N = X(n,:) + X(s,:) + X(:,e) + X(:,w) + ...
         X(n,e) + X(n,w) + X(s,e) + X(s,w);
      
      % A live cell with two live neighbors, or any cell with three
      % neigbhors, is alive at the next time step.
      X = (X & (N == 2)) | (N == 3);
      
      % Update plot.
      [i,j] = find(X);
      set(plothandle,'xdata',i,'ydata',j)
      drawnow
   end
   
   % ====== End of Demo
   set([startHndl closeHndl infoHndl],'Enable','on');
   set(stopHndl,'Enable','off');
   
elseif strcmp(action,'info');
   helpwin(mfilename);
   
end;    % if strcmp(action, ...
