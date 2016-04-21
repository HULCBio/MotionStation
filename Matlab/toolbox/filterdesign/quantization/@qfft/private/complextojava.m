function varargout=complextojava(varargin)
%COMPLEXTOJAVA  Create a Java complex array.
%   [Y1,Y2,...] = COMPLEXTOJAVA(X1,X2,...) creates Java 2-Dimensional
%   complex arrays Y1,Y2,... from MATLAB 2-dimensional arrays
%   X1,X2,... respectively. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/14 15:25:35 $


for k=1:nargin
  if ~isnumeric(varargin{k}) | ndims(varargin{k}) > 2
    error('Input must be numeric 2-dimensional array')
  end
  if isempty(varargin{k})
    varargout{k} = javaObject('com.mathworks.toolbox.filterdesign.Complex',...
        0,0,0,0); % empty
  else % nonempty
    varargout{k} = ...
        javaObject('com.mathworks.toolbox.filterdesign.Complex',...
        real(varargin{k}(:)),imag(varargin{k}(:)),size(varargin{k}));
  end
end
