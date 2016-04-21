function print(this,Device)
%PRINT  Print LTI Viewer

%   Author: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $  $Date: 2004/04/10 23:14:41 $

printsetup(this,{'Visible'},{'off'});
layout(this);
switch Device
case 'printer'
   localPrintToPaper(this);
 case 'figure'
   localPrintToFigure(this);
end
printsetup(this,{'Visible'},{'on'});
layout(this);

%%%%%%%%%%%%%%%%%%%%%
% localPrintToPaper %
%%%%%%%%%%%%%%%%%%%%%
function localPrintToPaper(this)
%---Print to paper

% if paperposition mode is manual create hidden figure to print from 
% to prevent viewer from resizing to actual print size during printing
if strcmpi(get(this.Figure,'PaperPositionMode'),'manual')
    PrintProperties=struct(...,
        'PaperType', get(this.Figure,'PaperType'),...
        'PaperUnits', get(this.Figure,'PaperUnits'), ...
        'PaperPosition', get(this.Figure,'PaperPosition'), ...
        'PaperPositionMode', get(this.Figure,'PaperPositionMode'),...
        'PaperOrientation', get(this.Figure,'PaperOrientation'), ...
        'PrintTemplate',get(this.Figure,'PrintTemplate'),...
        'InvertHardcopy', get(this.Figure,'InvertHardcopy'));
    tempfig = localPrintToFigure(this);
    set(tempfig,PrintProperties)
    printdlg(double(tempfig));
    delete(tempfig);
    figure(double(this.Figure))
else
    set(this.Figure,'PaperPositionMode','auto');
    printdlg(double(this.Figure));
end

%%%%%%%%%%%%%%%%%%%%%%
% localPrintToFigure %
%%%%%%%%%%%%%%%%%%%%%%
function newfig = localPrintToFigure(this)
%----Print to figure
%---New figure
printfig = figure('Visible','off','Name','LTI Viewer Responses','Units',get(this.Figure,'Units'));
%---Match figure size (but not necessarily location)
pp1 = get(this.Figure,'Position');
pp2 = get(printfig,'Position');
set(printfig,'Position',[pp2(1) pp2(2)-(pp1(4)-pp2(4)) pp1(3) pp1(4)]);
%---Copy visible view axes
CopyAx = []; BackAx = [];
for n=find(ishandle(this.Views))',
   CopyAx = [CopyAx ; findobj(getaxes(this.Views(n,1).AxesGrid),'flat','Visible','on')];
   BackAx = [BackAx ; get(this.Views(n,1).AxesGrid,'BackgroundAxes')];
end
% ---- Get the labels
labels1 = [get([BackAx],{'XLabel','YLabel','Title'});...
        get([CopyAx],{'XLabel','YLabel','Title'})];
if ~iscell(labels1)
    labels1 = {labels1};
end
labels1 = reshape([labels1{:,:}],size(labels1));
%---- Get label properties
PropVal = get(labels1,{'Position','Visible','Color'});
%
%---- Copy background axes to the new figure
%
B = copyobj(BackAx,printfig);
h = copyobj(CopyAx,printfig);
%
%---- Get the axes object properties
labels2 = get([B;h],{'XLabel','YLabel','Title'});
if ~iscell(labels2)
    labels2 = {labels2};
end
labels2 = reshape([labels2{:,:}],size(labels2));
%---- Apply old properties.
set(labels2,{'Position','Visible','Color'},PropVal)
set(labels2,'Units','Normalized');
%---Turn off buttondownfcn, deletefcn, etc.
set([h(:);B(:)],'Units','Normalized');
kids = get(h,{'children'});
if iscell(kids)
    kids = cat(1,kids{:});
else
    kids = kids(:);
end
%---Clear all callbacks/uicontextmenus/tags/userdata associated with new copies
set([h(:);kids(:)],'DeleteFcn','','ButtonDownFcn','','UIContextMenu',[],'UserData',[],'Tag','');
%
% Clear appdata
for cnt = 1:length(h)
    if isappdata(h(cnt),'WaveRespPlot')
         rmappdata(h(cnt),'MWBYPASS_grid');
         rmappdata(h(cnt),'MWBYPASS_title');
         rmappdata(h(cnt),'MWBYPASS_xlabel');
         rmappdata(h(cnt),'MWBYPASS_ylabel');
         rmappdata(h(cnt),'MWBYPASS_axis');
         rmappdata(h(cnt),'WaveRespPlot');
    end
end

if nargout == 0
    %---Enable visibility
    set(printfig,'Visible','on');
else
    newfig = handle(printfig);
end
