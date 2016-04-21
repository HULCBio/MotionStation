## Copyright (C) 2008 Alexander Barth <barth.alexander@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Loadable Function} {[@var{fi},@var{vari}] = } optiminterpn(@var{x},@var{y},@dots{},@var{f},@var{var},@var{lenx},@var{leny},@dots{},@var{m},@var{xi},@var{yi},@dots{})
## Performs a local nD-optimal interpolation (objective analysis).
##
## Every elements in @var{f} corresponds to a data point (observation)
## at location @var{x},@var{y},@dots{} with the error variance @var{var}.
##
## @var{lenx},@var{leny},@dots{} are correlation length in x-direction
## y-direction,... respectively. 
## @var{m} represents the number of influential points.
##
## @var{xi},@var{yi},@dots{} are the data points where the field is
## interpolated. @var{fi} is the interpolated field and @var{vari} is 
## its error variance.
##
## The background field of the optimal interpolation is zero.
## For a different background field, the background field
## must be subtracted from the observation, the difference 
## is mapped by OI onto the background grid and finally the
## background is added back to the interpolated field.
## The error variance of the background field is assumed to 
## have a error variance of one.
## @end deftypefn

function [fi,vari] = optiminterpn(varargin)

if nargin < 6 || mod(nargin-3,3) ~= 0
  error('optiminterpn: wrong number of arguments');
end

n = (nargin-3)/3;

x =  varargin{1};
xi = varargin{2*n+4};
on = numel(varargin{1});
gsz = size(varargin{2*n+4});

for i=1:n
  tmp = varargin{i};

  if on ~= numel(tmp)
    error('optiminterpn: x, y,... must have the same number of elements');
  end

  ox(:,i) = tmp(:); 

  len(i) = varargin{n+i+2};
  tmp = varargin{2*n+3+i};

  if (numel(tmp) ~= prod(gsz))
    error('optiminterpn: xi, yi, ... must have the same number of elements');
  end

  gx(:,i) = tmp(:);
end

f = varargin{n+1};    
var = varargin{n+2};    

m = varargin{2*n+3};    

if (isscalar(var))
  var = var*ones(size(x));
end

if isvector(f) && size(f,1) == 1
   f = f';
end

% is this correct?
nf = size(f,n+1);

if (on*nf ~= numel(f) && on ~= numel(var))
  error('optiminterpn: x,y,...,var must have the same number of elements');
end

f=reshape(f,[on nf]);

%whos ox f var len m gx
[fi,vari] = optiminterp(ox,f,var,len,m,gx);

fi = reshape(fi,[gsz nf]);
vari = reshape(vari,gsz);
