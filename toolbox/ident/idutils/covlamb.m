function P = covlamb(L,N)
% COVLAMB Covariance matrix of Cholesky factor of
%      estimated noise covariance matrix

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/10 23:18:21 $


%%LL%% note this should ignore zeros i L, i.e.
% treat zeros in L as non-estimated with no covariance %%EJ GJORT%%
if isempty(N)|N==0, N = inf; end
lam = L*L';
ny = size(lam,1);
s1 = 1;
for i1 = 1:ny
   for j1 = 1:i1
      s2 = 1;
      for i2=1:ny
         for j2 = 1:i2
            lamcov(s1,s2) = lam(i1,i2)*lam(j1,j2)+lam(i1,j2)*lam(j1,i2);
            der = 0;
            for k=1:min(i1,j1)
               if i1==i2&k==j2
                  der = der+L(j1,k);
               end
               if j1==i2&k==j2
                  der = der+L(i1,k);
               end
            end
            dlamdL(s1,s2) = der;
            s2 = s2+1;
         end
      end
      s1 = s1+1;
   end
end
Di = inv(dlamdL);
P = Di*lamcov*Di'/N;
 
