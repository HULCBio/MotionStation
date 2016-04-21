function h = statespace(varargin)
%STATESPACE Construct a State-space filter object
%   Hd = DFILT.STATESPACE(A, B, C, D) constructs a State-space discrete-time
%   filter object with A, B, C and D.  If A, B, C or D are not specified,
%   they default to [], [], [] and 1.
%
%   See also DFILT.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:00:16 $

h = dfilt.statespace(varargin{:});

% [EOF]
