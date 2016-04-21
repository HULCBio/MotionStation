function varargout = evalc(tryVal,catchVal)
%EVALC for Java strings.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/15 04:14:28 $

tryVal = fromOpaque(tryVal);

if nargin==2,
  catchVal = fromOpaque(catchVal);
  if nargout>0,
    varargout{1:nargout} = evalc(tryVal,'evalc(catchVal,''error(lasterr)'')');
  else
    evalc(tryVal,'evalc(catchVal,''error(lasterr)'')');
  end
else
  if nargout>0,
    varargout{1:nargout} = evalc(tryVal);
  else
    evalc(tryVal);
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
