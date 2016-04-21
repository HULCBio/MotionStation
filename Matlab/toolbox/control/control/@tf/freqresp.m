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

%	Clay M. Thompson 7-10-90
%       Revised: AFP 9-10-95, P.Gahinet 5-2-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.25 $  $Date: 2002/04/10 06:07:56 $

error(nargchk(2,2,nargin));
if ~isa(w,'double') | ndims(w)>2 | min(size(w))>1,
   error('W must be a vector of real frequencies.')
end
w = w(:);
lw = length(w);

% Extract data 
[num,den,Ts] = tfdata(sys);
sizes = size(num);

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
infs = isinf(s.');  % s = Inf
idxf = find(~infs);

% Compute frequency response
h = zeros([lw , sizes]); % More convenient for loop below

SingularWarn = '';
lwarn = lastwarn;warn = warning('off');

for k=1:prod(sizes),
   denval = polyval(den{k},s(idxf));
   if any(denval==0),
      SingularWarn = 'Singularity in frequency response due to jw-axis or unit-circle poles.';
   end
   h(idxf,k) = polyval(num{k},s(idxf)) ./ denval;
end
   
warning(warn);lastwarn(lwarn);
warning(SingularWarn)

% Reorder dimensions
h = permute(h,[2 3 1 4:length(sizes)+1]);

% Add delay contribution 
if isdelayed, 
   hTd = delayfr(Td,w(idxf)); 
   h(:,:,idxf,:) = hTd(:,:,:,:) .* h(:,:,idxf,:); 
end

% Response at s=Inf
if any(infs)
   hinf = evalfr(sys,Inf);
   hinf = reshape(hinf,[sizes(1:2) 1 prod(sizes(3:end))]);
   h(:,:,infs,:) = hinf(:,:,ones(1,sum(infs)),:);
end