function A = getArray(this,Variable)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(Container,Variable)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:48 $
f = this.FileName;
v = Variable.Name;
try
   S = load(f,v);
   A = S.(v);
catch
   A = [];
   warning(sprintf(...
      'Data file %s cannot be found or does not contain variable %s.',f,v))
end