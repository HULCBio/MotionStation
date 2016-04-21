function sys = zpkcheck(sys,zpkflag)
%ZPKCHK   Verifies the consistency of arguments Z,P,K and makes sure
%         Z and P are cellarray of column vectors.
%
%         Returns the empty string if no error is detected.

%      Author: P. Gahinet, 5-1-96
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.15 $  $Date: 2002/05/11 17:33:06 $

if ~zpkflag,
   return
end

% Make sure both Z and P are cell arrays
formatmsg = 'Zero and pole data must be specified as vectors (SISO) or cell arrays of vectors (MIMO).';
if isa(sys.z,'double'), 
   % ZPK([1 2],[3 4],1)
   if ndims(sys.z)>2,
      error(formatmsg)
   end
   sys.z = {sys.z}; 
end
if isa(sys.p,'double'), 
   if ndims(sys.p)>2,
      error(formatmsg)
   end
   sys.p = {sys.p}; 
elseif ~isa(sys.k,'double')
   error('Gain data must be a numeric array.')
end

% Get sizes
nd = zeros(1,3);
sz = size(sys.z);  nd(1) = length(sz);
sp = size(sys.p);  nd(2) = length(sp);
sk = size(sys.k);  nd(3) = length(sk);

% Check I/O dimension consistency
if ~isequal(sz(1:2),sp(1:2),sk(1:2)),
   errmsg = 'Invalid system: Z,P,K must have matching dimensions.'; 
   if zpkflag<3,  % two or less modified
      errmsg = sprintf('%s\n%s',errmsg, ...
         'Use SET(SYS,''Z'',z,''P'',p,''K'',k) to modify input/output dimensions');
   end
   error(errmsg)    
end


% Check compatibility of dimensions > 2
[ndmax,imax] = max(nd);  % highest dimensionality
if ndmax>2,
   % ARRAYSIZES(:,j) = size of dimension j+2 for Z,P,K
   ArraySizes = [sz(3:end) ones(1,ndmax-nd(1)) ; ...
         sp(3:end) ones(1,ndmax-nd(2)) ; ...
         sk(3:end) ones(1,ndmax-nd(3))];
   FullSizes = ArraySizes(imax,:);         
   % Which matrices can be resized by REPMAT extension along dims>2      
   Resizable = (nd==2);
   
   % Consistency check
   nrs = length(find(~Resizable));
   if any(ArraySizes(~Resizable,:)~=FullSizes(ones(nrs,1),:),2),
      error('Z,P,K arrays must have compatible dimensions.')
   end
   
   % Resize the resizable
   if Resizable(1),  sys.z = repmat(sys.z,[1 1 FullSizes]);  end
   if Resizable(2),  sys.p = repmat(sys.p,[1 1 FullSizes]);  end
   if Resizable(3),  sys.k = repmat(sys.k,[1 1 FullSizes]);  end
end

% Deal with NaN models (used when hitting singularity like algebraic loop)
[ny,nu,nsys] = size(sys.k);
for ct=1:nsys
   if ~all(isfinite(sys.k(:,:,ct)))
      sys.k(:,:,ct) = NaN;
      sys.z(:,:,ct) = {zeros(0,1)};  
      sys.p(:,:,ct) = {zeros(0,1)};
   end
end

% Make Z and P cell arrays of column vectors
for ct=1:ny*nu*nsys
   z = sys.z{ct};
   p = sys.p{ct};
   if ~isa(z,'double') | ~isa(p,'double') 
      error('Zero and pole data must be real or complex valued.')
   elseif ~all(isfinite(z(:))) | ~all(isfinite(p(:)))
      error('Zero and pole data must be free of Inf''s or NaN''s.')
   elseif ndims(z)>2 | ndims(p)>2 | min(size(z))>1 | min(size(p))>1
      error(formatmsg)
   end
   sys.z{ct} = z(:);
   sys.p{ct} = p(:);
end
