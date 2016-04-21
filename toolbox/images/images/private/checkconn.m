function checkconn(conn,function_name,variable_name,arg_position)
%CHECKCONN Check validity of connectivity argument.
%    CHECKCONN(CONN) issues an error message if CONN is not a valid
%    connectivity array.

%    Copyright 1993-2003 The MathWorks, Inc.
%    $Revision: 1.6.4.3 $  $Date: 2003/08/23 05:53:35 $

checkinput(conn,{'double' 'logical'},{'real' 'nonsparse'},...
           function_name,variable_name,arg_position);

if all(size(conn) == 1)
    if (conn ~= 1) && (conn ~= 4) && (conn ~= 8) && (conn ~= 6) && ...
                (conn ~= 18) && (conn ~= 26)

        msgId = sprintf('Images:%s:badScalarConn', function_name);
        msg1 = first_line(variable_name, function_name, arg_position);
        msg2 = 'A scalar connectivity specifier must be 1, 4, 6, 8, 18, or 26.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
else
    if any(size(conn) ~= 3)
        msgId = sprintf('Images:%s:badConnSize', function_name);
        msg1 = first_line(variable_name, function_name, arg_position);
        msg2 = 'A nonscalar connectivity specifier must be 3-by-3-by- ... -by-3.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
    
    if any((conn(:) ~= 1) & (conn(:) ~= 0))
        msgId = sprintf('Images:%s:badConnValue', function_name);
        msg1 = first_line(variable_name, function_name, arg_position);
        msg2 = 'A nonscalar connectivity specifier must contain only 0s and 1s.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
    
    if conn((end+1)/2) == 0
        msgId = sprintf('Images:%s:badConnCenter', function_name);
        msg1 = first_line(variable_name, function_name, arg_position);
        msg2 = 'The central element of a connectivity specifier must be nonzero.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
    
    if ~isequal(conn(1:end), conn(end:-1:1))
        msgId = sprintf('Images:%s:nonsymmetricConn', function_name);
        msg1 = first_line(variable_name, function_name, arg_position);
        msg2 = 'A connectivity specifier must be symmetric about its center.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = first_line(variable_name, function_name, arg_position)

str = sprintf('Function %s expected its %s input argument, %s,\nto be a valid connectivity specifier.', ...
              upper(function_name), num2ordinal(arg_position), variable_name);
