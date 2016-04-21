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
%   Revised: P.Gahinet 5-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:59:56 $

no = nargout;
if nargin~=1,
   error('ZERO takes only one input when the first input is an LTI system.')
end

% Get data 
sizes = size(sys.d);
nd = length(sizes);
if no>1 & any(sizes(1:2)>1),
   error('Second output GAIN only defined for SISO systems.')
end

% Create output
if nd==2,
   % Single model
   [a,b,c,d] = ssdata(sys);
   [z,gain] = getzeros(a,b,c,d,[]);
else
   % SS array: preallocate Z
   Nx = size(sys,'order');
   Na = max(Nx(:));
   Nzmax = 0;
   z = zeros([Na 1 sizes(3:end)]);
   gain = zeros([1 1 sizes(3:end)]);
   
   % Compute zeros
   for k=1:prod(sizes(3:end)),
      [a,b,c,d] = ssdata(subsref(sys,substruct('()',{':' ':' k})));
      [zk,gk] = getzeros(a,b,c,d,[]);
      nz = length(zk);
      Nzmax = max(Nzmax,nz);
      z(1:nz,1,k) = zk;
      z(nz+1:Na,1,k) = NaN;
      if no>1,
         gain(1,1,k) = gk;
      end
   end
   
   % Delete extra Inf values
   colons = repmat({':'},[1,nd+1]);
   z(Nzmax+1:Na,colons{:}) = [];
end


