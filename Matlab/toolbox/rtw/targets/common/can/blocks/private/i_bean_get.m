function val = i_bean_get(bean,prop)
%I_BEAN_GET :   convert Java bean properties to MATLAB properties
%   bean    :   Java bean
%   prop    :   char array property to get          

%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $
%   $Date: 2004/04/19 01:19:33 $

% note upper case conversion of first character of char array prop
try
    % eg. message.getLength
    method = ['get' upper(prop(1)) prop(2:end) ];
    val = eval(['bean.' method]);
catch
    % eg. message.isDataIsExternal
    method = ['is' upper(prop(1)) prop(2:end) ];
    val = eval(['bean.' method]);
end

% post processing stage to convert types to desired MATLAB types
switch (class(val))
    case 'java.lang.String'
        % convert java strings to matlab strings
        val = char(val);
    case 'logical'
        % convert logical array to a numeric double array
        % note: DataIsExternal is the only boolean type we use
        % it is not actually used during Code Generation.
        val = double(val);
end

return;
