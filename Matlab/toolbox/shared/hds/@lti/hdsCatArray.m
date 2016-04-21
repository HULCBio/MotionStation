function sys = hdsCatArray(dim,varargin)
%HDSCATARRAY  Horizontal or vertical array concatenation.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:46 $
sys = stack(dim,varargin{:});