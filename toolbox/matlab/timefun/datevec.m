function [y,mo,d,h,mi,s] = datevec(t,varargin)
%DATEVEC Date components.
%   C = DATEVEC(T) separates the components of date strings and date
%   numbers into date vectors containing [year month date hour mins
%   secs] as columns.  If T is a date string, it must be in one of the
%   date formats 0,1,2,6,13,14,15,16,23 as defined by DATESTR.
%   Certain formats may not contain enough information to compute a date
%   vector.  In those cases, missing values will in general default to 0
%   for hours, minutes, seconds, will default to January for the month, and
%   1 for the day of month.  The year will default to the current year.
%   Date strings with 2 character years are interpreted to be within the 100
%   years centered around the current year.
%
%   [Y,M,D,H,MI,S] = DATEVEC(T) returns the components of the date
%   vector as individual variables.
%
%   C = DATEVEC(T,F) converts the date string T to a date vector C, using the
%   specified date form F to interpret the date string. The date form must be
%   composed of date format symbols according to Table 2 in DATESTR help.
%   See DATEVEC(T) above for details.  Formats with 'Q' are not accepted by
%   datevec.
%
%   [...] = DAVEVEC(T,PIVOTYEAR) uses the specified pivot year as the
%   starting year of the 100-year range in which a two-character year
%   resides.  The default pivot year is the current year minus 50 years.
%
%  C = DATEVEC(T,F,P) or C = DATEVEC(T,P,F) converts the date string T to a date
%  vector C, using the pivot year P and the date form F.
%
%   Examples
%     d = '12/24/1984';
%     t = 725000.00;
%     c = datevec(d) or c = datevec(t) produce c = [1984 12 24 0 0 0].
%     [y,m,d,h,mi,s] = datevec(d) returns y=1984, m=12, d=24, h=0, mi=0, s=0.
%     c = datevec('5/6/03') produces c = [2003 5 6 0 0 0] until 2054.
%     c = datevec('5/6/03',1900) produces c = [1903 5 6 0 0 0].
%     c = datevec('19.05.2000','dd.mm.yyyy') produces c = [2000 5 19 0 0 0].
%
%   See also DATENUM, DATESTR, CLOCK, DATETICK. 

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.28.4.8 $  $Date: 2004/04/10 23:32:17 $

if (nargin<1) || (nargin>3)
    error('MATLAB:datevec:Nargin',nargchk(1,3,nargin));
end

% parse input arguments
isdatestr = (ischar(t) || iscellstr(t));
isdateformat = false;
if nargin > 1
    isdateformat = cellfun('isclass',varargin,'char');
    if (nargin == 3)
        if ~isdateformat(1)
            pivotyear = varargin{1};
        elseif ~isdateformat(2)
            pivotyear = varargin{2};
        elseif isdateformat(1) && isdateformat(2)
            error('MATLAB:datevec:DateFormat',...
                'You specified two date format strings.\nThere can only be one.');
        end 
    elseif (nargin == 2) && ~isdateformat
        pivotyear = varargin{1};
    end
end

if isdatestr && isempty(t)
    if nargout <= 1
        y = zeros(0,6);
	else
		[y,mo,d,h,mi,s] = deal(zeros(0,0));
    end;
	warning('MATLAB:datevec:EmptyDate',...
		'Usage of DATEVEC with empty date strings is not supported.\nResults may change in future versions.');
    return;
end

