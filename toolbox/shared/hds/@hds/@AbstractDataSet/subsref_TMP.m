function x = subsref(this,Struct)
% Subscripted reference for data set objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:22 $
if isempty(Struct)
   x = this; return
end
try
   switch Struct(1).type
      case '.'
         % Errors out for methods!!
         x = subsref(this.(Struct(1).subs),Struct(2:end));
      case '()'
         x = subsref(this.slice(Struct(1).subs{:}),Struct(2:end));
      case '{}'
         error('Invalid indexing syntax into data set object.')
   end
catch
   rethrow(lasterror)
end
