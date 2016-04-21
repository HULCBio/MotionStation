function t = toc
%TOC Read the stopwatch timer.
%   TOC, by itself, prints the elapsed time (in seconds) since TIC was used.
%   t = TOC; saves the elapsed time in t, instead of printing it out.
%
%   See also TIC, ETIME, CLOCK, CPUTIME.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/04/10 23:33:08 $

% Note that toc is implemented as a builtin function for efficiency. Any changes
% to this file will not change the behavior of toc. This file is provided as
% an example of how to use the 'global' keyword only.

% TOC uses ETIME and the value of CLOCK saved by TIC.
global TICTOC
if isempty(TICTOC)
  error('MATLAB:toc:callTicFirst', 'You must call TIC before calling TOC.');
end
if nargout < 1
   disp(sprintf('Elapsed time is %f seconds.', etime(clock,TICTOC)));
else
   t = etime(clock,TICTOC);
end
