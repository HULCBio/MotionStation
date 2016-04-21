function sys = ndcheck(sys,ndchange)
%NDCHECK  Checks the validity and consistency of numerator and 
%         denominator values NUM and DEN.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/05/11 17:33:17 $

if ~ndchange,
   return
end

% Make sure both NUM and DEN are cell arrays
if isa(sys.num,'double'), 
   % TF([1 0],[2 0]):  NUM should be a row vector
   if ndims(sys.num)>2,
      error('Numerator data must be a row vector (siso) or a cell array of row vectors (mimo).')
   end
   sys.num = {sys.num};
end
if isa(sys.den,'double'), 
   % TF(NUM,[1 0]) (common denominator)
   den0 = sys.den;
   if ndims(den0)>2,
      error('Denominator data must be a row vector (siso) or a cell array of row vectors (mimo).')
   end
   sys.den = cell(size(sys.num));
   sys.den(:) = {den0};
end

% Get sizes
snum = size(sys.num);  ndnum = length(snum);
sden = size(sys.den);  ndden = length(sden);
Resizable = [(ndnum==2 & ndden>2)  (ndden==2 & ndnum>2)];

% Check dimension consistency
if ~isequal(snum(1:2),sden(1:2)) | ...
      (~any(Resizable) & ~isequal(snum(3:end),sden(3:end))),
   errmsg = 'Numerator and denominator cell arrays must have matching dimensions.';
   if ndchange<2,  % only NUM or DEN modified
      errmsg = sprintf('%s\n%s',errmsg, ...
         'Use SET(SYS,''num'',NUM,''den'',DEN) to modify input/output dimensions');
   end
   error(errmsg)
elseif Resizable(1),
   % NUM is 2D and DEN is ND: replicate NUM
   sys.num = repmat(sys.num,[1 1 sden(3:end)]);
elseif Resizable(2)
   % DEN is 2D and NUM is ND: replicate NUM
   sys.den = repmat(sys.den,[1 1 snum(3:end)]);
end

% Deal with NaN models (used when hitting singularity like algebraic loop)
[ny,nu,nsys] = size(sys.num);
for ct=1:nsys
   if ~all(isfinite(cat(2,sys.num{:,:,ct}))) || ~all(isfinite(cat(2,sys.den{:,:,ct})))
      sys.num(:,:,ct) = {NaN};  
      sys.den(:,:,ct) = {1};
   end
end

% Check that all elements of NUM and DEN are row vectors
for ct=1:ny*nu*nsys
   num = sys.num{ct};
   den = sys.den{ct};
   if ~isa(num,'double') | ~isa(den,'double')
      error('Numerator and denominator data must be of class DOUBLE.')
   elseif ndims(num)>2 | ndims(den)>2 | isempty(num) | isempty(den) | ...
         size(num,1)~=1 | size(den,1)~=1
      error('Each numerator and denominator must be specified as a non-empty row vector.')
   elseif ~any(den),
      error('Denominators must be nonzero vectors.')
   end
end


   