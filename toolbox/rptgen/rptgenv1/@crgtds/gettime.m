function timestr=gettime(c)
%GETTIME returns the current time as a nicely formatted string

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:34 $

timestr=[];
d=clock;

if c.att.timeformat==12 & d(4)>12
   hour=num2str(d(4)-12);
else
   hour=num2str(d(4)); 
end

mins=num2str(d(5));
if length(mins)==1
   mins=['0',mins];
end

timestr=[timestr,hour,c.att.timesep,mins];

if c.att.timesec
   secs=num2str(floor(d(6)));
   if length(secs)==1
      secs=['0',secs];
   end   
   timestr=[timestr,c.att.timesep,secs,' '];
else
   timestr=[timestr,' '];
end

if c.att.timeformat==12
   if d(4)>12
      timestr=[timestr,'pm '];      
   else
      timestr=[timestr,'am '];      
   end
end



   


