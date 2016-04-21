function pos=iduilay(figwh,butwh,ftb,bbv,bbh,etf,lev,nobut,layers)
%IDUILAY Compute positions for nicely laid out uicontrols.
%   fdigwh  figure width & height
%   butwh   button width & height
%   ftb     frame to button
%   bb      between buttons
%   etf     edge to frame
%   nobut   number of buttons
%   layers  number of layers
%   POS: A matrix containing the positions of the surrounding frame,
%   and the corresponding nobut uicontrols.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:39 $

if nargin<9,layers=1;end
nobutw=ceil(nobut/layers);
framewidth=nobutw*butwh(1)+(nobutw-1)*bbh+2*ftb;
etf2=[figwh(1)-framewidth]/2;
pos(1,:)=[etf2 lev  framewidth layers*butwh(2)+(layers-1)*bbv+ftb*2];
kcount=1;
for kl=layers:-1:1
  for kb=1:nobutw
     kcount=kcount+1;
     pos(kcount,:)=[etf2+ftb+(kb-1)*(bbh+butwh(1))...
                    ftb+(kl-1)*(bbv+butwh(2))+lev butwh];
  end
end
