function [dtstrarray] = formatdate(dtvector,formatstr,islocal)
%   FORMATDATE casts date vector into a specified date format
%   [DATESTRING] = FORMATDATE(DATEVECTOR, FORMATSTRING) turns the date
%   vector into a formated date string, according to the user's date
%   format template.
%
%   INPUT PARAMETERS:
%   DATEVECTOR: 1 x m double array, containing standard MATLAB date vector.
%   FORMATSTRING: char string containing a user specified date format
%                 string. See NOTE 1.
%
%   RETURN PARAMETERS:
%   DATESTRING: char string, containing date and, optionally, time formated
%               as per user specified format string.
%
%   EXAMPLES:
%   The date vector [2002 10 01 16 8] reformed as a date and time string,
%   using a user format, 'dd-mm-yyyy HH:MM', will display as 
%   01-10-2002 16:08 .
%   
%   NOTE 1: The format specifier allows free-style date format, within the
%   following limits - 
%   ddd  => day is formatted as abbreviated name of weekday
%   dd   => day is formatted as two digit day of month
%   d    => day is formatted as first letter of day of month
%   mmm  => month is formatted as three letter abreviation of name of month
%   mm   => month is formatted as two digit month of year
%   m    => month is formatted as one or two digit month of year
%   yyyy => year is formatted as four digit year
%   yy   => year is formatted as two digit year
%   HH   => hour is formatted as two digit hour of the day
%   MM   => minute is formatted as two digit minute of the hour
%   SS   => second is formatted as two digit second of the minute
%   The user may use any separator and other delimiters of his liking, but
%   must confine himself to the above format tokens regarding day, month,
%   year, hour, minute and second.
% 
%   
%------------------------------------------------------------------------------

% Copyright 2003 The MathWorks, Inc.

if isempty(dtvector) || isempty(formatstr)
    dtstrarray = '';
    return
else
    dtstr = formatstr;
end

notAMPM = isempty(strfind(formatstr,'AM')) && isempty(strfind(formatstr,'PM'));
[year,month,day,hour,minute,second] = deal([]);

% make sure days are capital D and seconds are capital second, so as not to
% confuse d for day with d as in %d when building conversion string.
dtstr = strrep(dtstr,'d','D');
dtstr = strrep(dtstr,'s','S');
dtstr = strrep(dtstr,'Y','y');
if notAMPM
else
    c = cell(1);
    if islocal
        ampm = getampmtokensmx;
    else
        ampm = {'AM','PM'};
    end
    dtstr = strrep(dtstr,'AM',''); % remove AM to avoid confusion below
    dtstr = strrep(dtstr,'PM',''); % remove PM to avoid confusion below
end

showyr =  strfind(dtstr,'y'); wrtYr =  numel(showyr);
showmo =  strfind(dtstr,'m'); wrtMo =  numel(showmo);
showday = strfind(dtstr,'D'); wrtday = numel(showday);
showhr =  strfind(dtstr,'H'); wrtHr =  numel(showhr);
showmin = strfind(dtstr,'M'); wrtMin = numel(showmin);
showsec = strfind(dtstr,'S'); wrtSec = numel(showsec);
showqrt = strfind(dtstr,'Q'); wrtQrt = numel(showqrt);

% Format date
if wrtYr > 0
	checkYr = diff(showyr);
	if any(checkYr~=1)
		error('MATLAB:datestr:yearFormat','Unrecognized year format');
	end
	switch wrtYr
		case 4,
	        dtstr = strrep(dtstr,'yyyy','%.4d');
		case 2,
	        dtstr = strrep(dtstr,'yy','%02d');
		    dtvector(:,1) = mod(abs(dtvector(:,1)),100);
		otherwise
	        error('MATLAB:formatdate:yearFormat','Unrecognised year format');        
    end
    showyr = min(showyr);
end
if wrtQrt > 0
    if wrtQrt == 2 && all(diff(showqrt) == 1)
        dtstr = strrep(dtstr,'QQ','Q%1d');
    else
        error('MATLAB:formatdate:quarterFormat','Unrecognised quarter format');
    end
    if wrtMo > 0 || wrtday > 0 || wrtHr > 0 || wrtMin > 0 || wrtSec > 0
        error('MATLAB:formatdate:quarterFormat',...
        'Cannot use other time and date fields besides year and quarter.');
    end
    showqrt = min(showqrt);
end
if wrtMo > 0
	checkMo = diff(showmo);
	if any(checkMo~=1)
		error('MATLAB:formatdate:monthFormat','Unrecognized month format');
	end
	switch wrtMo
		case 4,
        %long month names
			if islocal
				 month = getmonthnames(1,'long','local');
			else
				month = getmonthnames(1,'long');
			end
			monthfmt = '%s';
			dtstr = strrep(dtstr,'mmmm',monthfmt);			
		case 3,
			if islocal
				 month = getmonthnames(1,'short','local');
			else
				%Putting in a 0 argument prevents the C function from being called,
				%and wasting time
				 month = getmonthnames(0);
			end
			monthfmt = '%s';
			dtstr = strrep(dtstr,'mmm',monthfmt);	
		case 2,
			dtstr = strrep(dtstr,'mm','%02d');  
		case 1,
			if islocal
				 month = getmonthnames(1,'short','local');
			else
				%Putting in a 0 argument prevents the C function from being called,
				%and wasting time
				 month = getmonthnames(0);
			end         
			dtstr = strrep(dtstr,'m','%.1s');			
		otherwise
	        error('MATLAB:formatdate:monthFormat','Unrecognised month format');
    end 
    showmo = min(showmo);
