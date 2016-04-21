function print(sisodb,request)
%PRINT  Prints SISO Tool Editors to hard copy or separate figure.

%   Authors: K. Gondoly and P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/10 23:14:29 $

SISOfig = sisodb.Figure;

% Prints only the Editor views...
switch lower(request)
case 'print'
   printfig = figure('Visible','off','IntegerHandle','off');  % target figure
case 'print2fig'
   printfig = figure('Visible','off','Name',get(SISOfig,'Name'),'Units',get(SISOfig,'Units'));
   pp1 = get(SISOfig,'Position');
   pp2 = get(printfig,'Position');
   set(printfig,'Position',[pp2(1) pp2(2)-(pp1(4)-pp2(4)) pp1(3) pp1(4)]);
end

%---Copy visible editor axes
CopyAx = [];
for n=1:length(sisodb.PlotEditors)
   CopyAx = [CopyAx ; findobj(getaxes(sisodb.PlotEditors(n).Axes),'flat','Visible','on')];
end
h = copyobj(CopyAx,printfig);

%---Get current position of all axes
set(h,'Units','Normalized');
AllPos = get(h,{'Position'});
AllPos = cat(1,AllPos{:});
[MaxStartX,IndMaxX] = max(AllPos(:,1));
[MinStartX,IndMinX] = min(AllPos(:,1));
[MaxStartY,IndMaxY] = max(AllPos(:,2));
[MinStartY,IndMinY] = min(AllPos(:,2));
CurrentPos(1,1) = AllPos(IndMinX,1);
CurrentPos(1,2) = AllPos(IndMinY,2);
CurrentPos(1,3) = AllPos(IndMaxX,1)+AllPos(IndMaxX,3)-AllPos(IndMinX,1);
CurrentPos(1,4) = AllPos(IndMaxY,2)+AllPos(IndMaxY,4)-AllPos(IndMinY,2);

%---Resize axes to fill rectangle TargetPos
%%pos = get(0,'defaultaxesposition');
%TargetPos =[0.10 0.12 0.85 0.80];
TargetPos = [0.10 0.11 0.85 0.82];
remapfig(CurrentPos,TargetPos,printfig,h)

%---Map label visibility
for n=1:length(h)
   lab1 = get(CopyAx(n),{'Title','XLabel','YLabel'});
   lab1 = cat(1,lab1{:});
   vis1 = get(lab1,'Visible');
   lab2 = get(h(n),{'Title','XLabel','YLabel'});
   lab2 = cat(1,lab2{:});
   set(lab2,{'Visible'},vis1);
end

%---Turn off buttondownfcn, deletefcn, etc.
kids = allchild(h(:));
if iscell(kids)
   kids = cat(1,kids{:});
else
   kids = kids(:);
end
set([h(:);kids(:)],'DeleteFcn','','ButtonDownFcn','','UIContextMenu',[],'UserData',[],'Tag','');

% Clear appdata
for cnt = 1:length(h)
    if isappdata(h(cnt),'MWBYPASS_axis')
         rmappdata(h(cnt),'MWBYPASS_grid');
         rmappdata(h(cnt),'MWBYPASS_title');
         rmappdata(h(cnt),'MWBYPASS_xlabel');
         rmappdata(h(cnt),'MWBYPASS_ylabel');
         rmappdata(h(cnt),'MWBYPASS_axis');         
    end
end

%---Process request
switch lower(request)
case 'print'
   set(h,'Box','on')  % box around axis
   printdlg(printfig);
   close(printfig)
case 'print2fig'
   set(printfig,'Visible','on')
end
