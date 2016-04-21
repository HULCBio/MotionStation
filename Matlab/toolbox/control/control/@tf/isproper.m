function boo = isproper(sys)
%ISPROPER  True for proper LTI systems.
%
%   ISPROPER(SYS) returns 1 (true) if the LTI model SYS is proper 
%   (relative degree<=0), and 0 (false) otherwise.  If SYS is an
%   array of LTI models, ISPROPER(SYS) is true if all models are
%   proper.
%
%   See also ISSISO, ISEMPTY, LTIMODELS.

%   Author(s): P. Gahinet, 4-1-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/10 23:13:45 $

den = sys.den;
boo=true;

for i=1:prod(size(den)),
   if den{i}(1)==0,
      boo = false;
      return
   end
end
      
