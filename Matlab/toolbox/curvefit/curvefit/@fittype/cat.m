function c = cat(varargin)
%CAT    N-D concatenation of FITTYPE objects (disallowed)

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:41:23 $

error('curvefit:fittype:cat:catNotPermitted', ...
      'Concatenation of %s objects not permitted.\n', class(varargin{1}))
