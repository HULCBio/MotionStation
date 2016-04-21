function Report = arecheckout(X1,X2,Ls)
% Checks for proper extraction of stable invariant subspace.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:13:52 $
X12 = X1'*X2;
Asym = X12-X12';
Asym = max(abs(Asym(:))); % solution asymmetry
n = size(X1,1);

if any(~Ls(1:n)) || any(Ls(n+1:2*n)) || ...
      Asym > max(1e3*eps,0.1*max(abs(X12(:))))
   % Could not (reliably) isolate stable invariant subspace of dimension n
   Report = -1;
else
   Report = 0;
   if Asym > sqrt(eps),
      warning('control:InaccurateSolution',...
         'Solution may be inaccurate due to poor scaling or eigenvalues near the stability boundary.')
   end
end
