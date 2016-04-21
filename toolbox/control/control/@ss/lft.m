function sys = lft(sys1,sys2,nu,ny)
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
%   $Revision: 1.8 $  $Date: 2002/04/10 06:01:21 $

ni = nargin;
error(nargchk(2,4,ni))
if ni==3,
   error('Number of inputs must be 2 or 4.')
end

% Ensure both operands are SS
sys1 = ss(sys1);
sys2 = ss(sys2);

% Get system dimensions
sizes1 = size(sys1);   sizes2 = size(sys2);   
ny1 = sizes1(1);  nu1 = sizes1(2);
ny2 = sizes2(1);  nu2 = sizes2(2);

% Figure out NU and NY if unspecified
if ni==2
   if nu1>=ny2 & ny1>=nu2,
      nu = ny2; 
      ny = nu2;
   elseif ny1<=nu2 & nu1<=ny2,
      nu = nu1; 
      ny = ny1;
   else
      error('Ambiguous configuration: please specify the dimensions of u and y.')
   end
elseif nu>ny2 | nu>nu1,
   error('NU exceeds number of inputs of SYS1 or number of outputs of SYS2.')
elseif ny>nu2 | ny>ny1,
   error('NY exceeds number of inputs of SYS2 or number of outputs of SYS1.')
end

% Check compatibility of higher dimensions
if ~isequal(sizes1(3:end),sizes2(3:end)) & ...
   ~all(sizes1(3:end)==1) & ~all(sizes2(3:end)==1),
   error('Arrays SYS1 and SYS2 must have compatible dimensions.')
end

% Determine signal dimensions
lw1 = nu1-nu;  lz1 = ny1-ny;
lw2 = nu2-ny;  lz2 = ny2-nu;

% Append SYS1 and SYS2 and close the positive feedback loop 
%                   [u1 ; u2] = [y2 ; y1]
% in
%                         +-------+
%             w1 -------->|       |-------> z1
%                         |  SYS1 |
%             u1 -------->|       |-------> y1
%                         +-------+     
%                         +-------+
%             u2 -------->|       |-------> y2
%                         |  SYS2 |
%             w2 -------->|       |-------> z2
%                         +-------+     
%
sys = feedback(append(sys1,sys2),[zeros(nu,ny) eye(nu) ; eye(ny) zeros(ny,nu)],...
                                           [lw1+1:lw1+nu+ny],[lz1+1:lz1+nu+ny],+1);

% Select inputs [w1;w2] and outputs [z1;z2]
no = ny1+ny2;
ni = nu1+nu2;
sys = subsref(sys,substruct('()',{[1:lz1 no-lz2+1:no],[1:lw1 ni-lw2+1:ni]}));



