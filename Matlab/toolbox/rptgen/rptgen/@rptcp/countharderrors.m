function numErr=countharderrors(p,incrementIn)
%COUNTHARDERRORS tracks number of hard errors while running components
%   NUMERR=COUNTHARDERRORS(RPTCP,INCREMENT) where INCREMENT is a number
%       greater than or equal to zero will add increment to the number of
%       errors already recorded.
%
%   COUNTHARDERRORS(RPTCP,-1) will reset the hard error counter.
%
%   A hard error happens during RPTCP/RUNCOMPONENT if execute(c)
%   fails on the try/catch.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:29 $

persistent RPTGEN_GENERATION_HARD_ERROR_COUNTER

if nargin<2
   incrementIn=0;
end


if incrementIn<0
   RPTGEN_GENERATION_HARD_ERROR_COUNTER=0;
else
   if isempty(RPTGEN_GENERATION_HARD_ERROR_COUNTER)
      RPTGEN_GENERATION_HARD_ERROR_COUNTER=0;
   end
   
   RPTGEN_GENERATION_HARD_ERROR_COUNTER=...
      RPTGEN_GENERATION_HARD_ERROR_COUNTER+incrementIn;
end

numErr=RPTGEN_GENERATION_HARD_ERROR_COUNTER;