% branch to appropriate date string parser
if any(isdateformat) || isdatestr
    % a date format string was specified
    % map date format to ICU date format tokens
    if isdatestr && ischar(t)
        % convert to cellstring.
        t = cellstr(t);
    end
    icu_dtformat = {};
    if ~any(isdateformat)
        format = getformat(t);
        if ~isempty(format)
            icu_dtformat = cnv2icudf(format);
        end
    else
        icu_dtformat = cnv2icudf(varargin{isdateformat});
    end
    
    if ~isempty(icu_dtformat)
        % call ICU MEX function to parse date string to date vector
        try
            t = strrep(t,'T','');
            if nargin <= 2
                y = dtstr2dtvecmx(t,icu_dtformat);
            else
				showyr =  findstr(icu_dtformat,'y'); 
				if ~isempty(showyr)
					wrtYr =  numel(showyr);
					checkYr = diff(showyr);
					if any(checkYr~=1)
						error('MATLAB:datevec:YearFormat','Unrecognized year format');
					end
					switch wrtYr
						case 4,
							icu_dtformat = strrep(icu_dtformat,'yyyy','yy');
						case 3,
							icu_dtformat = strrep(icu_dtformat,'yyy','yy');
					end
				end
                y = dtstr2dtvecmx(t,icu_dtformat,pivotyear);
            end
            if nargout > 1
                mo = y(:,2);
                d  = y(:,3);
                h  = y(:,4);
                mi = y(:,5);
                s  = y(:,6);
                y  = y(:,1);
            end
        catch
            err = lasterror;
            err.identifier = 'MATLAB:datevec:dtstr2dtvecmx';
            err.message = sprintf(['DATEVEC failed, calling DTSTR2DTVECMX.\n'... 
                    '%s'],err.message);
            rethrow(err);
        end 
    else
        %last resort!!!
       if ischar(t)
          m = size(t,1);
       else
          m = length(t);
       end
       y = zeros(m,6);
       t = lower(t);
       ampmtokens = lower(getampmtokensmx);
       amtok = ampmtokens{1};
       amtok0 = 'am';
       pmtok = ampmtokens{2};
       pmtok0 = 'pm';
       M = lower(getmonthnames);
       M0 = lower(getmonthnames(0)); % fall-back list of English short month names.
       try
           for i = 1:m
               % Convert date input to date vector
               % Initially, the six fields are all unknown.
               c(1,1:6) = NaN;
               pm = -1; % means am or pm is not in datestr
               if ischar(t)
                   str = t(i,:);
               else
                   str = t{i};
               end
               d = [' ' str ' '];

               % Replace 'a ' or 'am', 'p ' or 'pm' with ': '.
               p = max(find(d == amtok(1) | d == pmtok(1) | ...
                            d == amtok0(1)| d == pmtok0(1)));
               if ~isempty(p)
                   if (d(p+1) == amtok(2) | ...
                       d(p+1) == amtok0(2)| isspace(d(p+1))) & ...
                       d(p-1) ~= lower('e')
                       pm = (d(p) == pmtok(1) | d(p) == pmtok0(1));
                       if d(p-1) == ' '
                           d(p-1:p+1) = ':  ';
                       else
                           d(p:p+1) = ': ';
                       end
                   end
               end

               % Any remaining letters must be in the month field
               p = find(isletter(d));

               % Test length of string to catch a bogus date string.
               % Get index of month in list of months of year
               % replace with spaces, month name in date string.
               % If native month name lookup fails, fall back on 
               % list of English month names.
               if ~isempty(p) && numel(d)>4
                   k = min(p);
                   if d(k+3) == '.', d(k+3) = ' '; end
                   monthidx = ~cellfun('isempty',strfind(M,d(k:k+2)));
                   if ~any(monthidx)
                       monthidx = ~cellfun('isempty',strfind(M0,d(k:k+2)));
                       if ~any(monthidx)
                           error('MATLAB:datevec:MonthOfYear',...
                               'Failed to lookup month of year.');
                       end
                   end
                   c(2) = find(monthidx);
                   d(p) = char(' '*ones(size(p)));
               end

               % Find all nonnumbers.
               p = find((d < '0' | d > '9') & (d ~= '.'));

               % Pick off and classify numeric fields, one by one.
               % Colons delinate hour, minutes and seconds.

               k = 1;
               while k < length(p)
                   if d(p(k)) ~= ' ' && d(p(k)+1) == '-'
                       f = str2double(d(p(k)+1:p(k+2)-1));
                       k = k+1;
                   else
                       f = str2double(d(p(k)+1:p(k+1)-1));
                   end
                   if ~isnan(f)
                       if d(p(k))==':' || d(p(k+1))==':'
                           if isnan(c(4))
                               c(4) = f;             % hour
                               % Add 12 if pm specified and hour isn't 12
                               if pm == 1 && f ~= 12 
                                   c(4) = f+12;
                               elseif pm == 0 && f == 12
                                   c(4) = 0;
                               end
                           elseif isnan(c(5))
                               c(5) = f;             % minutes
                           elseif isnan(c(6)) 
                               c(6) = f;             % seconds
                           else
                               error('MATLAB:datevec:NumberOfTimeFields',...
                                   'Too many time fields in %s', str);
                           end
                       elseif isnan(c(2))
                           if f > 12
                               error('MATLAB:datevec:IllegalDateField',...
                                   '%s is too large to be a month.',num2str(f));
                           end
                           c(2) = f;                % month
                       elseif isnan(c(3))
                           c(3) = f;                % date
                       elseif isnan(c(1))
                           if (f >= 0) & (p(k+1)-p(k) == 3) % two char year
                               if nargin < 2
                                   clk = clock;
                                   pivotyear = clk(1)-50;  %(current year-50 years)
                               end
                               % Moving 100 year window centered around current year
                               c(1) = pivotyear+rem(f+100-rem(pivotyear,100),100);
                           else
                               c(1) = f;             % year
                           end
                       else
                           error('MATLAB:datevec:NumberOfDateFields',...
                               'Too many date fields in %s', str);
                       end
                   end
                   k = k+1;
               end

               if sum(isnan(c)) >= 5
                   error('MATLAB:datevec:ParseDateString',...
                       'Cannot parse date %s', str);
               end
              % If any field has not been specified
               if isnan(c(1)), clk = clock; c(1) = clk(1); end
               if isnan(c(2)), c(2) = 1; end;
               if isnan(c(3)), c(3) = 1; end;
               if isnan(c(4)), c(4) = 0; end;               
               if isnan(c(5)), c(5) = 0; end;                   
               if isnan(c(6)), c(6) = 0; end;

               % Normalize components to correct ranges.
               y(i,:) = datevecmx(datenummx(c));
           end
       catch
           err = lasterror;
           err.message = sprintf('Failed to parse date string.\n%s',...
                                 err.message);
           rethrow(err);
       end 
       if nargout > 1
           mo = y(:,2);
           d  = y(:,3);
           h  = y(:,4);
           mi = y(:,5);
           s  = y(:,6);
           y  = y(:,1);
       end
    end
