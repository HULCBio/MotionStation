function Sys = series(Sys1,Sys2,outputs1,inputs2)
%SERIES  Series interconnection of the two LTI models.
%
%                                  +------+
%                           v2 --->|      |
%                  +------+        | SYS2 |-----> y2
%                  |      |------->|      |
%         u1 ----->|      |y1   u2 +------+
%                  | SYS1 |
%                  |      |---> z1
%                  +------+
%
%   SYS = SERIES(SYS1,SYS2,OUTPUTS1,INPUTS2) connects two LTI models 
%   SYS1 and SYS2 in series such that the outputs of SYS1 specified by
%   OUTPUTS1 are connected to the inputs of SYS2 specified by INPUTS2.  
%   The vectors OUTPUTS1 and INPUTS2 contain indices into the outputs 
%   and inputs of SYS1 and SYS2, respectively.  The resulting LTI model 
%   SYS maps u1 to y2.
%
%   If OUTPUTS1 and INPUTS2 are omitted, SERIES connects SYS1 and SYS2
%   in cascade and returns
%                     SYS = SYS2 * SYS1 .
%
%   If SYS1 and SYS2 are arrays of LTI models, SERIES returns an LTI
%   array SYS of the same size where 
%      SYS(:,:,k) = SERIES(SYS1(:,:,k),SYS2(:,:,k),OUTPUTS1,INPUTS2) .
%
%   See also APPEND, PARALLEL, FEEDBACK, LTIMODELS.

%	Clay M. Thompson 6-29-90, Pascal Gahinet, 4-12-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.11 $  $Date: 2002/04/10 05:48:25 $


ni = nargin;
if ni==2,
   Sys = Sys2 * Sys1;
   return
elseif ni~=4,
   error('Wrong number of arguments (must be 2 or 4).');
end

% Error checking
sizes1 = size(Sys1);
sizes2 = size(Sys2);
lo = length(outputs1);
li = length(inputs2);
if ~isequal(sizes1(3:end),sizes2(3:end)) & length(sizes1)>2 & length(sizes2)>2,
   error('LTI arrays SYS1 and SYS2 must have compatible dimensions.')
elseif li~=lo,
   error('Vectors OUTPUTS1 and INPUTS2 must have matching lengths.')
elseif li>sizes2(2),
   error('Length of INPUTS2 exceeds number of inputs in SYS2.');
elseif lo>sizes1(1),
   error('Length of OUTPUTS1 exceeds number of outputs in SYS1.');
elseif min(inputs2)<=0 | max(inputs2)>sizes2(2),
   error('Index out of range in INPUTS2.')
elseif min(outputs1)<=0 | max(outputs1)>sizes1(1),
   error('Index out of range in OUTPUTS1.')
end

% Build series interconnection
Sys = Sys2(:,inputs2) * Sys1(outputs1,:);

