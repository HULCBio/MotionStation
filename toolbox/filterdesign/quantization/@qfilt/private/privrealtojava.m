function varargout=privrealtojava(varargin)
%PRIVREALTOJAVA  Create a Java real array.
%   [Y1,Y2,...] = PRIVREALTOJAVA(X1,X2,...) creates Java 2-Dimensional
%   real arrays Y1,Y2,... from MATLAB 2-dimensional arrays
%   X1,X2,... respectively. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/14 15:29:04 $

for k=1:nargin
  if ~isnumeric(varargin{k}) | ~isreal(varargin{k}) | ndims(varargin{k}) > 2
    error('Input must be real 2-dimensional array.')
  end
  if isempty(varargin{k})
    % Empty matrices can still have a non-zero dimension
    [m,n] = size(varargin{k});
    varargout{k} = javaObject('com.mathworks.toolbox.filterdesign.Real',...
        0,m,n); % empty
  else % nonempty
    varargout{k} = ...
        javaObject('com.mathworks.toolbox.filterdesign.Real',...
        varargin{k}(:),size(varargin{k}));
  end
end
