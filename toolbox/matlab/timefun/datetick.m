function datetick(varargin)
%DATETICK Date formatted tick labels. 
%   DATETICK(TICKAXIS,DATEFORM) annotates the specified tick axis with
%   date formatted tick labels. TICKAXIS must be one of the strings
%   'x','y', or 'z'. The default is 'x'.  The labels are formatted
%   according to the format number or string DATEFORM (see table
%   below).  If no DATEFORM argument is entered, DATETICK makes a
%   guess based on the data for the objects within the specified axis.
%   To produce correct results, the data for the specified axis must
%   be serial date numbers (as produced by DATENUM).
%
%   DATEFORM number   DATEFORM string         Example
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      1             'dd-mmm-yyyy'            01-Mar-2000  
%      2             'mm/dd/yy'               03/01/00     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     3            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     1            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   2000         
%     11             'yy'                     00           
%     12             'mmmyy'                  Mar00        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-01        
%     18             'QQ'                     Q1        
%     19             'dd/mm'                  01/03        
%     20             'dd/mm/yy'               01/03/00     
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%     22             'mmm.dd,yyyy'            Mar.01,2000  
%     23             'mm/dd/yyyy'             03/01/2000 
%     24             'dd/mm/yyyy'             01/03/2000 
%     25             'yy/mm/dd'               00/03/01 
%     26             'yyyy/mm/dd'             2000/03/01 
%     27             'QQ-YYYY'                Q1-2001        
%     28             'mmmyyyy'                Mar2000       
%
%   DATETICK(...,'keeplimits') changes the tick labels into date-based
%   labels while preserving the axis limits. 
%
%   DATETICK(....'keepticks') changes the tick labels into date-based labels
%   without changing their locations. Both 'keepticks' and 'keeplimits' can
%   be used at the same time.
%
%   DATETICK(AX,...) uses the specified axes, rather than the current axes.
%
%   DATETICK relies on DATESTR to convert date numbers to date strings.
%
%   Example (based on the 1990 U.S. census):
%      t = (1900:10:1990)'; % Time interval
%      p = [75.995 91.972 105.711 123.203 131.669 ...
%          150.697 179.323 203.212 226.505 249.633]';  % Population
%      plot(datenum(t,1,1),p) % Convert years to date numbers and plot
%      datetick('x','yyyy') % Replace x-axis ticks with 4 digit year labels.
%    
%   See also DATESTR, DATENUM.

%   Author(s): C.F. Garvin, 4-03-95, Clay M. Thompson 1-29-96
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.3 $  $Date: 2004/04/10 23:32:16 $

[axh,nin,ax,dateform,keep_ticks,keep_limits] = parseinputs(varargin);

labels = [];

% Compute data limits.
if keep_limits | isempty(get(axh,'children'))
   lim = get(axh,[ax 'lim']);
   vmin = lim(1);
   vmax = lim(2);
else
   h = findobj(axh);
   vmin = inf; vmax = -inf;
   for i=1:length(h),
      t = get(h(i),'type');
      if strcmp(t,'surface') | strcmp(t,'patch') | ...
            strcmp(t,'line') | strcmp(t,'image') 
         vdata = get(h(i),[ax,'data']);
         if ~isempty(vdata)
             vmin = min(vmin,min(vdata(:)));
             vmax = max(vmax,max(vdata(:)));
          end
      elseif strcmp(t,'text')
         pos = get(h(i),'position');
         switch ax
         case 'x'
            vdata = pos(1);
         case 'y'
            vdata = pos(2);
         case 'z'
            vdata = pos(3);
         end
         vmin = min(vmin,min(vdata(:)));
         vmax = max(vmax,max(vdata(:)));
      end
   end
end

if nin==2 & isstr(dateform), % Determine dateformat from string.
   switch dateform
   case 'dd-mmm-yyyy HH:MM:SS', dateform = 0;
   case 'dd-mmm-yyyy', dateform = 1;
   case 'mm/dd/yy', dateform = 2;
   case 'mmm', dateform = 3;
   case 'm', dateform = 4;
   case 'mm', dateform = 5;
   case 'mm/dd', dateform = 6;
   case 'dd', dateform = 7;
   case 'ddd', dateform = 8;
   case 'd', dateform = 9;
   case 'yyyy', dateform = 10;
   case 'yy', dateform = 11;
   case 'mmmyy', dateform = 12;
   case 'HH:MM:SS', dateform = 13;
   case 'HH:MM:SS PM', dateform = 14;
   case 'HH:MM', dateform = 15;
   case 'HH:MM PM', dateform = 16;
   case 'QQ-YY', dateform = 17;
   case 'QQ', dateform = 18;
   case 'dd/mm', dateform = 19;
   case 'dd/mm/yy', dateform = 20;
   case 'mmm.dd,yyyy HH:MM:SS', dateform = 21;
   case 'mmm.dd,yyyy', dateform = 22;
   case 'mm/dd/yyyy', dateform = 23;
   case 'dd/mm/yyyy', dateform = 24;
   case 'yy/mm/dd', dateform = 25;
   case 'yyyy/mm/dd', dateform = 26;
   case 'QQ-YYYY', dateform = 27;
   case 'mmmyyyy', dateform = 28; 
   otherwise
      error(sprintf('Unknown date format: %s',dateform))
   end
