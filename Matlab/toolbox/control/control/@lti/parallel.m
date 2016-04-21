function Sys = parallel(Sys1,Sys2,inp1,inp2,out1,out2)
%PARALLEL  Parallel interconnection of two LTI models.
%
%                          +------+
%            v1 ---------->|      |----------> z1
%                          | SYS1 |
%                   u1 +-->|      |---+ y1
%                      |   +------+   |
%             u ------>+              O------> y
%                      |   +------+   |
%                   u2 +-->|      |---+ y2
%                          | SYS2 |
%            v2 ---------->|      |----------> z2
%                          +------+
%
%   SYS = PARALLEL(SYS1,SYS2,IN1,IN2,OUT1,OUT2) connects the two 
%   LTI models SYS1 and SYS2 in parallel such that the inputs 
%   specified by IN1 and IN2 are connected and the outputs specified
%   by OUT1 and OUT2 are summed.  The resulting LTI model SYS maps 
%   [v1;u;v2] to [z1;y;z2].  The vectors IN1 and IN2 contain indexes 
%   into the input vectors of SYS1 and SYS2, respectively, and define 
%   the input channels u1 and u2 in the diagram.  Similarly, the 
%   vectors OUT1 and OUT2 contain indexes into the outputs of these 
%   two systems. 
%
%   If IN1,IN2,OUT1,OUT2 are jointly omitted, PARALLEL forms the 
%   standard parallel interconnection of SYS1 and SYS2 and returns
%          SYS = SYS2 + SYS1 .
%
%   If SYS1 and SYS2 are arrays of LTI models, PARALLEL returns an LTI
%   array SYS of the same size where 
%      SYS(:,:,k) = PARALLEL(SYS1(:,:,k),SYS2(:,:,k),IN1,...) .
%
%   See also APPEND, SERIES, FEEDBACK, LTIMODELS.

%	Clay M. Thompson 6-27-90, Pascal Gahinet, 4-15-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.12 $  $Date: 2002/04/10 05:48:55 $


ni = nargin;
if ni==2,
   Sys = Sys1 + Sys2;
   return
elseif ni~=6,
   error('Wrong number of arguments (must be 2 or 6).');
end

% Error checking
[p1,m1] = size(Sys1);
[p2,m2] = size(Sys2);
li1 = length(inp1);
li2 = length(inp2);
lo1 = length(out1);
lo2 = length(out2);
if li1~=li2,
   error('Vectors INP1 and INP2 must have matching lengths.')
elseif lo1~=lo2,
   error('Vectors OUT1 and OUT2 must have matching lengths.')
elseif li1>m1,
   error('Length of INP1 exceeds number of inputs in SYS1.');
elseif li2>m2,
   error('Length of INP2 exceeds number of inputs in SYS2.');
elseif lo1>p1,
   error('Length of OUT1 exceeds number of outputs in SYS1.');
elseif lo2>p2,
   error('Length of OUT2 exceeds number of outputs in SYS2.');
elseif min(inp1)<=0 | max(inp1)>m1,
   error('Index out of range in INP1.')
elseif min(inp2)<=0 | max(inp2)>m2,
   error('Index out of range in INP2.')
elseif min(out1)<=0 | max(out1)>p1,
   error('Index out of range in OUT1.')
elseif min(out2)<=0 | max(out2)>p2,
   error('Index out of range in OUT2.')
end

% Build parallel interconnection
iv1 = 1:m1;   iv1(inp1) = [];
iz1 = 1:p1;   iz1(out1) = [];
iv2 = 1:m2;   iv2(inp2) = [];
iz2 = 1:p2;   iz2(out2) = [];
Sys = append(Sys1([iz1,out1],[iv1,inp1]),zeros(p2-lo2,m2-li2)) + ...
      append(zeros(p1-lo1,m1-li1),Sys2([out2,iz2],[inp2,iv2]));

% end parallel.m
