function varargout = ndgrid(varargin)
%NDGRID Generation of arrays for N-D functions and interpolation.
%   [X1,X2,X3,...] = NDGRID(x1,x2,x3,...) transforms the domain
%   specified by vectors x1,x2,x3, etc. into arrays X1,X2,X3, etc. that
%   can be used for the evaluation of functions of N variables and N-D
%   interpolation.  The i-th dimension of the output array Xi are copies
%   of elements of the vector xi.
%
%   [X1,X2,...] = NDGRID(x) is the same as [X1,X2,...] = NDGRID(x,x,...).
%
%   For example, to evaluate the function  x2*exp(-x1^2-x2^2-x^3) over the
%   range  -2 < x1 < 2,  -2 < x2 < 2, -2 < x3 < 2,
%
%       [x1,x2,x3] = ndgrid(-2:.2:2, -2:.25:2, -2:.16:2);
%       z = x2 .* exp(-x1.^2 - x2.^2 - x3.^2);
%       slice(x2,x1,x3,z,[-1.2 .8 2],2,[-2 -.2])
%
%   NDGRID is like MESHGRID except that the order of the first two input
%   arguments are switched (i.e., [X1,X2,X3] = NDGRID(x1,x2,x3) produces
%   the same result as [X2,X1,X3] = MESHGRID(x2,x1,x3)).  Because of
%   this, NDGRID is better suited to N-D problems that aren't spatially
%   based, while MESHGRID is better suited to problems in cartesian
%   space (2-D or 3-D).
%
%   See also MESHGRID, INTERPN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2003/05/01 20:41:49 $

if nargin==0 
  error('MATLAB:ndgrid:NotEnoughInputs', 'Not enough input arguments.'); 
end
if nargin==1, varargin = repmat(varargin,[1 max(nargout,2)]); end
nin = length(varargin);
nout = max(nargout,nin);

for i=length(varargin):-1:1,
  varargin{i} = full(varargin{i}); % Make sure everything is full
  siz(i) = numel(varargin{i});
end
if length(siz)<nout, siz = [siz ones(1,nout-length(siz))]; end

varargout = cell(1,nout);
for i=1:nout,
  x = varargin{i}(:); % Extract and reshape as a vector.
  s = siz; s(i) = []; % Remove i-th dimension
  x = reshape(x(:,ones(1,prod(s))),[length(x) s]); % Expand x
  varargout{i} = permute(x,[2:i 1 i+1:nout]); % Permute to i'th dimension
end