end

if ~keep_ticks
   if nin==2,
      switch dateform
      case 0, dateChoice = 'yqmwdHMS';
      case 1, dateChoice = 'yqmwd';
      case 2, dateChoice = 'yqmwd';
      case 3, dateChoice = 'yqm';
      case 4, dateChoice = 'yqm';
      case 5, dateChoice = 'yqm';
      case 6, dateChoice = 'yqmwd';
      case 7, dateChoice = 'yqmwd';
      case 8, dateChoice = 'yqmwd';
      case 9, dateChoice = 'yqmwd';
      case 10, dateChoice = 'y';
      case 11, dateChoice = 'y';
      case 12, dateChoice = 'yqm';
      case 13, dateChoice = 'yqmwdHMS';
      case 14, dateChoice = 'yqmwdHMS';
      case 15, dateChoice = 'yqmwdHMS';
      case 16, dateChoice = 'yqmwdHMS';
      case 17, dateChoice = 'yq';
      case 18, dateChoice = 'yq';
      case 19, dateChoice = 'yqmwd';
      case 20, dateChoice = 'yqmwd';
      case 21, dateChoice = 'yqmwdHMS';
      case 22, dateChoice = 'yqmwd';
      case 23, dateChoice = 'yqmwd';
      case 24, dateChoice = 'yqmwd';
      case 25, dateChoice = 'yqmwd';
      case 26, dateChoice = 'yqmwd';
      case 27, dateChoice = 'yq';
      case 28, dateChoice = 'yqm';
      otherwise
         error('Date format number must be between 0 and 28.');
      end
      ticks = bestscale(axh,ax,vmin,vmax,dateform,dateChoice);
   else
      [ticks,dateform] = bestscale(axh,ax,vmin,vmax);
   end
else
   ticks = get(axh,[ax,'tick']);
   if nin~=2
      % Use dateform from bestscale
      [dum,dateform] = bestscale(axh,ax,min(ticks),max(ticks));
   end
end

% Set axis tick labels
labels = datestr(ticks,dateform);
if keep_limits
   set(axh,[ax,'tick'],ticks,[ax,'ticklabel'],labels)
else
   set(axh,[ax,'tick'],ticks,[ax,'ticklabel'],labels, ...
      [ax,'lim'],[min(ticks) max(ticks)])
end

%--------------------------------------------------
function [labels,format] = bestscale(axh,ax,xmin,xmax,dateform,dateChoice)
%BESTSCALE Returns ticks for "best" scale.
%   [TICKS,FORMAT] = BESTSCALE(XMIN,XMAX) returns the tick
%   locations in the vector TICKS that span the interval (XMIN,XMAX) 
%   with "nice" tick spacing.  The dateform FORMAT is also returned.

if nargin<6, dateChoice = 'yqmwdHMS'; end
if nargin<5, dateform = []; end
penalty = 0.03;
formlen = [20 12 8 3 1 2 5 2 3 1 4 2 5 8 11 5 8 5 2 5 8 20 11 10 10 8 10 7 7];

% Compute xmin, xmax if matrices passed.
if length(xmin) > 1, xmin = min(xmin(:)); end
if length(xmax) > 1, xmax = max(xmax(:)); end

% "Good" spacing between dates
if xmin==xmax, 
   xmin = xmin-1;
   xmax = xmax+1;
end
yearDelta = 10.^(max(0,round(log10(xmax-xmin)-3)))* ...
   [ .1 .2 .25 .5 1 2 2.5 5 10 20 25 50];
yearDelta(yearDelta<1)= []; % Make sure we use integer years.
quarterDelta = [3];
monthDelta = [1];
weekDelta = 1;
dayDelta = 1;
hourDelta = [1 3 6];
minuteDelta = [1 5 10 15 30 60];
secondDelta = min(1,10.^(round(log10(xmax-xmin)-1))* ...
   [ .1 .2 .25 .5 1 2 2.5 5 10 20 25 50 ]);
secondDelta = [secondDelta 1 5 10 15 30 60];

x = [xmin xmax];
[y,m,d] = datevec(x);

% Compute continuous variables for the various time scales.
year = y + (m-1)/12 + (d-1)/12/32;
qtr = (y-y(1))*12 + m + d/32 - 1;
mon = (y-y(1))*12 + m + d/32; 
day = x;
week = (x-2)/7;
hour = (x-floor(x(1)))*24;
minute = (x-floor(x(1)))*24*60;
second = (x-floor(x(1)))*24*3600;

