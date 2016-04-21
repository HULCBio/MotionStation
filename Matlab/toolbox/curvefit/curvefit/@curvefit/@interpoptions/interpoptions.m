function h = interpoptions(varargin)
% INTERPOPTIONS Constructor for interpoptions object.
% h = interpoptions(methodname)

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:40:56 $

h = curvefit.interpoptions;

if nargin > 0
  if mod(nargin,2) == 1 
    h.Method = varargin{1};
    varargin(1) = [];
  end
end
