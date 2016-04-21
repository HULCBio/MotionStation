function S = dateformverify(D,dateformstr,local)
%Helper function for datevec, to determine if a format is right or not.
%This is a simplified copy of datestr.  Takes as input a date string, and a
%dateformat, and optionally whether to localize or not.  Tries to put the
%string into the format, and return the result.

% Copyright 2003 The MathWorks, Inc.

% handle input arguments
if (nargin<2) || (nargin>3)
    error('MATLAB:dateformverify:Nargin',nargchk(1,3,nargin));
end

islocal = 0;
if nargin == 3
    if strmatch(lower(local), 'local','exact')
        islocal = 1;
    elseif strmatch(lower(local),'en_us','exact')
        islocal = 0;
    end
end

% Convert strings to date numbers.
try
    dtnumber = datenum(D, dateformstr); 
catch
    error('MATLAB:dateformverify:ConvertToDateNumber',...
        'Cannot convert input into specified date string.\n%s',lasterr);
end

dtnumber = dtnumber(:);

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
    err.identifier = 'MATLAB:dateformverify:ConvertDateNumber';
    err.message = sprintf('%s\n%s\n%s',...
                          ['dateformverify failed converting date'...
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

end
