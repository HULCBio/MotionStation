function [ppx,ppy]=pointsperpixel(rptparent)
%POINTSPERPIXEL returns the local ratio of points per pixel
%   PPX=POINTSPERPIXEL(RPTPARENT)
%   [PPX,PPY]=POINTSPERPIXEL(RPTPARENT) returns the
%      points/pixel ratio in the X and Y directions

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:23 $

persistent RPTGEN_POINTS_PER_PIXEL

if isempty(RPTGEN_POINTS_PER_PIXEL)
   oldUnits=get(0,'Units');
   set(0,'Units','Points');
   pointSize=get(0,'ScreenSize');
   set(0,'Units','Pixels');
   pixelSize=get(0,'ScreenSize');
   set(0,'Units',oldUnits);
   
   RPTGEN_POINTS_PER_PIXEL=pointSize(3:4)./pixelSize(3:4);
end

ppx=RPTGEN_POINTS_PER_PIXEL(1);
ppy=RPTGEN_POINTS_PER_PIXEL(2);
