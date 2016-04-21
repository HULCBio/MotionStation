function [a, b] = d2c(phi, gamma, t)
%D2C  Conversion of discrete LTI models to continuous time.
%
%   SYSC = D2C(SYSD,METHOD) produces a continuous-time model SYSC
%   that is equivalent to the discrete-time LTI model SYSD.  
%   The string METHOD selects the conversion method among the 
%   following:
%      'zoh'       Assumes zero-order hold on the inputs.
%      'tustin'    Bilinear (Tustin) approximation.
%      'prewarp'   Tustin approximation with frequency prewarping.  
%                  The critical frequency Wc is specified last as in
%                  D2C(SysD,'prewarp',Wc)
%      'matched'   Matched pole-zero method (for SISO systems only).
%   The default is 'zoh' when METHOD is omitted.
%
%   See also C2D, D2D, LTIMODELS.

%   J.N. Little 4-21-85
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2004/04/10 23:13:32 $

error(nargchk(3,3,nargin));
[msg,phi,gamma]=abcdchk(phi,gamma); error(msg);

[m,n] = size(phi);
[m,nb] = size(gamma);

% phi = 1 case cannot be computed through matrix logarithm.  Handle
% as a special case.
if m == 1
    if phi == 1
        a = 0; b = gamma/t;
        return
    end
end

% Remove rows in gamma that correspond to all zeros
b = zeros(m,nb);
nz = 0;
nonzero = [];
for i=1:nb
    if any(gamma(:,i)~=0) 
        nonzero = [nonzero, i];
        nz = nz + 1;
    end
end

% Do rest of cases using matrix logarithm.
ws = warning('off','MATLAB:logm:obsoleteEstErr'); % Disable Backward compatability warning
[s, exitflag] = logm([[phi gamma(:,nonzero)]; zeros(nz,n) eye(nz)]);
warning(ws); % Renable Backward compatability warning
s = s/t;
if exitflag || norm(imag(s),'inf') > sqrt(eps)
   warning('Accuracy of d2c conversion may be poor.')
end
s = real(s);
a = s(1:n,1:n);
if length(b)
   b(:,nonzero) = s(1:n,n+1:n+nz);
end


