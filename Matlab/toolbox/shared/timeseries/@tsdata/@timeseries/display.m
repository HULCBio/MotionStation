function display(ts)
%DISPLAY @timeseries display method
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:45 $

fprintf(1,'Time Series Object: %s\n\n',ts.name);

% Check for empty objects
if isempty(ts.Time) || isempty(ts.Data)
    fprintf(1,'      %s\n', 'Empty');
    return
end

% Time vecter header
fprintf(1,'Time vector characteristics\n');
timelenstr = 'Length';
fprintf(1,'      %s%s%d\n', timelenstr, blanks(22-length(timelenstr)), ...
    length(ts.time));

% Time vector characteristics
if tsIsDateFormat(ts.timeInfo.Format) && ~isempty(ts.timeInfo.Startdate)
    timeasdate = true;
    formatstr = ['      %s%s%s\n'];
    strStartTime = 'Start date';
    strEndTime = 'End date';
    fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), ...
        datestr(tsunitconv('days',ts.timeInfo.Units)*ts.timeInfo.Start+...
        datenum(ts.timeInfo.Startdate),ts.timeInfo.Format));
    fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), ...
        datestr(tsunitconv('days',ts.timeInfo.Units)*ts.timeInfo.End+...
        datenum(ts.timeInfo.Startdate),ts.timeInfo.Format));   
else
    timeasdate = false;
    if ~isempty(ts.timeInfo.Startdate)
        startdatestr = 'Reference start date';
        fprintf(1,'      %s%s%s\n', startdatestr, ...
            blanks(22-length(startdatestr)),ts.timeInfo.Startdate);
    end
    strStartTime = 'Start time';
    strEndTime = 'End time';
    formatstr = ['      %s%s%d ' ts.timeInfo.units '\n'];
    fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), ts.timeInfo.start);
    fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), ts.timeInfo.end);
end    
   
% Ordinate data characteristics
s = size(ts.Data);
fprintf(1,'\nOrdinate data characteristics\n');
interpMethod = 'Interpolation method';
fprintf(1,'      %s%s%s\n',interpMethod, ...
    blanks(22-length(interpMethod)),ts.DataInfo.Interpolation.Name);
sizeStr = 'Size';
fprintf(1,'      %s%s[%s]\n',sizeStr, ...
    blanks(22-length(sizeStr)),num2str(s));
typeStr = 'Data type';
fprintf(1,'      %s%s%s\n',typeStr, ...
    blanks(22-length(typeStr)),class(ts.Data));

 

if ~isempty(ts.Data) && isa(ts.Data,'numeric') && length(s)<3 && ...
        ((s(end)==1 && ts.DataInfo.GridFirst) || ...
        (s(1)==1 && ~ts.DataInfo.GridFirst))
     
     if timeasdate
         time = datestr(tsunitconv('days',ts.timeInfo.Units)*ts.Time+ ...
                 datenum(ts.timeInfo.Startdate),ts.timeInfo.Format);
         headergap = 10+length(time(1,:));
     else
         time = ts.Time;
         headergap = 14;
     end
     
     % Header
     if isempty(ts.DataInfo.Name)
         fprintf(1,'\n%s%s%s\n','Time',blanks(headergap),'Data');
         fprintf(1,'%s\n', repmat('-',[1 headergap+8]));
     else
         fprintf(1,'\n%s%s%s\n','Time',blanks(headergap),ts.DataInfo.Name);
         fprintf(1,'%s\n', repmat('-',[1 headergap+length(ts.DataInfo.Name)+4]));
     end

     data = ts.Data;
     for k=1:length(time)  
         if timeasdate
             timestr = time(k,:);
         else
             timestr = sprintf('%0.3g',time(k));
         end
         if abs(imag(data(k)))<eps
             fprintf(1,'%s%s%0.3g\n', timestr, ...
                 blanks(18-length(timestr)), data(k));
         elseif abs(imag(data(k))-1)<1e-3
              fprintf(1,'%s%s%0.3g + i\n', timestr, ...
                 blanks(18-length(timestr)), real(data(k)));
         elseif abs(imag(data(k))+1)<1e-3
              fprintf(1,'%s%s%0.3g - i\n', timestr, ...
                 blanks(18-length(timestr)), real(data(k)));  
         elseif imag(data(k))<0    
              fprintf(1,'%s%s%0.3g - %0.3gi\n', timestr, ...
                 blanks(18-length(timestr)), real(data(k)),-imag(data(k)));
         else
              fprintf(1,'%s%s%0.3g + %0.3gi\n', timestr, ...
                 blanks(18-length(timestr)), real(data(k)),imag(data(k)));
         end
     end
end

     
