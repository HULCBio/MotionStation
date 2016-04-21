function [v,t,m,swap] = cschur(a,odtype)
%CSCHUR Ordered complex Schur form.
%
% [V,T,M,SWAP] = CSCHUR(A,ODTYPE) produces an ordered Complex Schur form
%
%              V' * A * V  = T = |T1  T12|
%                                | 0   T2|,
%
%              m    = no. of stable poles (s or z plane)
%              swap = total no. of swaps.
%
%       The unordered Schur form produced by "schur" is ordered using
%       complex Givens rotation to swap adjacent diagonal terms.
%
%       Six types of ordering can be selected:
%
%         odtype = 1 --- Re(eig(T1)) < 0, Re(eig(T2)) > 0.
%         odtype = 2 --- Re(eig(T1)) > 0, Re(eig(T2)) < 0.
%         odtype = 3 --- eigenvalue real parts in descending order.
%         odtype = 4 --- eigenvalue real parts in ascending order.
%         odtype = 5 --- modulus of eigenvalues in descending order.
%         odtype = 6 --- modulus of eigenvalues in ascending order.
%

% R. Y. Chiang & M. G. Safonov 4/4/86
% Modified by Charles R. Denham, MathWorks, 1989.
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
%---------------------------------------------------------------------
[ma,na] = size(a);
if ~isequal(ma,na), error('CSCHUR(A,..), A matrix must be square'), end
% quick return
if isequal(ma,0), 
   v=a;
   t=a;
   m=0;
   swap=0;
   return
end
%
% -------- Regular Complex Schur Decomposition :
%
[v,t] = schur(a);
[v,t] = rsf2csf(v,t);
[mt,nt] = size(t);
dt = diag(t);
if odtype < 5
   idm = find(real(dt)<zeros(mt,1));
else
   idm = find(abs(dt)<ones(mt,1));
end
[m,dum] = size(idm);
%
% -------- Assign I.C. for the loop counter :
%
pcnt = 0.; kcnt = 0.; gcnt = 0.;

% Predetermine the order of sorting, to avoid possible
%  infinite loop due to round-off errors.

if odtype > 0 & odtype < 7

   if odtype == 1
      d = sign(real(diag(t)));
     elseif odtype == 2
      d = -sign(real(diag(t)));
     elseif odtype == 3
      d = -real(diag(t));
     elseif odtype == 4
      d = real(diag(t));
     elseif odtype == 5
      d = -abs(diag(t));
     elseif odtype == 6
      d = abs(diag(t));
   end

% Simple bubble sorting via Given's rotations.  Matrix t
%  is re-ordered in the same manner as an ascending sort
%  of matrix d.  Then, matrix v is made compatible.  The
%  bubble sort code is reminiscent of the SCHORD function
%  in the Control_Toolbox, but the order of interchanges
%  is different.

   q = eye(nt,nt);
   swap = 0;
   okay = 1;
   while okay
      okay = 0;
      for k = 1:nt-1
         if d(k) > d(k+1)
            okay = 1;
            swap = swap + 1;
            g = givens(t(k,k+1), t(k,k)-t(k+1,k+1));
            t(:,k:k+1) = t(:,k:k+1) * g;
            t(k:k+1,:) = g' * t(k:k+1,:);
            q(:,k:k+1) = q(:,k:k+1) * g;
            temp = d(k); d(k) = d(k+1); d(k+1) = temp;
         end
      end
   end

   v = v * q;

end

% ------ End of CSCHUR.M % RYC/MGS %
