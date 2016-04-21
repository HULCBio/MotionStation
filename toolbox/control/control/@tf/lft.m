function sys = star(sys1,sys2,varargin)
%LFT  Redheffer star product of LTI systems.
%
%   SYS = LFT(SYS1,SYS2,NU,NY) evaluates the star product SYS of
%   the two LTI models SYS1 and SYS2.  The star product or 
%   linear fractional transformation (LFT) corresponds to the 
%   following feedback interconnection of SYS1 and SYS2:
%		
%                        +-------+
%            w1 -------->|       |-------> z1
%                        |  SYS1 |
%                  +---->|       |-----+
%                  |     +-------+     |
%                u |                   | y
%                  |     +-------+     |
%                  +-----|       |<----+
%                        |  SYS2 |
%           z2 <---------|       |-------- w2
%                        +-------+
%
%   The feedback loop connects the first NU outputs of SYS2 to the 
%   last NU inputs of SYS1 (signals u), and the last NY outputs of 
%   SYS1 to the first NY inputs of SYS2 (signals y).  The resulting 
%   LTI model SYS maps the input vector [w1;w2] to the output vector 
%   [z1;z2].
%
%   SYS = LFT(SYS1,SYS2) returns
%     * the lower LFT of SYS1 and SYS2 if SYS2 has fewer inputs and 
%       outputs than SYS1.  This amounts to deleting w2,z2 in the
%       above diagram.
%     * the upper LFT of SYS1 and SYS2 if SYS1 has fewer inputs and 
%       outputs than SYS2.  This amounts to deleting w1,z1 above.
%
%   If SYS1 and SYS2 are arrays of LTI models, LFT returns an LTI
%   array SYS of the same dimensions where 
%      SYS(:,:,k) = LFT(SYS1(:,:,k),SYS2(:,:,k),NU,NY) .
%
%   See also FEEDBACK, CONNECT, LTIMODELS.

%   Author(s): P. Gahinet, 5-10-95.
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 06:07:36 $

ni = nargin;
error(nargchk(2,4,ni))
if ni==3,
   error('Number of inputs must be 2 or 4.')
end

% Computations done in state-space
sys = tf(lft(ss(sys1),ss(sys2),varargin{:}));



