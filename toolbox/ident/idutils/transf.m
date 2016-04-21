
function [Ts,argnew] = transf(argold,npar)
%TRANSF  Transform old syntax to new for pem
%   
%   [Ts,argnew] = TRANSF(argold,npar)
%
%   argold: old input argument.
%   argnew: new input argument
%   Ts: Sampling Interval
%   npar: a flag

%
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:56 $


ml=length(argold);
Ts = [];
if nargin < 2
   npar = -1;
end

if npar < 0
   prop={'maxiter','tol','lim','maxsize','Ts'};
else
   prop={'fixedpar','maxiter','tol','lim','maxsize','Ts'};
end

for kk=1:ml
   if strcmp(argold(kk),'trace');
      argnew{2*kk-1}='trace';argnew{2*kk}='Full';
   else
      if kk==1&~isempty(argold{kk})&npar>0
         argold{kk}=indinvert(argold{kk},npar);
      end
      
      argnew{2*kk-1}=prop{kk};
      argnew{2*kk}=argold{kk};
      if strcmp(prop{kk},'Ts')
         Ts = argold{kk};
      end
      
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:56 $
function ind3 = indinvert(ind1,npar)
 if npar==0
   error('Transformation of old syntax for INDEX failed.')
end

ind2 = [1:npar]';
indt = ind2*ones(1,length(ind1))~=ones(npar,1)*ind1(:)';
if size(indt,2)>1, indt=all(indt');end
ind3 = ind2(find(indt));

 