% Compute possible low, high and ticks
if any(dateChoice=='y')
   yearHigh = yearDelta.*ceil(year(2)./yearDelta);
   yearLow = yearDelta.*floor(year(1)./yearDelta);
   yrTicks = round((yearHigh-yearLow)./yearDelta);
   yrHigh = datenum(yearHigh,1,1);
   yrLow = datenum(yearLow,1,1);
   % Encode location of year tick locations in format
   yrFormat = 10 + (1:length(yearDelta))/10;
else
   yrHigh=[]; yrLow=[]; yrTicks=[]; yrFormat = 10;
end 

if any(dateChoice=='q'),
   quarterHigh = quarterDelta.*ceil(qtr(2)./quarterDelta);
   quarterLow = quarterDelta.*floor(qtr(1)./quarterDelta);
   qtrTicks = round((quarterHigh-quarterLow)./quarterDelta);
   qtrHigh = datenum(y(1),quarterHigh+1,1);
   qtrLow = datenum(y(1),quarterLow+1,1);
   % Encode location of qtr tick locations in format
   qtrFormat = 17 + (1:length(quarterDelta))/10;
else
   qtrHigh=[]; qtrLow=[]; qtrTicks=[]; qtrFormat = [];
end

if any(dateChoice=='m'),
   monthHigh = monthDelta.*ceil(mon(2)./monthDelta);
   monthLow = monthDelta.*floor(mon(1)./monthDelta);
   monTicks = round((monthHigh-monthLow)./monthDelta);
   monHigh = datenum(y(1),monthHigh,1);
   monLow = datenum(y(1),monthLow,1);
   % Encode location of month tick locations in format
   monFormat = 3 + (1:length(monthDelta))/10;
else
   monHigh=[]; monLow=[]; monTicks=[]; monFormat = [];
end

if any(dateChoice=='w')
   weekHigh = weekDelta.*ceil(week(2)./weekDelta);
   weekLow = weekDelta.*floor(week(1)./weekDelta);
   weekTicks = round((weekHigh-weekLow)./weekDelta);
   weekHigh = weekHigh*7+2;
   weekLow = weekLow*7+2;
   weekFormat = 6*ones(size(weekDelta));
else
   weekHigh=[]; weekLow=[]; weekTicks=[]; weekFormat=[];
end

if any(dateChoice=='d'),
   dayHigh = dayDelta.*ceil(day(2)./dayDelta);
   dayLow = dayDelta.*floor(day(1)./dayDelta);
   dayTicks = round((dayHigh-dayLow)./dayDelta);
   dayFormat = 6*ones(size(dayDelta));
else
   dayHigh=[]; dayLow=[]; dayTicks=[]; dayFormat = [];
end

if any(dateChoice=='H'),
   hourHigh = hourDelta.*ceil(hour(2)./hourDelta);
   hourLow = hourDelta.*floor(hour(1)./hourDelta);
   hourTicks = round((hourHigh-hourLow)./hourDelta);
   hourHigh = datenum(y(1),m(1),d(1),hourHigh,0,0);
   hourLow = datenum(y(1),m(1),d(1),hourLow,0,0);
   hourFormat = 15*ones(size(hourDelta));
else
   hourHigh=[]; hourLow=[]; hourTicks=[]; hourFormat=[];
end

if any(dateChoice=='M')
   minHigh = minuteDelta.*ceil(minute(2)./minuteDelta);
   minLow = minuteDelta.*floor(minute(1)./minuteDelta);
   minTicks = round((minHigh-minLow)./minuteDelta);
   minHigh = datenum(y(1),m(1),d(1),0,minHigh,0);
   minLow = datenum(y(1),m(1),d(1),0,minLow,0);
   minFormat = 15*ones(size(minuteDelta));
else
   minHigh=[]; minLow=[]; minTicks=[]; minFormat=[];
end

if any(dateChoice=='S'),
   secHigh = secondDelta.*ceil(second(2)./secondDelta);
   secLow = secondDelta.*floor(second(1)./secondDelta);
   secTicks = round((secHigh-secLow)./secondDelta);
   secHigh = datenum(y(1),m(1),d(1),0,0,secHigh);
   secLow = datenum(y(1),m(1),d(1),0,0,secLow);
   secFormat = 13*ones(size(secondDelta));
else
   secHigh=[]; secLow=[]; secTicks=[]; secFormat=[];
end

