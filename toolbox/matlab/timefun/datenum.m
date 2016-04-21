function n = datenum(arg1,arg2,arg3,h,min,s)
%DATENUM Serial date number.
%   N = DATENUM(S) converts the string or date vector (as defined by 
%   DATEVEC) S into a serial date number.  Date numbers are serial days 
%   where 1 corresponds to 1-Jan-0000.  If S is a string, it must be in 
%   one of the date formats 0,1,2,6,13,14,15,16,23 as defined by
%   DATESTR.
%   Certain formats may not contain enough information to compute a date
%   number.  In those cases, missing values will in general default to 0
%   for hours, minutes, seconds, will default to January for the month, and
%   1 for the day of month.  The year will default to the current year.
%   Date strings with 2 character years are interpreted to be within the 
%   100 years centered around the current year.  
%
%   N = DATENUM(S,PIVOTYEAR) uses the specified pivot year as the
%   starting year of the 100-year range in which a two-character year
%   resides.  The default pivot year is the current year minus 50 years.
%
%   N = DATENUM(S,F) uses the specified date form F to interpret the date string
%   S during the conversion to a date number N. The date form must be
%   composed of date format symbols according to Table 2 in DATESTR help.
%   See DATENUM(S) above for details.  Formats with 'Q' are not accepted by
%   datenum.
%
%   N = DATENUM(S,F,P) or N = DATENUM(S,P,F) uses the specified date form F and
%   the pivot year P to determine the date number N, given the date string S.
%
%   The input can be a one-dimensional (row or column) string array or 
%   cell array of strings; the resulting output is a column vector of date
%   numbers.
%
%   N = DATENUM(Y,M,D) and N = DATENUM([Y,M,D]) return the serial date
%   numbers for corresponding elements of the Y,M,D (year,month,day) arrays.
%   Y, M, and D must be arrays of the same size (or any can be a scalar).
%
%   N = DATENUM(Y,M,D,H,MI,S) and N = DATENUM([Y,M,D,H,MI,S]) return the
%   serial date numbers for corresponding elements of the Y,M,D,H,MI,S
%   (year,month,day,hour,minute,second) arrays.  The six arguments must
%   be arrays of the same size (or any can be a scalar).  Values outside
%   the normal range of each array are automatically carried to the next
%   unit (for example month values greater than 12 are carried to years).
%   Month values less than 1 are set to be 1; all other units can wrap 
%   and have valid negative values.
%
%   Examples:
%       n = datenum('19-May-2000') returns n = 730625.
%       n = datenum(2001,12,19) returns n = 731204.
%       n = datenum(2001,12,19,18,0,0) returns n = 731204.75.
%       n = datenum('19.05.2000','dd.mm.yyyy') returns n = 730625.75.
%
%   See also NOW, DATESTR, DATEVEC, DATETICK.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.24.4.5 $  $Date: 2004/04/10 23:32:14 $

if (nargin<1) || (nargin>6)
    error('MATLAB:datenumr:Nargin',nargchk(1,6,nargin));
end

% parse input arguments
isdatestr = (ischar(arg1) || iscellstr(arg1));
isdateformat = false;
if nargin == 2
    isdateformat = ischar(arg2);
elseif nargin == 3
    isdateformat = [ischar(arg2),ischar(arg3)];
end
% try to convert date string or date vector to a date number
try
    switch nargin
        case 1 
            if isdatestr
                n = datenummx(datevec(arg1));
            elseif (size(arg1,2)==3) || (size(arg1,2)==6)
                n = datenummx(arg1);
            else
                n = arg1;
            end
        case 2
            if isdateformat
                if ischar(arg1)
					arg1 = strrep(cellstr(arg1),'T','');
                else
					%arg1 is already a cell array
					arg1 = strrep(arg1,'T','');
				end
                n = dtstr2dtnummx(arg1,cnv2icudf(arg2));
            else
                n = datenummx(datevec(arg1,arg2));
            end
        case 3
			if any(isdateformat)
				if isdateformat(1) 
					format = arg2;
					pivot = arg3;
				elseif isdateformat(2)
					format = arg3;
					pivot = arg2;
				end
				if ischar(arg1)
					arg1 = cellstr(arg1);
				end
				arg1 = strrep(arg1,'T','');
				icu_dtformat = cnv2icudf(format);
				showyr =  strfind(icu_dtformat,'y'); 
				if ~isempty(showyr)
					wrtYr =  numel(showyr);
					checkYr = diff(showyr);
					if any(checkYr~=1)
						error('MATLAB:datenum:YearFormat','Unrecognized year format');
					end
					switch wrtYr
						case 4,
							icu_dtformat = strrep(icu_dtformat,'yyyy','yy');
						case 3,
							icu_dtformat = strrep(icu_dtformat,'yyy','yy');
					end
				end
				n = dtstr2dtnummx(arg1,icu_dtformat,pivot);
			else
                n = datenummx(arg1,arg2,arg3);
			end
        case 6, n = datenummx(arg1,arg2,arg3,h,min,s);
        otherwise, error('MATLAB:datenum:Nargin',...
                         'Incorrect number of arguments');
    end
catch
    err = lasterror;
    err.message = sprintf('DATENUM failed.\n%s',err.message);
    
    if (nargin == 1 && ~isdatestr)
        err.identifier = 'MATLAB:datenum:ConvertDateNumber';
    elseif (nargin == 1 && isdatestr) || (isdatestr && any(isdateformat))
        err.identifier = 'MATLAB:datenum:ConvertDateString';
    elseif (nargin > 1) && ~isdatestr && ~any(isdateformat)
        err.identifier = 'MATLAB:datenum:ConvertDateVector';
    end
 
    rethrow(err);
end
