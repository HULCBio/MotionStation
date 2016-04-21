function pos=iduilay1(figwh,nobut,layers,level,betw_but_vert,width_fact)
%IDUILAY1 Help function to compute positions for nicely laid out uicontrols.
%   figwh= figure width & height
%   nobut = number of buttons
%   layers = number of layers
%   level = the starting level (0 if at bottom)
%   betw_but_vert = Vertical distance between buttons
%   width_fact = factor to multiply the button-width. Could be a
%                 vector of length NOBUT/LAYERS
%   POS: A matrix containing the positions of the surrounding frame,
%   and the corresponding nobut uicontrols
%
%   The vertical distance between frame and controls will always be
%   mStdButtonHeight/2, while the vertical distance between buttons is
%   betw_but_vert

%   L. Ljung 10-10-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:39 $

layout
vert_FrToText = mStdButtonHeight/2;
if nargin<6,width_fact=1;end
if nargin<5,betw_but_vert = [];end
if isempty(betw_but_vert),betw_but_vert=mStdButtonHeight/5;end
if nargin<4,level=0;end
if nargin<3,layers=1;end
nobutw = ceil(nobut/layers);
if length(width_fact)==1,width_fact=width_fact*ones(1,nobutw);end

pos(1,:) = [mEdgeToFrame level+mEdgeToFrame figwh(1)-2*mEdgeToFrame ...
            layers*mStdButtonHeight+(layers-1)*betw_but_vert+2*vert_FrToText];

kcount=1;
cumwf=[0 cumsum(width_fact)];
if level==0  % Then we have the bottom-button row
  butspace_bb = (figwh(1)-2*mEdgeToFrame-...
                     sum(width_fact)*mStdButtonWidth)/(nobutw+1);
  butspace_fb = butspace_bb;
elseif nobutw>1
  butspace_fb = mFrameToText;
  butspace_bb = (figwh(1)-2*(mEdgeToFrame+mFrameToText)-...
                sum(width_fact)*mStdButtonWidth)/(nobutw-1);
end
for kl=layers:-1:1
  for kb=1:nobutw
     kcount=kcount+1;
     if nobutw==1&level>0
        pos(kcount,:) = [mEdgeToFrame+mFrameToText ...
                level+mEdgeToFrame+vert_FrToText+...
                (kl-1)*betw_but_vert+(kl-1)*mStdButtonHeight,...
                figwh(1)-2*(mEdgeToFrame+mFrameToText)  mStdButtonHeight];
     else
        pos(kcount,:)=[mEdgeToFrame+butspace_fb+(kb-1)*butspace_bb+...
                cumwf(kb)*mStdButtonWidth ...
                level+mEdgeToFrame+vert_FrToText+...
                (kl-1)*betw_but_vert+(kl-1)*mStdButtonHeight,...
                 mStdButtonWidth*width_fact(kb) mStdButtonHeight];
    end
  end
end