% Concatenate all the date formats together to determine
% the best spacing.
high =  [yrHigh   qtrHigh   monHigh   dayHigh   weekHigh   hourHigh   minHigh   secHigh];
low =   [yrLow    qtrLow    monLow    dayLow    weekLow    hourLow    minLow    secLow];
ticks = [yrTicks  qtrTicks  monTicks  dayTicks  weekTicks  hourTicks  minTicks  secTicks];
format =[yrFormat qtrFormat monFormat dayFormat weekFormat hourFormat minFormat secFormat];

% sort the formats by number of ticks.
[ticks,ndx] = sort(ticks);
high = high(ndx);
low = low(ndx);
format = format(ndx);

% Get axis width/heigth in pixels
units = get(axh,'units');
set(axh,'units','pixels');
pos = get(axh,'position');
set(axh,'units',units);

% Determine the extent of each format in pixels
% Use a temp figure to keep from de-activating the zoom state
tempfig=figure('visible','off'); 
tempax=axes('parent',tempfig);
htemp = text('parent',tempax,'units','pixels',...
   'fontname',get(axh,'fontname'), ...
   'fontangle',get(axh,'fontangle'),...
   'fontsize',get(axh,'fontsize'),...
   'fontunits',get(axh,'fontunits'),...
   'fontweight',get(axh,'fontweight'),'visible','on');
if strcmp(ax,'x')
   s = repmat('W',1,max(formlen));
   set(htemp,'string',s)
   ext = get(htemp,'extent');
   % fractional width taken up by string
   if isempty(dateform)
      len = formlen(floor(format)+1);
   else
      len = formlen(dateform+1)+zeros(size(format));
   end
   extent = ext(3)/max(formlen)*len/pos(3); 
else
   set(htemp,'string',('WW')')
   ext = get(htemp,'extent');
   % fractional height taken up by string
   extent = repmat(ext(4),size(format))/pos(4); 
end
delete(tempfig)

% Chose the best fit. The best fit has the least slop without overlap and
% the most ticks.
oldwarn = warning('off','MATLAB:divideByZero');
fit = (abs(xmin-low) + abs(high-xmax))./(high-low) + max(0,extent.*ticks-1);
warning(oldwarn.state,'MATLAB:divideByZero');
i = find(fit == min(fit));
[dum,j] = max(ticks(i));
i = i(j);
low = low(i); high = high(i); ticks = ticks(i); format = format(i);

if floor(format) == 3, % Month format
   i = round(rem(format,1)*10); % Retrieve encoded value
   labels = datenum(y(1),linspace(monthLow(i),monthHigh(i),ticks+1),1);
   format = floor(format);
elseif floor(format) == 17, % Quarter format
   i = round(rem(format,1)*10); % Retrieve encoded value
   labels = datenum(y(1),linspace(quarterLow(i)+1,quarterHigh(i)+1,ticks+1),1);
   format = floor(format);
elseif floor(format) == 10, % Year format
   i = round(rem(format,1)*10); % Retrieve encoded value
   labels = datenum(linspace(yearLow(i),yearHigh(i),ticks+1),1,1);
   format = floor(format);
else
   labels = linspace(low,high,ticks+1);
end
labels = unique(labels);

%-------------------------------------------------
function [axh,nin,ax,dateform,keep_ticks,keep_limits] = parseinputs(v)
%Parse Inputs

% Defaults;
ax = 'x';
dateform = [];
keep_ticks = 0;
keep_limits = 0;
nin = length(v);

% check to see if an axes was specified
if nin > 0 & ishandle(v{1}) & isequal(get(v{1},'type'),'axes')
    % use the axes passed in
    axh = v{1};
    v(1)=[];
    nin=nin-1;
else
    % use gca
    axh = gca;
end


% check for too many input arguments
if nin > 4
    error('Too many input arguments');
end

% check for incorrect arguments
% if the input args is more than two - it should be either
% 'keeplimits' or 'keepticks' or both.
if nin > 2
    for i = nin:-1:3
        if ~(strcmp(v{i},'keeplimits') | strcmp(v{i},'keepticks'))
            error('Incorrect arguments');
        end
    end
end


% Look for 'keeplimits'
for i=nin:-1:max(1,nin-2),
   if strcmp(v{i},'keeplimits'),
      keep_limits = 1;
      v(i) = [];
      nin = nin-1;
   end
end

% Look for 'keepticks'
for i=nin:-1:max(1,nin-1),
   if strcmp(v{i},'keepticks'),
      keep_ticks = 1;
      v(i) = [];
      nin = nin-1;
   end
end

if nin==0, 
   ax = 'x';
else
   switch v{1}
   case {'x','y','z'}
      ax = v{1};
   otherwise
      error('The axis must be ''x'',''y'', or ''z''.');
   end
end


if nin > 1
     % The dateform (Date Format) value should be a scalar or string constant
     % check this out
     dateform = v{2}; 
     if (isnumeric(dateform) & length(dateform) ~= 1) & ~ischar(dateform)
         error('The Date Format value should be a scalar or string');
     end 
end
