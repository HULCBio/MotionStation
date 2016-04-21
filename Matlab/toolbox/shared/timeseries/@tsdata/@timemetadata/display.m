function display(h)
%DISPLAY @timemetadata display method
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:37 $


fprintf(1,'%s\n\n','Time Series Meta Data Object');

if h.Length>0
    if ~isnan(h.Increment)
        strInterval = 'Interval:';
        strLength = 'Length:';
        fprintf(1,'%s\n      %s%s%0.2g %s\n      %s%s%d\n\n', ...
            'Uniformly sampled time vector with:',strInterval, blanks(22-length(strInterval)),h.Increment, ...
            h.Units, strLength, blanks(22-length(strLength)),h.Length);
    else
        fprintf(1,'%s %d\n','Non uniformly sampled of length',h.Length)
    end
    
    % If a start date is defined use it to convert the relative start and
    % end times into absolute start and end times with the right format
    if ~isempty(h.Startdate)
        fprintf(1,'%s%s\n','Defined relative to an absolute start date/time of: ',h.Startdate);
        if ~isempty(h.Format)
            startstr = datestr(datenum(h.Startdate)+tsunitconv('days',h.Units)*h.Start,h.Format);
            endstr = datestr(datenum(h.Startdate)+tsunitconv('days',h.Units)*h.End,h.Format);
        else
            startstr = datestr(datenum(h.Startdate)+tsunitconv('days',h.Units)*h.Start);
            endstr = datestr(datenum(h.Startdate)+tsunitconv('days',h.Units)*h.End);
        end
        str1 = 'Start time';
        fprintf(1,'      %s%s%s\n', str1, blanks(22-length(str1)), startstr);
        str1 = 'End time';
        fprintf(1,'      %s%s%s\n', str1, blanks(22-length(str1)), endstr);
    else
        fprintf(1,'%s\n','Representing a relative time vector with:')
        str1 = 'Start time';
        fprintf(1,'      %s%s%0.2g %s\n', str1, blanks(22-length(str1)), h.Start, h.Units);
        str1 = 'End time';
        fprintf(1,'      %s%s%0.2g %s\n', str1, blanks(22-length(str1)), h.End, h.Units);        
    end
  
else
    fprintf(1,'      %s\n', 'Empty');
end
