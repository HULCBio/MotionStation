function thd = sethidmo(thd,fcn,varargin);
% SETHIDMO
% Help function to c2d and d2c to do the right thing with the hidden
% models.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2004/04/10 23:17:38 $


P = thd.CovarianceMatrix;
if ischar(P)
   cov = 0;
else
   cov = 1;
end 
ut = pvget(thd,'Utility');  
try
   pol=ut.Idpoly;  
catch
   pol=[];
end
if ~cov
   pol =[];
end
try
   Pmod = ut.Pmodel;
catch
   Pmod = [];
end
if ~cov
   Pmod = [];
end

if ~isempty(Pmod)
   if fcn=='d2c'
      Pmod = d2c(Pmod,varargin{:});
   else
      Pmod = c2d(Pmod,varargin{:});
   end
end

ut.Pmodel = Pmod;
if ~isempty(pol)
    was = warning;
    warning off
   for kk=1:length(pol)
      if ~isempty(pol{kk})
          
         if fcn=='d2c'
            pol1{kk} = d2c(pol{kk},varargin{:});
         else
            pol1{kk} = c2d(pol{kk},varargin{:});
         end
         
      else 
         pol1{kk}=[];
      end
   end
   warning(was)
else
   pol1 =[];
end    
ut.Idpoly=pol1;

thd=pvset(thd,'Utility',ut); 

