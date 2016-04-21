function kk = isempty(m)
%IDPOLY/ISEMPTY
%   ISEMPTY(Model)
%   Returns 1 if the model is empty

%   $Revision: 1.7.4.1 $ $Date: 2004/04/10 23:16:36 $
%   Copyright 1986-2003 The MathWorks, Inc.


kk = false;
[ny,nu] = size(m);
if isempty(m.na)|(nu==0&pvget(m,'NoiseVariance') == 0)
   kk =true;
end
 
