function kk = isempty(m)
%IDARX/ISEMPTY
%   ISEMPTY(Model)
%   Returns TRUE (1) if the model is empty

%   $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:15:07 $
%   Copyright 1986-2003 The MathWorks, Inc.


kk = false;
%return
if isempty(m.na)
   kk =true;
else
   if sum(sum([m.na,m.nb])')==0
      kk= true;
   end
end
