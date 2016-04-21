function varargout = gradient(f,varargin)
%GRADIENT Approximate gradient.
%   [FX,FY] = GRADIENT(F) returns the numerical gradient of the
%   matrix F. FX corresponds to dF/dx, the differences in the
%   x (column) direction. FY corresponds to dF/dy, the differences
%   in the y (row) direction. The spacing between points in each
%   direction is assumed to be one. When F is a vector, DF = GRADIENT(F)
%   is the 1-D gradient.
%
%   [FX,FY] = GRADIENT(F,H), where H is a scalar, uses H as the
%   spacing between points in each direction.
%
%   [FX,FY] = GRADIENT(F,HX,HY), when F is 2-D, uses the spacing
%   specified by HX and HY. HX and HY can either be scalars to specify
%   the spacing between coordinates or vectors to specify the
%   coordinates of the points.  If HX and HY are vectors, their length
%   must match the corresponding dimension of F.
%
%   [FX,FY,FZ] = GRADIENT(F), when F is a 3-D array, returns the
%   numerical gradient of F. FZ corresponds to dF/dz, the differences
%   in the z direction. GRADIENT(F,H), where H is a scalar, 
%   uses H as the spacing between points in each direction.
%
%   [FX,FY,FZ] = GRADIENT(F,HX,HY,HZ) uses the spacing given by
%   HX, HY, HZ. 
%
%   [FX,FY,FZ,...] = GRADIENT(F,...) extends similarly when F is N-D
%   and must be invoked with N outputs and either 2 or N+1 inputs.
%
%   Examples:
%       [x,y] = meshgrid(-2:.2:2, -2:.2:2);
%       z = x .* exp(-x.^2 - y.^2);
%       [px,py] = gradient(z,.2,.2);
%       contour(z),hold on, quiver(px,py), hold off
%
%   Class support for input F:
%      float: double, single
%
%   See also DIFF, DEL2.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.17.4.2 $  $Date: 2004/03/09 16:16:20 $

[msg,f,ndim,loc,cflag] = parse_inputs(f,varargin);
if ~isempty(msg), error('MATLAB:gradient:InvalidInputs', msg); end

% Loop over each dimension. Permute so that the gradient is always taken along
% the columns.

if ndim == 1
  perm = [1 2];
else
  perm = [2:ndim 1]; % Cyclic permutation
end

for k = 1:ndim
   [n,p] = size(f);
   h = loc{k}(:);   
   g  = zeros(size(f),class(f)); % case of singleton dimension

   % Take forward differences on left and right edges
   if n > 1
      g(1,:) = (f(2,:) - f(1,:))/(h(2)-h(1));
      g(n,:) = (f(n,:) - f(n-1,:))/(h(end)-h(end-1));
   end

   % Take centered differences on interior points
   if n > 2
      h = h(3:n) - h(1:n-2);
      g(2:n-1,:) = (f(3:n,:)-f(1:n-2,:))./h(:,ones(p,1));
   end

   varargout{k} = ipermute(g,[k:ndim 1:k-1]);

   % Set up for next pass through the loop
   f = permute(f,perm);
end 

% Swap 1 and 2 since x is the second dimension and y is the first.
if ndim>1
  tmp = varargout{1};
  varargout{1} = varargout{2};
  varargout{2} = tmp;
end

if cflag, varargout{1} = varargout{1}.'; end


%-------------------------------------------------------
function [msg,f,ndim,loc,cflag] = parse_inputs(f,v)
%PARSE_INPUTS
%   [MSG,F,LOC,CFLAG] = PARSE_INPUTS(F,V) returns the spacing
%   LOC along the x,y,z,... directions and a column vector
%   flag CFLAG. MSG will be non-empty if there is an error.

msg = '';
ndim = [];
loc = {};
cflag = [];
nin = length(v)+1;

% Flag vector case and column vector case.
ndim = ndims(f);
vflag = 0; cflag = 0;
if ndims(f) == 2
   if size(f,2) == 1
      ndim = 1; vflag = 1; cflag = 1;
   elseif size(f,1) == 1    % Treat row vector as a column vector
      ndim = 1; vflag = 1; cflag = 0;
      f = f.';
   end;
end;
   
indx = size(f);

% Default step sizes: hx = hy = hz = 1
if nin == 1, % gradient(f)
   for k = 1:ndims(f)
      loc(k) = {1:indx(k)};
   end;

elseif (nin == 2) % gradient(f,h)
   % Expand scalar step size
   if (length(v{1})==1)
      for k = 1:ndims(f)
         h = v{1};
         loc(k) = {h*(1:indx(k))};
      end;
   % Check for vector case
   elseif vflag
      loc(1) = v(1);
   else
      msg = 'Invalid inputs to GRADIENT.';
   end

elseif ndims(f) == numel(v), % gradient(f,hx,hy,hz,...)
   % Swap 1 and 2 since x is the second dimension and y is the first.
   loc = v;
   if ndim>1
     tmp = loc{1};
     loc{1} = loc{2};
     loc{2} = tmp;
   end

   % replace any scalar step-size with corresponding position vector
   for k = 1:ndims(f)
      if length(loc{k})==1
         loc{k} = loc{k}*(1:indx(k));
      end;
   end;

else
   msg = 'Invalid inputs to GRADIENT.';

end
