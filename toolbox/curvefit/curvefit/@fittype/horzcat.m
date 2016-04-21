function c = horzcat(varargin)
%HORZCAT Horizontal concatenation of FITTYPE objects (disallowed)

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:41:40 $

error('curvefit:fittype:horzcat:catNotPermitted', ...
      'Concatenation of %s objects not permitted.\n',class(varargin{1}));
