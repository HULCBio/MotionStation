function mhelp(topic)
%MHELP  Maple help.
%   MHELP topic prints Maple's help text for the topic.
%   MHELP('topic') does the same thing.
%
%   MHELP is not available with MATLAB Student Version.
%
%   Example: 
%      mhelp gcd 

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/15 03:13:03 $

if nargin < 1
   help mhelp
else
   disp(' ')
   maplemex(topic,1);
   disp(' ')
end
