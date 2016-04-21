function [z,gain] = zero(sys)
%ZERO  Transmission zeros of LTI systems.
% 
%   Z = ZERO(SYS) returns the transmission zeros of the LTI 
%   model SYS.
%
%   [Z,GAIN] = ZERO(SYS) also returns the transfer function gain
%   (in the zero-pole-gain sense) for SISO models SYS.
%   
%   If SYS is an array of LTI models with sizes [NY NU S1 ... Sp],
%   Z and K are arrays with as many dimensions as SYS such that 
%   Z(:,1,j1,...,jp) and K(1,1,j1,...,jp) give the zeros and gain 
%   of the LTI model SYS(:,:,j1,...,jp).  The vectors of zeros are 
%   padded with NaN values for models with relatively fewer zeros.
%
%   See also POLE, PZMAP, ZPK, LTIMODELS.

%   Clay M. Thompson  7-23-90, 
%   Revised:  P.Gahinet 5-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 06:06:32 $

no = nargout;
if nargin~=1,
   error('ZERO takes only one input when the first input is an LTI model.')
end

% Get dimensions
sizes = size(sys.num);
nd = length(sizes);
if no>1 & any(sizes(1:2)>1),
   error('Second output GAIN only defined for SISO systems.')
end

if all(sizes(1:2)<=1),
   % SISO case. First determine the max number of zeros
   num = sys.num;
   nsys = prod(sizes);
   nzmax = 0;
   for k=1:nsys,
      numk = num{k};
      inz = find(numk);
      nzmax = max([nzmax length(numk)-inz(1:min(1,end))]);
   end
   
   % Dimension Z and G
   z = zeros([nzmax 1 sizes(3:end)]);   
   gain = zeros([1 1 sizes(3:end)]);
   
   % Compute zeros
   NanZero = NaN;
   for k=1:nsys,
      numk = num{k};
      zk = roots(numk);
      % RE: pad missing zeros with NaN
      z(:,1,k) = [zk ; NanZero(ones(nzmax-length(zk),1),1)];
      if no>1,
         % Compute the gain
         denk = sys.den{k};
         idx = find(denk);
         denk1 = denk(idx(1));
         numk1 = numk(end-length(zk));
         gain(k) = numk1/denk1;
      end
   end
   
else
   % MIMO case: convert to SS to compute transmission zeros
   if ~isproper(sys),
      error('Not supported for MIMO improper transfer functions.')
   end
   z = zero(ss(sys));

end

