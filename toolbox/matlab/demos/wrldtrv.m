function wrldtrv(action)
%WRLDTRV Show great circle flight routes around the globe.
%   This demonstration illustrates the Great       
%   Circle flight paths and distances between a    
%   number of cities around the world.             
%                                                  
%   Use the popup menus to select your city of     
%   origin and your city of destination. Then by   
%   pushing the "Fly" button, you can watch an     
%   animation of the flight between the two cities.
%   The distance between the two cities is also    
%   calculated.                                    
%                                                  
%   Use the "W. Hemisphere" and "E. Hemisphere"    
%   radio buttons to choose which hemisphere you   
%   want to view.                                  

%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.17 $  $Date: 2002/04/15 03:34:13 $

old_format=get(0,'Format');
if nargin<1,
   action='initialize';
end;

if strcmp(action,'initialize'),
   oldFigNumber=watchon;
   
   figNumber=figure( ...
      'Name','World Traveler', ...
      'NumberTitle','off', ...
      'Visible','off', ...
      'BackingStore','off');
   axes( ...
      'Units','normalized', ...
      'Position',[0.05 0.05 0.60 0.90], ...
      'Visible','off', ...
      'NextPlot','add');
   
   %===================================
   % Information for all buttons
   top=0.95;
   bottom=0.05;
   labelColor=[0.8 0.8 0.8];
   yInitPos=0.90;
   left=0.70;
   btnWid=0.25;
   btnHt=0.10;
   % Spacing between the button and the next command's label
   spacing=0.02;
   
   %====================================
   % The CONSOLE frame
   frmBorder=0.02;
   frmPos=[left-frmBorder bottom-frmBorder btnWid+2*frmBorder 0.9+2*frmBorder];
   h=uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',[0.5 0.5 0.5]);
   
   %====================================
   % The FLY button
   btnNumber=1;
   yPos=top-btnHt-(btnNumber-1)*(btnHt+spacing);
   labelStr='Fly';
   cmdStr='fly';
   callbackStr='wrldtrv(''fly'');';
   
   % Generic button information
   btnPos=[left yPos-spacing btnWid btnHt];
   flyHndl=uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %====================================
   % The ORIGIN CITY popup button
   btnNumber=2;
   yPos=top-btnHt-(btnNumber-1)*(btnHt+spacing);
   labelStr='Origin';
   popupStr=str2mat('Cape Town','Dakar','London','Miami','Moscow', ...
      'Nairobi','Natick','New Delhi','Riyadh','Sao Paulo');
   latLongData=[-34 18.3; 14.5 -17.5; 51.5 0; 25.7 -80; 55.7 37.5; ...
         1.3 36.8; 42.3 -71.4; 28.5 77.1; 24.5 46.6; -23.5 -46.5];
   
   % Generic button information
   btnPos1=[left yPos-spacing+btnHt/2 btnWid btnHt/2];
   btnPos2=[left yPos-spacing btnWid btnHt/2];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',btnPos1, ...
      'String',labelStr);
   popupHndl1=uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos2, ...
      'String',popupStr, ...
      'UserData',latLongData);
   
   %====================================
   % The DESTINATION CITY popup button
   btnNumber=3;
   yPos=top-btnHt-(btnNumber-1)*(btnHt+spacing);
   labelStr='Destination';
   
   % Generic button information
   btnPos1=[left yPos-spacing+btnHt/2 btnWid btnHt/2];
   btnPos2=[left yPos-spacing btnWid btnHt/2];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',btnPos1, ...
      'String',labelStr);
   popupHndl2=uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos2, ...
      'String',popupStr, ...
      'Value',10, ...
      'UserData',latLongData);
   
   %====================================
   % The WESTERN HEMISPHERE radio button
   btnNumber=4;
   yPos=top-btnHt-(btnNumber-1)*(btnHt+spacing);
   labelStr='W. Hemisphere';
   callbackStr='wrldtrv(''hemisphere'');';
   
   % Generic button information
   btnPos=[left yPos-spacing btnWid btnHt];
   westHndl=uicontrol( ...
      'Style','radiobutton', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Value',1, ...
      'Callback',callbackStr);
   
   %====================================
   % The EASTERN HEMISPHERE radio button
   btnNumber=5;
   yPos=top-btnHt-(btnNumber-1)*(btnHt+spacing);
   labelStr='E. Hemisphere';
   callbackStr='wrldtrv(''hemisphere'');';
   
   % Generic button information
   btnPos=[left yPos-spacing btnWid btnHt];
   eastHndl=uicontrol( ...
      'Style','radiobutton', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',labelStr, ...
      'Value',0, ...
      'Callback',callbackStr);
   
   %====================================
   % The INFO button
   labelStr='Info';
   callbackStr='wrldtrv(''info'')';
   infoHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %====================================
   % The CLOSE button
   labelStr='Close';
   callbackStr='close(gcf)';
   closeHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[left bottom btnWid btnHt], ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   % Uncover the figure
   hndlList=[popupHndl1 popupHndl2 westHndl eastHndl];
   set(figNumber, ...
      'Visible','on', ...
      'UserData',hndlList);
   % Now run the demo. With no arguments, "wrldtrv2" just draws the globe
   wrldtrv2;
   
   watchoff(oldFigNumber);
   figure(figNumber);
   
