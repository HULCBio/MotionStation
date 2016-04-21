function g=freqresp(a,b,c,d,iu,s)
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

% Old help 
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%FREQRESP Low level frequency response function.
%   G=FREQRESP(A,B,C,D,IU,S)
%   G=FREQRESP(NUM,DEN,S)
%   G=FREQRESP(Z,P,K,S)

%   Clay M. Thompson 7-10-90
%       Revised: AFP 9-10-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 06:23:59 $

% For P-output, M-input systems, g=freqresp(a,b,c,d,1:m,s)
% returns an NS by M*P matrix.  Each row of this matrix 
% contains [H11 H21 ... Hp1 H12 H22 ... Hp2 ... Hpm]
% where Hij is the frequenct response from the j-th input
% to the i-th output.
% This format WILL change in future versions.  The right thing
% to output is a PxMxNS 3-D matrix.

ni = nargin;
if ni==3,
   % It is in transfer function form.   Do directly, using Horner's method
   % of polynomial evaluation at the frequency points, for each row in
   % the numerator.   Then divide by the denominator.
   [ny,nx] = size(a);
   s = c(:);
   % Initialize g for minor performance improvement
   g = zeros(length(s),ny);
   for i=1:ny
      g(:,i) = polyval(a(i,:),s);
   end
   g = polyval(b,s)*ones(1,ny).\g;
elseif ni==4,
   % ZPK form
   s = d(:);
   z = a(:);
   p = b(:);
   k = c(:);
   nu = length(k);
   nx = length(p);
   % Pad Z if necessary so it has the same number of rows as p (i.e. #zeros==#poles)
   INF = Inf;
   z = [z; INF(ones(nx-size(z,1),nu))];;
   nw = size(s,1);

   % Initialize g to be the gain
   onesNW = ones(1,nw);
   g = (k(:,onesNW)).';

   % Assume it's faster to loop over poles as opposed to frequency points
   s = s(:,ones(1,nu));
   for i=1:nx,
      tmp = s - z(i(onesNW,:),:);
      ind = isinf(tmp);
      tmp(ind) = ones(sum(sum(ind)),1);
      g = g.*tmp./(s - p(i));
   end

else
   % Reduce state space A matrix to Hessenberg form
   % Then directly evaluate frequency response.
   [ny,nu] = size(d);
   nx = size(a,1);
   s = s(:);
   nw = size(s,1);

   % Balance A
   [t,a] = balance(a);
   b = t \ b;
   c = c * t;
   
   % Reduce A to Hessenburg form
   [p,a] = hess(a);

   % Apply similarity transformations from Hessenberg reduction to B and C:
   if nx>0,
      b = p' * b;
      c = c * p;
      g = [];
      for i=iu,
         G = ltifr(a,b(:,i),s);
         g = [g (c*G + d(:,i(1,ones(1,nw)))).'];
      end
   else
      D = d(:,iu);
      D = D(:).';
      g = D(ones(1,nw),:);
   end
end

% end freqresp
