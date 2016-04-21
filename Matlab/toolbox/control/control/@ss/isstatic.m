function boo = isstatic(sys)
%ISSTATIC  True for static gains
%
%   ISSTATIC(SYS) returns 1 (true) if the LTI model SYS is a 
%   static gain, and 0 (false) otherwise.
%
%   For LTI arrays, ISSTATIC(SYS) is true if all models in the
%   array are static gains.
%
%   See also POLE, ZERO.

%      Author: P. Gahinet, 5-23-97
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.10.4.1 $  $Date: 2003/01/07 19:32:39 $

% SYS is a static gain if it has dynamics and 
% no time delays
EmptyA = cellfun('isempty',sys.a);
if all(EmptyA(:)) & isstatic(sys.lti),
   boo = true;
else
   boo = false;
end

