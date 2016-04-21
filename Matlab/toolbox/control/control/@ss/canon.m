function [sys,T] = canon(sys,Type)
%CANON  Canonical state-space realizations.
%
%   CSYS = CANON(SYS,TYPE) computes a canonical state-space 
%   realization CSYS of the LTI model SYS.  The string TYPE
%   selects the type of canonical form:
%     'modal'    :  Modal canonical form where the system 
%                   eigenvalues appear on the diagonal. 
%                   The state matrix A must be diagonalizable.
%     'companion':  Companion canonical form where the characteristic
%                   polynomial appears in the right column.
%
%   [CSYS,T] = CANON(SYS,TYPE) also returns the state transformation 
%   matrix T relating the new state vector z to the old state vector
%   x by z = Tx.  This syntax is only meaningful when SYS is a 
%   state-space model.
%
%   The modal form is useful for determining the relative controll-
%   ability of the system modes.  Note: the companion form is ill-
%   conditioned and should be avoided if possible.
%
%   See also SS2SS, CTRB, CTRBF, SS.

%   Clay M. Thompson  7-3-90
%   Revised: P. Gahinet  6-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:02:12 $

error(nargchk(1,2,nargin));

if nargin==1,   % No type specified, assume modal 
   Type = 'modal';
elseif ~isstr(Type),
   error('TYPE must be a string.');
elseif ndims(sys)>2,
   error('Not available for arrays of state-space models.')
end

[a,b,c,d] = ssdata(sys);     
  
% --- Determine 'type' -- Only check 1st three letters.
switch Type(1:3)
case 'mod'
    % Modal form
    [V,D] = eig(a);
    if isreal(a)
        lambda = diag(D);
        % Transformation to modal form based on eigenvectors
        k = 1;
        while k<=length(lambda)
            if imag(lambda(k)) ~= 0
                rel = real(lambda(k));
                iml = imag(lambda(k));
                T(:,k) = real(V(:,k)); 
                T(:,k+1) = imag(V(:,k));
                D(k:k+1,k:k+1) = [rel iml;-iml rel];
                k = k+2;
            else
                T(:,k) = V(:,k);
                k = k+1;
            end
        end
    else
        T = V;
    end
    sys.a{1} = D;
    
case 'com'
  % Companion form
  % Transformation to companion form based on controllability matrix
  if length(b)
    T = ctrb(a,b(:,1));
    if rcond(T)<eps, 
      error('System must be controllable from first input.'), 
    end
  else
    T = [];
  end
  sys.a{1} = T\a*T; 

otherwise
  error('TYPE must be either ''modal'' or ''companion''.');
end

sys.b = {T\b}; 
sys.c = {c*T}; 
sys.e = {[]};

if nargout==2,  % Return inverse of T to be compatible with ss2ss
  T = inv(T);
end

