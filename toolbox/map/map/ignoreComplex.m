function A = ignoreComplex(A, function_name, variable_name) 
%IGNORECOMPLEX Convert complex input to real and issue warning.
%   IGNORECOMPLEX(A, FUNCTION_NAME, VARIABLE_NAME) replaces complex A with
%   its real part and issues a warning.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:16:39 $

if ~isnumeric(A)
    eid = sprintf('%s:%s:nonNumericInput', getcomp, function_name);
    msg = sprintf('Function %s expected its argument %s to be numeric.',...
                  function_name, variable_name);
    error(eid,'%s',msg);
end

if ~isreal(A)
    wid = sprintf('%s:%s:ignoringComplexArg', getcomp, function_name);
    warning(wid,'Imaginary parts of complex argument %s ignored in function %s.',...
            upper(variable_name), upper(function_name));
	A = real(A);
end
