function h = freqresp(sys,w)
%FREQRESP  Frequency response of LTI models.
%
%   H = FREQRESP(SYS,W) computes the frequency response H of the 
%   LTI model SYS at the frequencies specified by the vector W.
%   These frequencies should be real and in radians/second.  
%
%   If SYS has NY outputs and NU inputs, and W contains NW frequencies, 
%   the output H is a NY-by-NU-by-NW array such that H(:,:,k) gives 
%   the response at the frequency W(k).
%
%   If SYS is a S1-by-...-Sp array of LTI models with NY outputs and 
%   NU inputs, then SIZE(H)=[NY NU NW S1 ... Sp] where NW=LENGTH(W).
%
%   See also EVALFR, BODE, SIGMA, NYQUIST, NICHOLS, LTIMODELS.

%	 Clay M. Thompson 7-10-90
%   Revised: AFP 9-10-95, P.Gahinet 5-2-96
%	 Copyright 1986-2004 The MathWorks, Inc.
%	 $Revision: 1.35.4.3 $  $Date: 2004/04/10 23:13:25 $

%       Reference:
%       Alan J. Laub, "Efficient Multivariable Frequency Response Computations,"
%       IEEE TAC, AC-26 (April 1981), 407-8.


error(nargchk(2,2,nargin));
if ~isa(w,'double') | ndims(w)>2 | min(size(w))>1,
   error('W must be a vector of real frequencies.')
end
w = w(:);

% Loop over each model:
sizes = size(sys.d);
h = zeros([sizes(1:2) , length(w) , sizes(3:end)]);

for k=1:prod(sizes(3:end)),
   h(:,:,:,k) = fr2d(subsref(sys,substruct('()',{':' ':' k})),w);
end


%%%%%%%%%%%%%% Local function %%%%%%%%%%%%%%%%%%%%%%%%

%FR2D  Frequency response of single model
function h = fr2d(sys,w)

% Note: Performs balancing, descriptor systems allowed
dess = ~isempty(sys.e{1});
if dess
    [a,b,c,d,e,Ts] = dssdata(sys);
else
    [a,b,c,d,Ts] = ssdata(sys);  e = [];
end    
[ny,nu] = size(d);
nx = size(a,1);

% Compute I/O delay contribution
Td = totaldelay(sys);
isdelayed = any(Td(:));

% Form vector s of complex frequencies
lw = length(w);
if Ts==0,
   % Watch for case where W contains complex frequencies (old syntax)
   if isreal(w),
      w = sqrt(-1)*w;
   end
   s = w;
elseif isreal(w),
   % Discrete with real freqs
   w = sqrt(-1)*w*abs(Ts);
   s = exp(w);  % z = exp(j*w*Ts)
else
   % Discrete with complex frequencies (old syntax)
   s = w;
   w = log(s);
end

% Quick exit if empty system or static gain
if ny*nu==0,
   h = zeros(ny,nu,lw);  
   return
elseif nx==0,
   h = d(:,:,ones(1,lw));
   if isdelayed,
      h = delayfr(Td,w) .* h;
   end
   return
end

% Compute the frequency response over grid W
infs = isinf(s);
lwarn = lastwarn;warn = warning('off');

% Balancing
if dess,
   % Descriptor case: always balance
   [a,e,scx,perm] = aebalance(a,e);
   b(perm,:) = lrscale(b,1./scx,[]);
   c(:,perm) = lrscale(c,[],scx);
else
    % Regular case: balance only when ||A||>>rho(|A|))
    % Estime rho(|A|)
    aa = abs(a);
    v = ones(nx,1)/sqrt(nx);
    for k=1:10,
        v = aa*v;   
        rhoA = norm(v);
        if rhoA,
            v = v/rhoA;
        else
            break
        end
    end
    
    % If ||A||>>rho(A), balance A matrix to reduce sensitivity to
    % round-off introduced by HESS(A)
    nrma = norm(a,1);
    if nrma>1e3*rhoA,
       [scx,perm,aa] = balance(a);
       if norm(aa,1)<nrma/2
          % See g209493
          a = aa;
          b(perm,:) = lrscale(b,1./scx,[]);
          c(:,perm) = lrscale(c,[],scx);
       end
    end
end

% Use MIMOFR to evaluate frequency response
h = mimofr(a,b,c,e,s);

% Restore warning state and issue warning
warning(warn);lastwarn(lwarn);

% Add D matrix and delay contributions
h = h + d(:,:,ones(1,lw));
if isdelayed,
   idxf = find(~infs);
   hTd = delayfr(Td,w(idxf));
   h(:,:,idxf) = hTd .* h(:,:,idxf);
end

% Response at s=Inf
if any(infs)
   hinf = evalfr(sys,Inf);
   h(:,:,infs) = hinf(:,:,ones(1,sum(infs)));
end