elseif nargout <= 1
   % date number was specified 
   y = datevecmx(t);
elseif nargout == 3
    % date number was specified and first three date fields for output
   [y,mo,d] = datevecmx(t);
else
   % date number was specified and all six date fields for output
   [y,mo,d,h,mi,s] = datevecmx(t);
end
end

function [format] = getformat(str)
  format = '';
  formatstr = cell(11,1);
  formatstr(1) = {'dd-mmm-yyyy HH:MM:SS'};
  formatstr(2) = {'dd-mmm-yyyy'};
  formatstr(3) = {'mm/dd/yy'};
  formatstr(4) = {'mm/dd'};
  formatstr(5) = {'HH:MM:SS'};
  formatstr(6) = {'HH:MM:SS PM'};
  formatstr(7) = {'HH:MM'};
  formatstr(8) = {'HH:MM PM'};
  formatstr(9) = {'mm/dd/yyyy'};
  formatstr(10) = {'dd-mmm-yyyy HH:MM'};  %used by finance
  formatstr(11) = {'dd-mmm-yy'};  %used by finance
  
  AlphaFormats = [1 1 0 0 0 1 0 1 0 1 1];
  %[1 2 6 8 10 11];
  SlashFormats = [ 0 0 1 1 0 0 0 0 1 0 0];
  %[3 4 9];
  DashFormats = [ 1 1 0 0 0 0 0 0 0 1 1];
  %[1 2 10 11];
  ColonFormats = [1 0 0 0 1 1 1 1 0 1 0];
  %[1 5 6 7 8 10];
  SpaceFormats = [1 0 0 0 0 1 0 1 0 1 0];
  %[1 6 8 10];
  
  bMask = [ 1 1 1 1 1 1 1 1 1 1 1];
  
  if length(str) > 1
      str = str(1,1);
  end
  str = strtrim(char(str));
  slashes = strfind(str, '/');
  if ~isempty(slashes)
	  bMask = bMask & SlashFormats;
	  if (length(slashes) > 0 && slashes(1) == 2)
		  if (length(slashes) > 1 && slashes(2) == 4)
			  str = ['0' str(1:slashes(1)) '0' str(slashes(1)+1:end)];
		  else
			  str = ['0' str];
		  end
	  elseif (length(slashes) > 1 && slashes(2) - slashes(1) == 2)
		  str = [str(1:slashes(1)) '0' str(slashes(1)+1:end)];
	  end
  else
	  bMask = bMask & ~SlashFormats;
  end
  
  dashes = strfind(str,'-');
  if ~isempty(dashes)
	  bMask = bMask & DashFormats;
	  if (length(dashes) > 0 && dashes(1) == 2)
		str = ['0' str];
	  end
  else
	  bMask = bMask & ~DashFormats;	  
  end
  
  colons = strfind(str,':');
  if ~isempty(colons)
	  bMask = bMask & ColonFormats;
	  if (length(colons) > 0) && (colons(1) == 2) && (length(str) - colons(end) > 3)
		str = ['0' str];
	  end
  else
	  bMask = bMask & ~ColonFormats;
  end      
  
  spaces = strfind(str,' ');
  if ~isempty(spaces)
	  bMask = bMask & SpaceFormats;
  else
	  bMask = bMask & ~SpaceFormats;
  end
  
  for i = 1:11
	  if bMask(i)
		  try
			  str1 = dateformverify(str,char(formatstr(i)));
			if (strcmpi(str, strtrim(str1)) == 1)
				format = char(formatstr(i));
				break;
			end
		  catch
			   lasterr('');
		  end
		  if AlphaFormats(i)
			  try
				str1 = dateformverify(str,char(formatstr(i)),'local');
				if (strcmpi(str, strtrim(str1)) == 1)
					format = char(formatstr(i));
					break;
				end
			  catch
				lasterr('');
			  end       
		  end
	  end
  end
end 
