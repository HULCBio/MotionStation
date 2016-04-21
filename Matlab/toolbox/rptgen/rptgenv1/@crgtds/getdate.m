function datestr=getdate(c)
%GETDATE returns a formatted version of the current date

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:32 $

monthlong={'January'
   'February'
   'March'
   'April'
   'May'
   'June'
   'July'
   'August'
   'September'
   'October'
   'November'
   'December'};
monthshort={'Jan'
   'Feb'
   'Mar'
   'Apr'
   'May'
   'Jun'
   'Jul'
   'Aug'
   'Sep'
   'Oct'
   'Nov'
   'Dec'};

d=clock;
datestr=[];

for i=1:length(c.att.dateorder)
   switch lower(c.att.dateorder(i))
   case 'd'
      day=num2str(d(3));
      datestr=[datestr,day];      
   case 'm'
      month=d(2);
      switch lower(c.att.datemonth)
      case 'long'
         month=monthlong{month};
      case 'short'
         month=monthshort{month};
      otherwise
         month=num2str(month);
      end
      
      datestr=[datestr,month];
   case 'y'
      year=d(1);
      switch c.att.dateyear
      case 'LONG'
         year=num2str(year);
      otherwise
         year=year-floor(year/100)*100;
         year=num2str(year);
      end      
      datestr=[datestr,year];
   end
   
   if i~=length(c.att.dateorder)
      datestr=[datestr,c.att.datesep];
   end   
end

   