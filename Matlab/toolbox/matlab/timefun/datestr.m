function S = datestr(D,varargin)
%DATESTR String representation of date.
%   DATESTR(D,DATEFORM) converts D, a date vector (as returned by DATEVEC) 
%   or serial date number (as returned by DATENUM), or a free format date 
%   string into a date string with a format specified by format number or 
%   string DATEFORM (Table 1, below). By default, DATEFORM is 1, 16, or 0
%   depending on whether D contains dates, times or both. Date strings 
%   with 2 character years are interpreted to be within the 100 years 
%   centered around the current year. DATEFORM may also contain a free-form date
%   format string, consisting of format tokens as per Table 2, below, and
%   DATESTR will attempt to represent date D by the specified free dateform.
%
%   DATESTR(D,DATEFORM,PIVOTYEAR) uses the specified pivot year as the
%   starting year of the 100-year range in which a two-character year
%   resides.  The default pivot year is the current year minus 50 years.
%   DATEFORM = -1 uses the default format.
%
%   DATESTR(...,'local') returns the string in a localized format.  The
%   default (can be called with 'en_US'), is US English.  This argument
%   must come last in the argument sequence.
%
%   Table 1: Standard MATLAB Dateform definitions
%
%   DATEFORM number   DATEFORM string         Example
%   ===========================================================================
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      1             'dd-mmm-yyyy'            01-Mar-2000  
%      2             'mm/dd/yy'               03/01/00     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     03            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     01            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   2000         
%     11             'yy'                     00           
%     12             'mmmyy'                  Mar00        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-96        
%     18             'QQ'                     Q1           
%     19             'dd/mm'                  01/03        
%     20             'dd/mm/yy'               01/03/00     
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%     22             'mmm.dd,yyyy'            Mar.01,2000  
%     23             'mm/dd/yyyy'             03/01/2000 
%     24             'dd/mm/yyyy'             01/03/2000 
%     25             'yy/mm/dd'               00/03/01 
%     26             'yyyy/mm/dd'             2000/03/01 
%     27             'QQ-YYYY'                Q1-1996        
%     28             'mmmyyyy'                Mar2000        
%     29 (ISO 8601)  'yyyy-mm-dd'             2000-03-01
%     30 (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517 
%     31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17 
%
%   Table 2: Free-form date format symbols
%   
%   Symbol  Interpretation of format symbol
%   ===========================================================================
%   yyyy    full year, e.g. 1990, 2000, 2002
%   yy      partial year, e.g. 90, 00, 02
%   mmmm    full name of month of year, according to the calendar locale, e.g.
%           "March", "April" in the UK and USA English locales. 
%   mmm     the first three letters of the month of year, according to the
%           calendar locale, e.g. "Mar", "Apr" in the UK and USA English locales. 
%   mm      the numeric month of year, padded with leading zeros, e.g. ../03/..
%           or ../12/.. 
%   m       the capitalised first letter of the month of year, according to the
%           calendar locale; for backwards compatibility. 
%   dddd    the full name of the weekday, according to the calendar locale, eg.
%           "Monday", "Tueday", for the UK and USA calendar locales. 
%   ddd     the first three letters of the weekday, according to the calendar
%           locale, eg. "Mon", "Tue", for the UK and USA calendar locales. 
%   dd      the numeric day of month, padded with leading zeros, e.g. 05/../..
%           or 20/../.. 
%   d       capitalised first letter of the weekday; for backwards compatibility
%   HH      the hour of day, according to the time format. In case the time
%           format AM | PM is set, HH does not pad with leading zeros. In case
%           AM | PM is not set, display the hour of the day, padded with leading
%           zeros. E.g 10:20 PM, which is equivalent to  22:20; 9:00 AM, which
%           is equivalent to 09:00.
%   MM      minutes of the hour, padded with leading zeros, e.g. 10:15, 10:05,
%           10:05 AM.
%   SS      second of the minute, padded with leading zeros, e.g. 10:15:30,
%           10:05:30, 10:05:30 AM. 
%   PM      set the time format as time of morning or time of afternoon. AM or
%           PM is appended to the date string, as appropriate. 
%
%   Examples:
%   DATESTR(now) returns '24-Jan-2003 11:58:15' for that particular date, on an
%   US English locale
%   DATESTR(now,2) returns 01/24/03, the same as for DATESTR(now,'mm/dd/yy')
%   DATESTR(now,'dd.mm.yyyy') returns 24.01.2003
%   To convert a non-standard date form into a standard MATLAB dateform, first
%   convert the non-standard date form to a date number, using DATENUM, 
%   for example, DATESTR(DATENUM('24.01.2003','dd.mm.yyyy'),2) returns 01/24/03.
%
%   See also DATE, DATENUM, DATEVEC, DATETICK.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.32.4.4 $  $Date: 2004/04/10 23:32:15 $
%==============================================================================
% handle input arguments
if (nargin<1) || (nargin>4)
    error('MATLAB:datestr:Nargin',nargchk(1,4,nargin));
end
last = length(varargin);
islocal = 0;
if last > 0
    if strmatch(lower(varargin{end}), 'local','exact')
        islocal = 1;
        last = last - 1;
    elseif strmatch(lower(varargin{end}),'en_us','exact')
        islocal = 0;
        last = last - 1;
    end
end

if last == 0
elseif last == 1
    dateform = varargin{1};
elseif last == 2
    dateform = varargin{1};
    pivotyear = varargin{2};
else
    error('MATLAB:datestr:Nargin','Too many arguments');
end

dateformstr = {};
isdatestr = (ischar(D) || iscellstr(D));


if last > 0
    if ~ischar(dateform);
        % lookup date form string on index
        dateformstr = getdateform(dateform);
    else
        dateformstr = dateform;
    end
end

if last == 2
    if ischar(pivotyear)
        error('MATLAB:datestr:InputClass',...
            'Pivot year must be a number.');
    end
end

% Convert strings and clock vectors to date numbers.
try
    if (size(D,2)==6 && all(all(D(:,1:5)==fix(D(:,1:5)))) &&...
        all(abs(sum(D,2)-2000)<500)) || isdatestr
        if last == 0 || last == 1 || last == 5
            dtnumber = datenum(D);
        else
            dtnumber = datenum(D,pivotyear,dateformstr);
        end
    else
        dtnumber = D;
    end
catch
    error('MATLAB:datestr:ConvertToDateNumber',...
        'Cannot convert input into specified date string.\n%s',lasterr);
end

% Determine format if none specified.  If all the times are zero,
% display using date only.  If all dates are all zero display time only.
% Otherwise display both time and date.
dtnumber = dtnumber(:);
if (last < 1) || (isnumeric(dateform) && (dateform == -1))
   if all(floor(dtnumber)==dtnumber)
      dateformstr = getdateform(1);
   elseif all(floor(dtnumber)==0)
      dateformstr = getdateform(16);
   else
      dateformstr = getdateform(0);
   end
end 

% Handle the empty case properly.  Return an empty which is the same
% length of the string that is normally returned for each dateform.
if isempty(dtnumber)
   try
       if islocal
           S= zeros(0,length(datestr(now,dateformstr,'local')));
       else
           %This is the same as calling with 'en_us' flag
           S= zeros(0,length(datestr(now,dateformstr)));
       end
   catch
      err = lasterror;
      err.message=sprintf('Error using ==> datestr \n%s',...
                        err.message);
      rethrow(err);
   end
   return;
end

try
    % Obtain components using mex file, rounding to integer number of seconds.
    [y,mo,d,h,min,s] = datevecmx(dtnumber,1.);  mo(mo==0) = 1;
catch
    err = lasterror;
    err.identifier = 'MATLAB:datestr:ConvertDateNumber';
    err.message = sprintf('%s\n%s\n%s',...
                          ['DATESTR failed converting date'...
                           ' number to date vector'],...
                          err.message);
    rethrow(err);
end

% format date according to data format template
try
    S = formatdate([y,mo,d,h,min,s],dateformstr,islocal);
catch
    err=lasterror;
    err.message=sprintf('%s in format string %s',...
                        err.message,dateformstr);
    rethrow(err);
end 
S = char(S);
%==============================================================================
function [formatstr] = getdateform(dateform)
% Determine date format string from date format index.
    switch dateform
        case 0,  formatstr = 'dd-mmm-yyyy HH:MM:SS';
        case 1,  formatstr = 'dd-mmm-yyyy';
        case 2,  formatstr = 'mm/dd/yy';
        case 3,  formatstr = 'mmm';
        case 4,  formatstr = 'm';
        case 5,  formatstr = 'mm';
        case 6,  formatstr = 'mm/dd';
        case 7,  formatstr = 'dd';
        case 8,  formatstr = 'ddd';
        case 9,  formatstr = 'd';
        case 10, formatstr = 'yyyy';
        case 11, formatstr = 'yy';
        case 12, formatstr = 'mmmyy';
        case 13, formatstr = 'HH:MM:SS';
        case 14, formatstr = 'HH:MM:SS PM';
        case 15, formatstr = 'HH:MM';
        case 16, formatstr = 'HH:MM PM';
        case 17, formatstr = 'QQ-YY';
        case 18, formatstr = 'QQ';
        case 19, formatstr = 'dd/mm';
        case 20, formatstr = 'dd/mm/yy';
        case 21, formatstr = 'mmm.dd,yyyy HH:MM:SS';
        case 22, formatstr = 'mmm.dd,yyyy';
        case 23, formatstr = 'mm/dd/yyyy';
        case 24, formatstr = 'dd/mm/yyyy';
        case 25, formatstr = 'yy/mm/dd';
        case 26, formatstr = 'yyyy/mm/dd';
        case 27, formatstr = 'QQ-YYYY';
        case 28, formatstr = 'mmmyyyy'; 
        case 29, formatstr = 'yyyy-mm-dd';
        case 30, formatstr = 'yyyymmddTHHMMSS';
        case 31, formatstr = 'yyyy-mm-dd HH:MM:SS';
        otherwise
            error('MATLAB:datestr:DateNumber',...
                'Unknown date format number: %s', dateform);
    end 