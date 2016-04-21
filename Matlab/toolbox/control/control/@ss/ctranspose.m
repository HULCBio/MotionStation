function tsys = ctranspose(sys)
%CTRANSPOSE  Pertransposition of state-space models.
%
%   TSYS = CTRANSPOSE(SYS) is invoked by tsys = SYS'
%
%   For a continuous-time model SYS with data (A,B,C,D), 
%   CTRANSPOSE produces the state-space model TSYS with
%   data (-A',-C',B',D').  If H(s) is the transfer function 
%   of SYS, then H(-s).' is the transfer function of TSYS.
%
%   For a discrete-time model SYS with data (A,B,C,D), TSYS
%   is the state-space model with data 
%       (AA, AA*C', -B'*AA, D'-B'*AA*C')  with AA=inv(A').
%   Equivalently, H(z^-1).' is the transfer function of TSYS
%   if H(z) is the transfer function of SYS.
%
%   See also TRANSPOSE, SS, LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $  $Date: 2002/04/10 06:02:09 $

sizes = size(sys.d);
Ts = getst(sys);

% Compute pertranspose
tsys = sys;
tsys.d = conj(permute(sys.d,[2 1 3:length(sizes)]));
if Ts==0,
   % Continuous-time case
   for k=1:prod(sizes(3:end)),
      tsys.a{k} = -sys.a{k}';
      tsys.e{k} = sys.e{k}';
      tsys.b{k} = -sys.c{k}';
      tsys.c{k} = sys.b{k}';
   end      
   
else
   % Discrete time
   for k=1:prod(sizes(3:end)),
      % Compute pertranspose matrices
      e = sys.e{k};
      if isempty(e),
         e = 1;
      end
      
      % LU factorization of A
      [l,u,p] = lu(sys.a{k});
      if rcond(u)<eps,
         error('TSYS is improper (the A matrix is singular to working precision).');
      end
      ck = -(u\(l\(p*sys.b{k})))';
      tsys.a{k} = (u\(l\(p*e)))';
      tsys.c{k} = ck;
      tsys.b{k} = ((((sys.c{k}/u)/l)*p)*e)';
      tsys.d(:,:,k) = tsys.d(:,:,k) + ck * sys.c{k}';
   end
   tsys.e = cell(size(tsys.a));
end

% Delete state names
tsys.StateName(:,1) = {''}; 

% LTI property management
tsys.lti = (sys.lti)';

