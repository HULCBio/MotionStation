function h = freqresp(sys,w,npts,PlotType)
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

%   Clay M. Thompson 7-10-90
%   Revised: AFP 9-10-95, PG 5-2-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.30.4.1 $  $Date: 2002/11/11 22:22:17 $

error(nargchk(2,2,nargin));
if ~isa(w,'double') | ndims(w)>2 | min(size(w))>1,
   error('W must be a vector of real frequencies.')
end
lw = length(w);
w = reshape(w,1,lw);

% Extract data
[Zeros,Poles,Gains,Ts] = zpkdata(sys);
Ts = abs(Ts);
sizes = size(Gains);
RealFlag = isreal(sys);

% Quick exit if empty system or empty w 
if lw==0 | any(sizes==0),
   h = zeros([sizes(1:2) , lw , sizes(3:end)]);
   return
end

% Get delay
Td = totaldelay(sys); 
isdelayed = any(Td(:));
if isdelayed
   Td = repmat(Td,[1 1 sizes(1+ndims(Td):end)]);
end

% Form vector s of complex frequencies
if Ts==0,
   % Watch for case where W contains complex frequencies (old syntax)
   if isreal(w),
      w = 1i*w;
   end
   s = w;
elseif isreal(w),
   % Discrete with real freqs
   w = (1i*abs(Ts)) * w;
   s = exp(w);  % z = exp(j*w*Ts)
else
   % Discrete with complex frequencies (old syntax)
   s = w;
   w = log(s);
end

% Compute frequency response
h = zeros([lw , sizes]); % More convenient for loop below
SingularWarn = '';
for m=1:prod(sizes)
   % Zeros and Poles for SYS(m)
   % Sort by ascending magnitude to minimize risk of overflow
   zm = Zeros{m};
   [junk,isz] = sort(abs(zm));
   pm = Poles{m};
   [junk,isp] = sort(abs(pm));
   % Evaluate response at each frequency
   % RE: Ensures no underflow or overflow in intermediate results
   [h(:,m),InfResp] = zpkfresp(zm(isz),pm(isp),Gains(m),s,RealFlag);
   if InfResp
      SingularWarn = 'Singularity in frequency response due to jw-axis or unit-circle poles.';
   end
end
warning(SingularWarn)

% Reorder dimensions
h = permute(h,[2 3 1 4:length(sizes)+1]);

% Finally add delay contribution
if isdelayed,
   infs = isinf(s);
   idxf = find(~infs);
   hTd = delayfr(Td,w(idxf)); 
   h(:,:,idxf,:) = hTd(:,:,:,:) .* h(:,:,idxf,:); 
   % Recompute the response at infinity as delays introduce
   % unknown phase for finite response at s=inf 
   if any(infs)
      hinf = evalfr(sys,Inf);
      hinf = reshape(hinf,[sizes(1:2) 1 prod(sizes(3:end))]);    
      h(:,:,infs,:) = hinf(:,:,ones(1,sum(infs)),:);
   end
end