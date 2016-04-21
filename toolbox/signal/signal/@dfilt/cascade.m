function h = cascade(varargin)
%CASCADE Create a cascade of discrete-time filters.
%   Hd = CASCADE(Hd1, Hd2, etc) creates a cascade of the filter objects
%   Hd1, Hd2, etc.  The block diagram of this cascade looks like:
%
%      x ---> Hd1 ---> Hd2 ---> etc. ---> y
%
%   See also DFILT. 

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/12 23:59:51 $

h = dfilt.cascade(varargin{:});

% [EOF]
