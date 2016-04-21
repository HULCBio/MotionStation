function [tag,action] = democlean(slidenum)
%DEMOCLEAN  Cleans up demo window when toggling slideshow slides.

%   Authors: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/10 06:41:36 $

%---Clean up objects from last slide
 action = get(gcbo,'Tag');
 if isempty(action), action = 'next'; end  
 switch lower(action)
 case {'next','autoplay'}
    demotaglast = ['SLIDE' num2str(slidenum-1)];
    delete(findobj(gcbf,'Tag',demotaglast));
 case 'back'
    demotaglast = ['SLIDE' num2str(slidenum+1)];
    delete(findobj(gcbf,'Tag',demotaglast));
 case 'reset'
 end
 tag = ['SLIDE' num2str(slidenum)];
