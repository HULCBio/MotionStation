function varargout=javatodouble(varargin)
%JAVATODOUBLE Java real or complex matrix to MATLAB double.
%   [Y1,Y2,...] = JAVATODOUBLE(X1,X2,...) creates MATLAB 2-Dimensional
%   real or complex arrays Y1,Y2,... from MATLAB 2-dimensional real or
%   complex arrays X1,X2,... respectively. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:25:38 $

for k=1:nargin
  re = real(varargin{k});
  m = double(rows(varargin{k}));
  n = double(columns(varargin{k}));
  if isreal(varargin{k})
    varargout{k} = reshape(re,m,n);
  else
    im = imag(varargin{k});
    varargout{k} = reshape(complex(re,im),m,n);
  end
end

    
  
