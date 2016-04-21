function ViewHandle = histview(sisodb)
%HISVIEW  Manages the SISO Tool history view.

%   Author(s): K. Gondoly and P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/10 23:14:28 $

% Open figure 
ViewHandle = LocalOpenView(sisodb);

%----------------- Local functions -----------------


%%%%%%%%%%%%%%
% LocalClose %
%%%%%%%%%%%%%%
function LocalClose(hSrc,event,ViewHandle)
% Callback when closing SISO Tool
delete(ViewHandle);


%%%%%%%%%%%%%%%%%%%
%%% LocalUpdate %%%
%%%%%%%%%%%%%%%%%%%
function LocalUpdate(hSrc,event,hList)
% Update text
set(hList,'String',event.NewValue)


%%%%%%%%%%%%%%%%%
%%% LocalSave %%%
%%%%%%%%%%%%%%%%%
function LocalSave(hSrc,event,sisodb)

% Get history text
HistoryText = sisodb.EventManager.gethistory;

[HistoryFile,HistoryPath] = uiputfile('SISOhistory.txt','Save SISO History');

if HistoryFile,
   CurrentDir = pwd;
   cd(HistoryPath);
   fid = fopen(HistoryFile,'wt');
   if fid>0,
      fprintf(fid,'%s\n',HistoryText{:});
      fclose(fid);
   else
      %---Error opening desired file
      warndlg({'The history could not be written to the file you specified.'; ...
            ''; ...
            'Make sure you are not trying to save to a read-only file or directory.'}, ...
         'Save History Error');
   end
   cd(CurrentDir)
end

   
%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenView %%%
%%%%%%%%%%%%%%%%%%%%%
function HistoryFig = LocalOpenView(sisodb)

if isunix
    FontSize = 12;
else
    FontSize = 10;
end

FigPos = [10 10 60 18];
StdColor = get(0,'DefaultUIcontrolBackgroundColor');

HistoryFig = figure('Color',StdColor, ...
    'IntegerHandle','off', ...
    'MenuBar','none', ...
    'Name','Design History', ...
    'NumberTitle','off', ...
    'Unit','character', ...
    'Position',FigPos, ...
    'HandleVisibility','Callback',...
    'Visible','off',...
    'Tag','HistoryView',...
    'DockControls', 'off');

centerfig(HistoryFig,sisodb.Figure);

% Compute object positions
[HistPos,SavePos,OKPos] = LocalLayout(FigPos);

HistoryList = uicontrol('Parent',HistoryFig, ...
    'Units','character', ...
    'BackgroundColor',[1 1 1], ...
    'Position',[2 2.5 56 15], ...
    'FontSize',FontSize,...
    'String',sisodb.EventManager.gethistory,...
    'Style','listbox');

OKButton = uicontrol('Parent',HistoryFig, ...
    'Callback','close(gcbf)',...
    'Unit','character',...
    'Position',[48 0.5 10 1.5], ...
    'String','OK');

SaveButton = uicontrol('Parent',HistoryFig, ...
    'Callback',{@LocalSave sisodb},...
    'Unit','character',...
    'Position',[2 0.5 20 1.5], ...
    'String','Save to Text File');

% Install listners
Listeners(1) = handle.listener(sisodb.LoopData,...
    'ObjectBeingDestroyed',{@LocalClose HistoryFig});
Listeners(2) = handle.listener(sisodb,findprop(sisodb,'History'),...
    'PropertyPostSet',{@LocalUpdate HistoryList});

% Install CS help
cshelp(HistoryFig,sisodb.Figure);

set(HistoryFig,...
    'UserData',Listeners,...
    'Visible','on',...
    'ResizeFcn',{@LocalResize [HistoryList,SaveButton,OKButton]})


%%%%%%%%%%%%%%%%%%%
%%% LocalResize %%%
%%%%%%%%%%%%%%%%%%%
function LocalResize(hSrc,event,Handles)

[HistPos,SavePos,OKPos] = LocalLayout(get(hSrc,'Position'));
set(Handles(1),'Position',HistPos)
set(Handles(2),'Position',SavePos)
set(Handles(3),'Position',OKPos)


%%%%%%%%%%%%%%%%%%%
%%% LocalLayout %%%
%%%%%%%%%%%%%%%%%%%
function [HistPos,SavePos,OKPos] = LocalLayout(FigPos)

HistPos = [2 2.5 FigPos(3)-4 FigPos(4)-3];
SavePos = [2 0.5 20 1.5];
OKPos = [FigPos(3)-12 0.5 10 1.5];
