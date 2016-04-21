function varargout = eval(tryVal,catchVal)
%EVAL for Java strings.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2002/12/10 10:59:46 $

tryVal = fromOpaque(tryVal);

if nargin==2,
  catchVal = fromOpaque(catchVal);
  if nargout>0,
    varargout{1:nargout} = evalin('caller', tryVal, 'evalin(''caller'', catchVal,''error(lasterr)'')');
  else
    eval(tryVal,'evalin(''caller'', catchVal,''error(lasterr)'')');
  end
else
  if nargout>0,
    varargout{1:nargout} = evalin('caller', tryVal);
  else
    evalin('caller', tryVal);
  end
end

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(sprintf('Conversion to char from %s is not possible.', class(x)));
end