elseif strcmp(action,'fly'),
   %====================================
   axHndl=gca;
   figNumber=watchon;
   hndlList=get(figNumber,'Userdata');
   popupHndl1=hndlList(1);
   popupHndl2=hndlList(2);
   westHndl=hndlList(3);
   eastHndl=hndlList(4);
   
   % ====== Start of Demo
   % Wrldtrv problem
   city1Value=get(popupHndl1,'Value');
   city2Value=get(popupHndl2,'Value');
   city1Matrix=get(popupHndl1,'UserData');
   city2Matrix=get(popupHndl2,'UserData');
   city1=city1Matrix(city1Value,:);
   city2=city2Matrix(city2Value,:);
   wrldtrv2(city1,city2);
   
   % ====== End of Demo
   watchoff(figNumber);
   
elseif strcmp(action,'hemisphere'),
   axHndl=gca;
   figNumber=watchon;
   drawnow;
   hndlList=get(figNumber,'Userdata');
   popupHndl1=hndlList(1);
   popupHndl2=hndlList(2);
   westHndl=hndlList(3);
   eastHndl=hndlList(4);
   if gco==westHndl,
      view(-90,25);
      set(westHndl,'Value',1);
      set(eastHndl,'Value',0);
      popupStr=str2mat('Cape Town','Dakar','London','Miami','Moscow', ...
         'Nairobi','Natick','New Delhi','Riyadh','Sao Paulo');
      latLongData=[-34 18.3; 14.5 -17.5; 51.5 0; 25.7 -80; 55.7 37.5; ...
            1.3 36.8; 42.3 -71.4; 28.5 77.1; 24.5 46.6; -23.5 -46.5];
      set(popupHndl1,'String',popupStr,'UserData',latLongData);
      set(popupHndl2,'String',popupStr,'UserData',latLongData,'Value',10);
   else
      view(90,25);
      set(westHndl,'Value',0);
      set(eastHndl,'Value',1);
      popupStr=str2mat('Anchorage','Beijing','Guam','Honolulu','Natick', ...
         'San Diego','Singapore','Sydney','Tokyo','Wellington');
      latLongData=[61.2 -150; 40 116.4; 13.5 144.8; 21.3 -157.9; 42.3 -71.4; ...
            32.6 -117.2; 1.3 103.9; -33.9 151.2; 35.6 139.7; -41.3 174.8];
      set(popupHndl1,'String',popupStr,'UserData',latLongData);
      set(popupHndl2,'String',popupStr,'UserData',latLongData,'Value',10);
   end;
   watchoff(figNumber);
   
elseif strcmp(action,'info'),
   helpwin(mfilename)
   
end;    % if strcmp(action, ...

%  Restore Format
set(0,'Format',old_format)

function pos=wrldtrv2(city1,city2);
%WRLDTRV2 Calculate and plot great circle distances.
%   WRLDTRV2 is used by the demo WRLDTRV.

% East longitude is POSITIVE
% North latitude is POSITIVE
if nargin==0,
   %clf
   load('topo.mat','topo','topomap1');
   % Sphere of 24 makes 15 degrees between lat and long lines
   [x,y,z]=sphere(24);
   h=surface(x,y,z,'FaceColor','texture','CData',topo);
   
   % Now view the globe so the Greenwich meridian is directly
   % facing the viewer
   view(-90,25);
   colormap(topomap1);
   set(gca, ...
      'NextPlot','add', ...
      'Visible','off');
   axis equal
   set(get(gca,'Title'),'Visible','on')
   
elseif nargin==1,
   phi1=city1(1)*pi/180;
   tht1=(city1(2)+135)*pi/180+pi/4; 
   [xp1,yp1,zp1]=sph2cart(tht1,phi1,1);
   plot3(xp1,yp1,zp1,'r.', ...
      'MarkerSize',20, ...
      'EraseMode','none');
   pos=[xp1 yp1 zp1];
   
elseif nargin==2,
   phi1=city1(1)*pi/180;
   tht1=(city1(2)+135)*pi/180+pi/4; 
   [xp1,yp1,zp1]=sph2cart(tht1,phi1,1);
   city1Hndl=plot3(xp1,yp1,zp1,'r.', ...
      'Color','red', ...
      'Marker','^', ...
      'MarkerSize',12, ...
      'LineWidth',4, ...
      'EraseMode','none');
   
   phi2=city2(1)*pi/180;
   tht2=(city2(2)+135)*pi/180+pi/4; 
   [xp2,yp2,zp2]=sph2cart(tht2,phi2,1);
   city2Hndl=plot3(xp2,yp2,zp2, ...
      'Color','red', ...
      'Marker','^', ...
      'MarkerSize',12, ...
      'LineWidth',4, ...
      'EraseMode','none');
   
   out=cross([xp2 yp2 zp2],[xp1 yp1 zp1]);
   [tht3,phi3,r]=cart2sph(out(1),out(2),out(3));
   h=plot3(xp1,yp1,zp1,'y.', ...
      'MarkerSize',12, ...
      'EraseMode','none');
   
   % Following calculation uses Napier's Spherical 
   % Trigonometry Cosine Rule for Sides
   % Ref: VNR Encyclopedia of Mathematics
   angularDistCos=sin(phi1)*sin(phi2)+cos(phi1)*cos(phi2)*cos(tht1-tht2);
   angularDist=acos(angularDistCos)*180/pi;
   % Earth radius in miles: 3963
   earthRadius=3963;
   distance=(angularDist*pi/180)*earthRadius;
   format bank;
   title(['Distance = ',num2str(distance,'%15.0f'),' miles']);
   format;
   drawnow;
   for count=1:2:angularDist,
      rotate(h,[tht3*180/pi phi3*180/pi],-2,[0 0 0]);
      drawnow;
   end;
   
   pos=[xp1 yp1 zp1];
   delete([city1Hndl city2Hndl h]);
   
end;