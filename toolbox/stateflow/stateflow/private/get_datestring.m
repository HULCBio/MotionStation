function str = get_datestring(varargin)
%
%
%

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/04/15 00:58:01 $

str = '';

switch nargin, 
    case 1, 
        switch (varargin{1}),
            case 'now', str = sf_date_str;
            otherwise,  
        end;
    otherwise, 
end;

    
