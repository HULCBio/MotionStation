function c = vertcat(varargin)
%VERTCAT Vertical concatenation of FITTYPE objects (disallowed)

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:43:02 $

error('curvefit:fittype:vertcat:catNotAllowed', ....
      'Concatenation of %s objects not permitted.\n',class(varargin{1}));