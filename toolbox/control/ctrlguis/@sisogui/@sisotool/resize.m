function resize(sisodb)
%RESIZE  Resize function for the SISO Tool GUI.

%   Authors: Karen D. Gondoly   10-21-98
%            P. Gahinet (UDD)
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 04:58:58 $

% RE: The figure position should be in character units

%---Get the new figure position
SISOfig = sisodb.Figure;
HG = sisodb.HG;
FigPos = get(SISOfig,'Position');

%---Set the minimum figure width and height
MinFigHeight = 20;
MinFigWidth = 84; 
ResizeFlag = 0;
if FigPos(3) < MinFigWidth
   FigPos(3)=MinFigWidth;
   ResizeFlag=1;
end
if FigPos(4) < MinFigHeight
   FigPos(4)=MinFigHeight;
   ResizeFlag=1;
end

%---Expand the figure to its minimum height and width
if ResizeFlag
   set(SISOfig,'Position',FigPos);
end

%---Scale the width of the UIcontrols
StatusFrame = HG.StatusFrame;
StatusPos = get(StatusFrame.FrameHandle,'Position');
set(StatusFrame.FrameHandle,'Position', ...
   [StatusPos(1:2),FigPos(3)-5,StatusPos(4)]);
StatusPos = get(StatusFrame.StatusText,'Position');
set(StatusFrame.StatusText,'Position',...
   [StatusPos(1:2),FigPos(3)-7,StatusPos(4)]);

%---Compensator frame
CompFrame = HG.CompensatorFrame;
CompFramePos = get(CompFrame.FrameHandle,'Position');
NewFramePos = [CompFramePos(1),FigPos(4)-4.8,FigPos(3)-31.5,CompFramePos(4)];

Vshift = NewFramePos(2) - CompFramePos(2);  % vertical shift of frame objects
CompTextPos = get(CompFrame.CompensatorText,'Position');
set(CompFrame.CompensatorText,'Position',...
   [CompTextPos(1),NewFramePos(2)+NewFramePos(4)-0.55,CompTextPos(3:4)]);
DomainTextPos = get(CompFrame.DomainText,'Position');
set(CompFrame.DomainText,'Position',DomainTextPos+[0 Vshift 0 0])
GainPos = get(CompFrame.GainEdit,'Position');
set(CompFrame.GainEdit,'Position',GainPos+[0 Vshift 0 0]);
MultPos = get(CompFrame.Multiply,'Position');
set(CompFrame.Multiply,'Position',MultPos+[0 Vshift 0 0]);

% w=(z-1)/Ts display. Eshift = horizontal shift of frame end
Eshift = (NewFramePos(1)+NewFramePos(3)) - (CompFramePos(1)+CompFramePos(3));
Pos = get(CompFrame.wText(1),'Position');
set(CompFrame.wText(1),'Position',[Pos(1)+Eshift,Pos(2)+Vshift,Pos(3:4)])
Pos = get(CompFrame.wText(2),'Position');
wExtent = Pos(3) * strcmp(get(CompFrame.wText(2),'Visible'),'on');
set(CompFrame.wText(2),'Position',[Pos(1)+Eshift,Pos(2)+Vshift,Pos(3:4)])
Pos = get(CompFrame.wText(3),'Position');
set(CompFrame.wText(3),'Position',[Pos(1)+Eshift,Pos(2)+Vshift,Pos(3:4)])

% NUM/DEN display. 
DenTextPos = get(CompFrame.DenText,'Position');
set(CompFrame.DenText,'Position',...
   [DenTextPos(1),DenTextPos(2)+Vshift,DenTextPos(3:4)]);
NumTextPos = get(CompFrame.NumText,'Position');
set(CompFrame.NumText,'Position',...
   [NumTextPos(1),NumTextPos(2)+Vshift,NumTextPos(3:4)]);
FracTextPos = get(CompFrame.FractionText,'Position');
set(CompFrame.FractionText,'Position',...
   [FracTextPos(1),FracTextPos(2)+Vshift,FracTextPos(3:4)]);
% Reset frame position (triggers adjustment of num/den width)
set(CompFrame.FrameHandle,'Position',NewFramePos);

% Configuration frame
ConfigFrame = HG.LoopConfigFrame;
ConfigAxPos = get(ConfigFrame.ConfigAxes,'Position');
Xstart = FigPos(3)-27.5;
Ystart = FigPos(4)-4.8;
set(ConfigFrame.ConfigAxes,'Position',[Xstart,Ystart,ConfigAxPos(3:4)]);
SignPos = get(ConfigFrame.ChangeSign,'Position');
set(ConfigFrame.ChangeSign,'Position',[Xstart,Ystart,SignPos(3:4)]);
ConfigPos = get(ConfigFrame.ChangeConfig,'Position');
set(ConfigFrame.ChangeConfig,'Position',...
   [Xstart+ConfigAxPos(3)-ConfigPos(3),Ystart,ConfigPos(3:4)]);

% Redistribute the editor views
layout(sisodb);

