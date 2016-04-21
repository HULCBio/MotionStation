function [d,w] = weekday(t, varargin)
%WEEKDAY Day of week.
%   [D,W] = WEEKDAY(T) returns the day of the week in numeric and 
%   string form given T, a serial date number or a date string. This
%   returns the short English days of the week.
%
%   [D, W] = WEEKDAY(T, FORM) :
%   [D, W] = WEEKDAY(T, LOCALE):
%   [D, W] = WEEKDAY(T, FORM, LOCALE):
%   The form argument can be one of:
%           short   --      short days of the week  (Default)
%           long    --      long days of the week
%   The locale argument can be one of:
%           local   --      Use local format
%           en_US   --      Use default, US English format  (Default)
%   
%   Both of these arguments are optional and can come in any order,
%   following the date number.
%
%   The days of the week are assigned the following values, for the
%   English locales:
%
%                       1     Sun
%                       2     Mon
%                       3     Tue
%                       4     Wed
%                       5     Thu
%                       6     Fri
%                       7     Sat
%
%   For other language locales, the second return argument will
%   contain the equivalent weekday name for that locale.
%
%   For example, [d,w] = weekday(728647) or [d,w] = weekday('19-Dec-1994')
%   returns d = 2 and w = Mon for the English locales.
% 
%   See also EOMDAY, DATENUM, DATEVEC.
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2004/04/10 23:33:09 $

if ischar(t)
    try
        t = datenum(t); 
    catch
        err = lasterror;
        err.identifier = 'MATLAB:weekday:ConvertDateString';
        rethrow(err);
    end
end
isshort = 1;
isenglish = 1;
if (nargin > 1 && nargout > 1)
    i = 1;
    while (i <= length(varargin))
        if strmatch(lower(varargin(i)), 'local','exact')
            isenglish = 0;
        elseif strmatch(lower(varargin(i)), 'en_us','exact')
            isenglish = 1;
        elseif strmatch(lower(varargin(i)), 'short','exact')
            isshort = 1;
        elseif strmatch(lower(varargin(i)), 'long','exact')
            isshort = 0;
        end
        i = i + 1;
    end
    if isenglish 
        if isshort
            form = 'short';
        else
            form = 'long';
        end
    else
         if isshort
            form = 'shortloc';
        else
            form = 'longloc';
        end
    end     
    
    if ischar(form)
        week = getweekdaynamesmx(form);
    end;
else
    week = getweekdaynamesmx;
end;
d = mod(fix(t)-2,7)+1;
w = strvcat(week{d});

