%ADDTODATE Add a quantity to a date field.
%   R = ADDTODATE(D,N,T) will add a quantity N to date field T of date number N,
%   and return the new date string R. 
%
%   INPUT PARAMETERS:
%   D:  double scalar, defining the date number (see DATENUM for definition)
%   N:  double scalar, defining the quantity to add to N
%   T:  char vector, defining the date field to add to (see NOTE 1).
%
%   RETURN PARAMETERS:
%   R:  double scalar, returning the new date number.
%
%   NOTE 1: valid values are 'year', 'month', 'day'.
%   
%   Examples:
%   R = ADDTODATE(now,20,'day') will add 20 days to the current date and time
%   and return the result in R.
%
%   R = ADDTODATE(DATENUM('20.01.2002','dd.mm.yyyy'),20,'day') will add 20 days
%   to the date 20 January 2002, which is first converted to a date number by
%   the nested call to DATENUM, and return the result in R.
%
%   R = DATEVEC(ADDTODATE(now,20,'day')) will add 20 days to the current date
%   and time, convert the result to a date vector, returned in R.
%
%   See also DATENUM, DATEVEC, DATESTR.

%   Copyright 2004 The MathWorks, Inc. 

%==============================================================================
function R = addtodate(d,n,t)

% Copyright 2002 The MathWorks, Inc.

% initialise variables
validfields = {'year','month','day'};

% check number of input arguments
if nargin < 3
    error('MATLAB:addtodate:Nargin','Invalid number of arguments.');
end
% validate input arguments
if ~isnumeric(d)
    error('MATLAB:addtodate:InputClass','Date number must be numeric.');
end
if ~isnumeric(n)
    error('MATLAB:addtodate:InputClass','Quantity must be numeric.');
end
if ~ischar(t)
    error('MATLAB:addtodate:InputClass','Date field must be a char string.');
end

% find matching datefield
datefield = strfind(validfields,t);
if all(cellfun('isempty',datefield))
    error('MATLAB:addtodate:DateField',...
        'Date field "%s" is invalid. Date field must be one of { %s}.',...
        t,sprintf('%s ',validfields{:}));
else
    R = addtodatemx(d,n,find(~cellfun('isempty',datefield)));
end

%==============================================================================


