function c = vertcat(varargin)
%VERTCAT Vertical concatenation of inline objects (disallowed)

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:21:14 $

error('Inline functions can''t be concatenated.');
