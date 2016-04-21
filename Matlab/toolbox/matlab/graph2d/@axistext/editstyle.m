function aObj = editstyle(aObj, style)
%AXISTEXT/EDITSTYLE Edit font style for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:11:59 $

notNormal = strcmp(get(gcbo,'Checked'),'on');

switch style
case 'normal'
   aObj = set(aObj,'FontAngle','normal');   
   aObj = set(aObj,'FontWeight','normal');
case 'italic'
   if notNormal
      angle = 'normal';
   else
      angle = 'italic';
   end
   aObj = set(aObj,'FontAngle',angle);
case 'bold'
   if notNormal
      weight = 'normal';
   else
      weight = 'bold';
   end
   aObj = set(aObj,'FontWeight',weight);
end
