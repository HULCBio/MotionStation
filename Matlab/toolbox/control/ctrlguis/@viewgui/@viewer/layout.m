function layout(this,varargin)
%PLOTPOS  Determines new locations for response plots in the viewer
%         object based on the current figure size/position.
%         This function also adds new background axes to the viewer
%         as needed.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/05/04 02:09:50 $

if strcmp(this.Figure.Visible,'off')
   return
end

% Adjust position of status frame
layoutstatus(this)

% Position plots
ActiveViews = getCurrentViews(this);
if ~isempty(ActiveViews)
   FigPos = get(this.Figure,'Position');
   FigWidth = FigPos(3);
   FigHeight = FigPos(4);
   
   % Spacing values
   tedge = min(24,0.12*0.34*FigHeight);
   bedge = min(46,0.12*0.66*FigHeight);
   ledge = min(66,0.1*FigWidth);
   
   % Adjusted figure position (accounts for status bar, if visible)
   % RE: Leave min gap of 45 pixels between bottom axis and status bar, and
   %     min gap of 15 pixels between top axis and figure edge
   sp = get(this.HG.StatusBar,'Position');
   if strcmpi(get(this.HG.StatusBar,'Visible'),'on')
      BottomGap = sp(2)+sp(4);
   else
      BottomGap = sp(2);
   end
   BottomGap = BottomGap + max(0,40-bedge);
   TopGap = max(0,15-tedge);
   LeftGap = max(0,55-ledge);
   RightGap = 20;
   FigPos = [LeftGap BottomGap FigWidth-(LeftGap+RightGap) FigHeight-(BottomGap+TopGap)];
   
   %--- Calculate new viewer axes positions (pixels)
   %--- (width and height will be limited to 1 pixel to avoid invalid position vector)
   switch length(ActiveViews)
   case 1
      aw = max(1,FigPos(3) - ledge);
      ah = max(1,FigPos(4) - (tedge+bedge));
      AxPo = [FigPos(1)+ledge FigPos(2)+bedge aw ah];
   case 2
      aw = max(1,FigPos(3) - ledge);
      ah = max(1,FigPos(4)/2 - (tedge+bedge));
      AxPo = [[FigPos(1)+ledge FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+ledge   FigPos(2)+bedge aw ah]];  
   case 3
      aw = max(1,FigPos(3) - ledge);
      ah = max(1,FigPos(4)/3 - (tedge+bedge));
      AxPo = [[FigPos(1)+ledge FigPos(2)+3*bedge+2*tedge+2*ah aw ah];...
            [FigPos(1)+ledge   FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+ledge   FigPos(2)+bedge aw ah]];  
   case 4
      aw = max(1,FigPos(3)/2 - ledge);
      ah = max(1,FigPos(4)/2 - (tedge+bedge));
      AxPo = [[FigPos(1)+ledge    FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+2*ledge+aw FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+ledge      FigPos(2)+bedge aw ah];...
            [FigPos(1)+2*ledge+aw FigPos(2)+bedge aw ah]];  
   case 5
      aw1 = max(1,FigPos(3)/2 - ledge);
      aw2 = max(1,FigPos(3)/3 - ledge);
      ah  = max(1,FigPos(4)/2 - (tedge+bedge));
      AxPo = [[FigPos(1)+ledge       FigPos(2)+2*bedge+tedge+ah aw1 ah];...
            [FigPos(1)+2*ledge+aw1   FigPos(2)+2*bedge+tedge+ah aw1 ah];...
            [FigPos(1)+ledge         FigPos(2)+bedge aw2 ah];...
            [FigPos(1)+2*ledge+aw2   FigPos(2)+bedge aw2 ah];...
            [FigPos(1)+3*ledge+2*aw2 FigPos(2)+bedge aw2 ah]];  
   case 6
      aw = max(1,FigPos(3)/3 - ledge);
      ah = max(1,FigPos(4)/2 - (tedge+bedge));
      AxPo = [[FigPos(1)+ledge      FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+2*ledge+aw   FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+3*ledge+2*aw FigPos(2)+2*bedge+tedge+ah aw ah];...
            [FigPos(1)+ledge        FigPos(2)+bedge aw ah];...
            [FigPos(1)+2*ledge+aw   FigPos(2)+bedge aw ah];...
            [FigPos(1)+3*ledge+2*aw FigPos(2)+bedge aw ah]];  
   end
   %---Remap existing Axes
   for ct=1:length(ActiveViews)
      set(ActiveViews(ct).AxesGrid,'Position',...
         AxPo(ct,:)./[FigWidth FigHeight FigWidth FigHeight]);
   end
end
