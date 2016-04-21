function hList=figloopfigures
%FIGLOOPFIGURES creates figures for figloop-tutorial.rpt
%   FIGLOOPFIGURES creates five figures which are used by
%   the Report Generator setup file "figloop-tutorial.rpt".
%   To run this tutorial, type "setedit figloop-tutorial"
%   at the command prompt.
%
%   Figure 1: Membrane Data
%   Figure 2: Invisible Membrane Data
%   Figure 3: An Application
%   Figure 4: An Invisible Application
%   Figure 5: Peaks Data
%
%   Figures 2 and 4 are invisible.
%   Figures 3 and 4 have HandleVisibility='off'
%   Figure  5 is the current figure
%
%   FIGLOOPFIGURES deletes any existing figures which have
%   tag 'peaks' 'app' or 'membrane'

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:57 $


%delete existing figures with used tag names
allFigs=allchild(0);
delete([findall(allFigs,'flat','tag','membrane');...
   findall(allFigs,'flat','tag','peaks');...
   findall(allFigs,'flat','tag','app')]);

figName={'Membrane Data'
   'Invisible Membrane Data'
   'An Application'
   'An Invisible Application'
   'Peaks Data'};
figTag={'membrane'
   'membrane'
   'app'
   'app'
   'peaks'};
figVisible={'on'
   'off'
   'on'
   'off'
   'on'};
figHandleVisible={'on'
   'on'
   'off'
   'off'
   'on'};

for i=1:length(figName)
   hList(i)=figure('Name',figName{i},...
      'Tag',figTag{i},...
      'HandleVisibility',figHandleVisible{i},...
      'Visible','off',...
      'Units','points',...
      'Position',[90+30*i 230-30*i 200 200]);
end


LocalMakeMembrane(hList(1));
LocalMakeMembrane(hList(2));
LocalMakeApplication(hList(3),'Push Me');
LocalMakeApplication(hList(4),'Invisible');
LocalMakePeaks(hList(5));

set(hList,{'Visible'},figVisible);
set(0,'CurrentFigure',hList(5));

drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMakeMembrane(h)

ax=axes('Parent',h,...
   'Xlim',[0 31],...
   'Ylim',[0 31],...
   'Xgrid','on',...
   'Ygrid','on',...
   'Zgrid','on',...
   'View',[-37.5 35]);
surface(membrane,'Parent',ax);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMakeApplication(h,btnString)

figWd=200;
figHt=200;

btn=uicontrol('Parent',h,...
   'String',btnString,...
   'FontSize',18,...
   'Units','points');

btnExtent=get(btn,'Extent');
btnHt=btnExtent(4)+10;
btnWd=btnExtent(3)+10;

cbString=sprintf('set(gcbo,''Position'',[rand(1)*%0.2g rand(1)*%0.2g %0.2g %0.2g])',...
   figWd-btnWd-10,figHt-btnHt-10,btnWd,btnHt);

set(btn,...
   'Position',[10 10 btnWd btnHt],...
   'Callback',cbString);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMakePeaks(h)

pSize=49;
pData=peaks(pSize);

ax=axes('Parent',h,...
   'View',[-37.5 30],...
   'Visible','off',...
   'Xlim',[0 pSize],...
   'Ylim',[0 pSize],...
   'Zlim',[min(min(pData)) max(max(pData))],...
   'Units','normalized',...
   'Position',[0 0 1 1]);

surface(pData,...
   'Parent',ax,...
   'FaceLighting','gouraud',...
   'edgecolor','none');
light('Parent',ax);