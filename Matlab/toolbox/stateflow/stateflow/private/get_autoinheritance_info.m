function result = get_autoinheritance_info(sfunName, chartNumber) 

% Copyright 2004 The MathWorks, Inc.

    result = [];
    
    if (exist(sfunName) == 3)
        result = feval(sfunName, 'get_autoinheritance_info', chartNumber);
    end