function nyqplot(varargin)
%NYQPLOT Plots a Nyquist diagram of a frequency function.
%   OBSOLETE function. Use NYQUIST instead. See HELP IDMODEL/NYQUIST.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:43 $

if nargout == 0
   nyqaux(varargin{:});
elseif nargout <= 2
   [fr,w] = nyqaux(varargin{:});
else
   [fr,w,covfr] = nyqaux(varargin{:});
end
 