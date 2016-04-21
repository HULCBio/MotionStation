function ViewHandle = clview(sisodb)
%CLVIEW  Creates and manages the closed-loop data view.
%
%   See also SISOTOOL.

%   Author(s): K. Gondoly, modified P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/04/10 23:14:22 $

% Open closed-loop pole view
ViewHandle = LocalOpenView(sisodb);

% Display pole data
LocalUpdateData(sisodb.LoopData,[],ViewHandle);


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%
% LocalCloseCB %
%%%%%%%%%%%%%%%%
function LocalCloseCB(hSrc,event,ViewHandle)
% Callback when closing SISO Tool
delete(ViewHandle);

   
%%%%%%%%%%%%%%%%%%%
% LocalUpdateData %
%%%%%%%%%%%%%%%%%%%
function LocalUpdateData(LoopData,event,ViewHandle)
% Update view

Ud = get(ViewHandle,'UserData');
StdColor = get(Ud.Frame,'BackgroundColor');

% Get closed-loop poles
% RE: Use same algorithm as in RLEDITOR/UPDATEPLOT for consistency
OL = getopenloop(LoopData);
if isempty(OL)
   P = [];
else
   P = fastrloc(OL,getzpkgain(LoopData.Compensator,'mag'));
end

% Group the Poles into real and complex values
im = imag(P);
P = [P(~im,:) ; P(im>0,:)];

% Dimension figure
FigureHeight = 5+1.7*max(1,length(P));
Pos = get(ViewHandle,'Position');
set(ViewHandle,'Position',[Pos(1:3) FigureHeight])
Pos = get(Ud.Frame,'Position');
set(Ud.Frame,'Position',[Pos(1:3) FigureHeight-3])
Pos = get(Ud.CLText,'Position');
set(Ud.CLText,'Position',[Pos(1) FigureHeight-2.2 Pos(3:4)])

% Add text for pole data
delete(Ud.PoleText(ishandle(Ud.PoleText)))
if isempty(P)
   Ud.PoleText = uicontrol('Parent',ViewHandle, ...
      'Units','Character', ...
      'BackgroundColor',StdColor, ...
      'HorizontalAlignment','center', ...
      'Position',[3 FigureHeight-3.3 29 1.3], ...
      'String','<None>', ...
      'Style','text');
else
   Ud.PoleText = zeros(size(P));
   for ctP=1:length(P),
      Ud.PoleText(ctP) = uicontrol('Parent',ViewHandle, ...
         'Units','Character', ...
         'BackgroundColor',StdColor, ...
         'HorizontalAlignment','left', ...
         'Position',[5 FigureHeight-1.9-(ctP*1.7) 25 1.3], ...
         'Style','text');
      rP = real(P(ctP));
      iP = imag(P(ctP));
      if iP
         set(Ud.PoleText(ctP),'String',...
            sprintf('%0.3g %s %0.3gi',rP,char(177),iP))
      else
         set(Ud.PoleText(ctP),'String',sprintf('%0.3g',rP))
      end
   end
end

set(ViewHandle,'UserData',Ud)


%%%%%%%%%%%%%%%%%
% LocalOpenView %
%%%%%%%%%%%%%%%%%
function ViewHandle = LocalOpenView(sisodb)

StdColor = get(0,'DefaultUIcontrolBackgroundColor');
FigureHeight = 6.7;

% Handles
Ud = struct(...
   'Frame',[],...
   'CLText',[],...
   'PoleText',[],...
   'Listener',[]);
   
% Main figure
ViewHandle = figure('Color',StdColor, ...
   'IntegerHandle','off', ...
   'MenuBar','none', ...
   'Name','Closed Loop', ...
   'NumberTitle','off', ...
   'HandleVisibility','callback',...
   'Resize','off', ...
   'Unit','Character',...
   'Visible','off',...
   'Tag','CLView',...
   'Position',[18 10 35 FigureHeight],...
   'DockControls', 'off');

centerfig(ViewHandle,sisodb.Figure);

% Install listeners
LoopData = sisodb.LoopData;
Listeners(1) = handle.listener(LoopData,...
    'ObjectBeingDestroyed',{@LocalCloseCB ViewHandle});
Listeners(2) = handle.listener(LoopData,...
    'LoopDataChanged',{@LocalUpdateData ViewHandle});
Ud.Listener = Listeners;

Ud.Frame = uicontrol('Parent',ViewHandle, ...
   'Units','Character', ...
   'BackgroundColor',StdColor, ...
   'Position',[1 2.6 33 FigureHeight-3], ...
   'Style','frame');
Ud.CLText = uicontrol('Parent',ViewHandle, ...
   'Units','Character', ...
   'BackgroundColor',StdColor, ...
   'FontWeight','Bold', ...
   'Position',[3 FigureHeight-2.2 29 1.5], ...
   'String','Pole Values:', ...
   'Style','text');
uicontrol('Parent',ViewHandle, ...
   'Units','Character', ...
   'Position',[12.5 0.3 10 2], ...
   'Callback','close(gcbf)',...
   'String','OK');

% Install CS help
% RE: Do this last for proper initialization when opened while CS help is on
cshelp(ViewHandle,sisodb.Figure);

set(ViewHandle,'UserData',Ud,'Visible','on')
