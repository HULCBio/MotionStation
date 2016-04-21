function static = isstatic(sys)
%ISSTATIC  True for static gains
%
%   ISSTATIC(SYS) returns 1 (true) if the LTI model SYS is a 
%   static gain, and 0 (false) otherwise.
%
%   For LTI arrays, ISSTATIC(SYS) is true if all models in the
%   array are static gains.
%
%   See also POLE, ZERO.

%      Author: S. Almy
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.8 $  $Date: 2002/04/14 22:34:03 $


% A static gain must be delay free
static = isstatic(sys.lti);

% static gain must have constant real response
% Test for real value in first ResponseData element,
% then check that all are equal ( consequently, real too )
if static
  difference = diff(sys.ResponseData,1,3);
  static = ~any(difference(:));
end
