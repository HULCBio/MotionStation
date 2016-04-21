function months = getmonths(base, varargin)
% GETMONTHS Return full names of months of year for defined calendar.
% To be reimplemented after calender class becomes available.

% Copyright 2002-2003 The MathWorks, Inc.


if nargin>0 && base == 0
    %retained for backward compatibility
    months = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
elseif nargin > 1 
    isshort = 1;
    isenglish = 1;
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
    
    months = getmonthnamesmx(form);
else
    if strncmpi(get(0,'lang'),'ja',2) || strncmpi(get(0,'lang'),'ch',2)
        % get long month names for Japanese
        % to avoid ambiguity with date forms of format dd-mm-yyyy
        months = getmonthnamesmx('longloc');
    else
        months = getmonthnamesmx;
    end
end