end
if wrtday > 0
	checkday = diff(showday);
	if any(checkday~=1) || wrtday > 4
		error('MATLAB:formatdate:dayFormat','Unrecognized day format');
    end 
	switch wrtday
		case 4,
			%long month names
			if islocal
				  [daynr,day] = weekday(datenum(dtvector), 'long', 'local');
			else
				[daynr,day] = weekday(datenum(dtvector), 'long');
			end
			dtstr = strrep(dtstr,'DDDD','%s');			
		case 3, 
			if islocal
				[daynr,day] = weekday(datenum(dtvector),'local');
			else
				[daynr,day] = weekday(datenum(dtvector));
			end
			dtstr = strrep(dtstr,'DDD','%s');
		case 2,
			dtstr = strrep(dtstr,'DD','%02d'); 			
		case 1,
			if islocal
				[daynr,day] = weekday(datenum(dtvector),'local');
			else
				[daynr,day] = weekday(datenum(dtvector));
			end
			dtstr = strrep(dtstr,'D','%s'); 			
		otherwise
			error('MATLAB:formatdate:dayFormat','Unrecognised day format');
    end 
    showday = min(showday);
end 
% Format time
if wrtHr > 0
    if notAMPM
        fmt = '%02d';
    else
        fmt = '%2d';
        h = dtvector(:,4);
        c(h<12) = ampm(1);
        c(h>=12) = ampm(2);
        dtvector(:,4) = mod(h-1,12) + 1; % replace hour column with 12h format.
        dtstr = [dtstr '%s']; % append conversion string for AM or PM
    end
    
    if wrtHr == 2 && all(diff(showhr)==1)
        dtstr = strrep(dtstr,'HH',fmt); 
    else
        error('MATLAB:formatdate:hourFormat','Unrecognised hour format');    
    end
    showhr = min(showhr);
end
if wrtMin > 0
    if wrtMin == 2 && all(diff(showmin)==1)
        dtstr = strrep(dtstr,'MM','%02d');
    else
        error('MATLAB:formatdate:minuteFormat','Unrecognised minute format');        
    end
    showmin = min(showmin);
end
if wrtSec > 0
	if wrtSec == 2 && all(diff(showsec)==1)
        dtstr = strrep(dtstr,'SS','%02d');
	else
        error('MATLAB:formatdate:secondFormat','Unrecognised second format');        
    end
    showsec = min(showsec);
end

% set year
if wrtYr > 0
    year = mod(dtvector(:,1),10000); 
end
% set month
if wrtMo > 0
	switch wrtMo
		case 4,
	        month = char(month(dtvector(:,2)));
		case 3,
	        month = char(month(dtvector(:,2)));
		case 2,
	        month = abs(dtvector(:,2));
		case 1,
	        month = char(month(dtvector(:,2)));
		    month = month(:,1);
    end
end
% set day
if wrtday > 0
	switch wrtday
		case 2,
		    day = abs(dtvector(:,3));
		case 1,
			language = get(0,'lang');
			if (strncmpi(language,'ja',2) == 0)|| (strncmpi(language,'ch',2) == 0 )
				  day = day(:,1);
			end  
    end
end
% set quarter
if wrtQrt > 0
    qrt = floor((dtvector(:,2)-1)/3)+1;
end
% set hour
if wrtHr > 0
    hour   = dtvector(:,4);
end
% set minute
if wrtMin > 0
    minute = dtvector(:,5);
end
% set second
if wrtSec > 0
	second = dtvector(:,6);
end

% build date-time array to print
if wrtQrt > 0
    dtorder = [showyr, showqrt];    
    dtarray = [{year} {qrt}];
    dtarray = dtarray([(wrtYr>0) (wrtQrt>0)]);
else
    dtorder = [showyr, showmo, showday, showhr, showmin, showsec];
    dtarray = [{year} {month} {day} {hour} {minute} {second}];
    dtarray = dtarray([(wrtYr>0) (wrtMo>0) (wrtday>0) (wrtHr>0) (wrtMin>0) (wrtSec>0)]);
end

% sort date vector in the order of the time format fields
[tmp,dtorder] = sort(dtorder);

% print date vector using conversion string
dtarray = dtarray(dtorder);
[rows,cols] = size(dtvector);
numeldtarray = length(dtarray);
dtstrarray = cell(rows,1);
thisdate = cell(1,numeldtarray);
dtSize = cellfun('size',dtarray,1);
if (dtSize == 1)
    %optimize if only one member
    thisdate = dtarray;
    if notAMPM
        dtstrarray = sprintf(dtstr,thisdate{:});
    else
        dtstrarray = sprintf(dtstr,thisdate{:},char(c));
    end    
else
    for i = 1:dtSize
        for j = 1:numeldtarray
            % take horzontal slice through cells
            thisdate{j} = dtarray{j}(i,:);
        end
        if notAMPM
            %dtstr = sprintf(dtstr,dtarray');
            dtstrarray{i} = sprintf(dtstr,thisdate{:});
        else
            %dtstr = sprintf(dtstr,[dtarray c]');
            dtstrarray{i} = sprintf(dtstr,thisdate{:},char(c{i}));
        end 
    end
end        
