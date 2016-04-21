function [JE,JJ,normJE] = calcjejj(net,Pd,Zb,Zi,Zl,N,Ac,En,Q,TS,MR)
%CALCJEJJ Calculate Jacobian performance vector.
%
%  Syntax
%
%    [je,jj,normje] = calcjejj(net,Pd,BZ,IWZ,LWZ,N,Ac,El,Q,TS,MR)
%
%  Description
%
%    This function calculates two values (related to the Jacobian
%    of a network) required to calculate the network's Hessian,
%    in a memory efficient way.
%
%    Two values needed to calculate the Hessian of a network are
%    J*E (Jacobian times errors) and J'J (Jacobian squared).
%    However the Jacobian J can take up a lot of memory.
%
%    This function calculates J*E and J'J by dividing up training
%    vectors into groups, calculating partial Jacobians Ji and
%    its associated values Ji*Ei and Ji'Ji, then summing the
%    partial values into the full J*E and J'J values.
%
%    This allows the J*E and J'J values to be calculated with a
%    series of smaller Ji matrices, instead of a larger J matrix.
%
%    [je,jj,normgX] = CALCJEJJ(NET,PD,BZ,IWZ,LWZ,N,Ac,El,Q,TS,MR) takes,
%      NET    - Neural network.
%      PD     - Delayed inputs.
%      BZ     - Concurrent biases.
%      IWZ    - Weighted inputs.
%      LWZ    - Weighted layer outputs.
%      N      - Net inputs.
%      Ac     - Combined layer outputs.
%      El     - Layer errors.
%      Q      - Concurrent size.
%      TS     - Time steps.
%      MR     - Memory reduction factor.
%    and returns,
%      je     - Jacobian times errors.
%      jj     - Jacobian transposed time the Jacobian.
%     normgx - Magnitute of the gradient.
%
%  Examples
%
%    Here we create a linear network with a single input element
%    ranging from 0 to 1, two neurons, and a tap delay on the
%    input with taps at 0, 2, and 4 timesteps.  The network is
%    also given a recurrent connection from layer 1 to itself with
%    tap delays of [1 2].
%
%      net = newlin([0 1],2);
%      net.layerConnect(1,1) = 1;
%      net.layerWeights{1,1}.delays = [1 2];
%
%    Here is a single (Q = 1) input sequence P with 5 timesteps (TS = 5),
%    and the 4 initial input delay conditions Pi, combined inputs Pc,
%    and delayed inputs Pd.
%
%      P = {0 0.1 0.3 0.6 0.4};
%      Pi = {0.2 0.3 0.4 0.1};
%      Pc = [Pi P];
%      Pd = calcpd(net,5,1,Pc);
%
%    Here the two initial layer delay conditions for each of the
%    two neurons, and the layer targets for the two neurons over
%    five timesteps are defined.
%
%      Ai = {[0.5; 0.1] [0.6; 0.5]};
%      Tl = {[0.1;0.2] [0.3;0.1], [0.5;0.6] [0.8;0.9], [0.5;0.1]};
%
%    Here the network's weight and bias values are extracted, and
%    the network's performance and other signals are calculated.
%
%      [perf,El,Ac,N,BZ,IWZ,LWZ] = calcperf(net,X,Pd,Tl,Ai,1,5);
%
%    Finally we can use CALCGX to calculate the Jacobian times error,
%    Jacobian squared, and the norm of the Jocobian times error using
%    a memory reduction of 2.
%
%      [je,jj,normje] = calcjejj(net,Pd,BZ,IWZ,LWZ,N,Ac,El,1,5,2);
%
%    The results should be the same whatever the memory reduction
%    used.  Here a memory reduction of 3 is used.
%
%      [je,jj,normje] = calcjejj(net,Pd,BZ,IWZ,LWZ,N,Ac,El,1,5,3);
%
%  See also CALCJX, CALCJEJJ.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:17:15 $

% Inputs
%
% Pd - NlxNixTS cell array         PD{i,j,ts}  - DijxQ matrix or []
% Zb - Nlx1 cell array             Zb{i}       - SixQ matrix or []
% Zi - NlxNixTS cell array         Zi{i,j,ts}  - SixQ matrix or []
% Zl - NlxNlxTS cell array         Zl{i,j,ts}  - SixQ matrix or []
% N  - NlxTS cell array            N{i}        - SixQ matrix
% Ac - Nlx(LD+TS) cell array       Ac{i,LD+ts} - SixQ matrix
% En - NlxTS cell array            E{i,ts}     - SixQ matrix or []
%
% Locals
%
% Em - sum(Vi)xQ matrix
% Ex - sum(Vi)*Q vector
% Jx - XLenxsum(Vi)*Q matrix
%
% Outputs
%
% JE - XLen vector
% JJ - XLenxXLen matrix

% Standard Calculation
if (MR == 1)
  Em = cell2mat(En);
  Ex = Em(:);
  Jx = calcjx(net,Pd,Zb,Zi,Zl,N,Ac,Q,TS);
  JE = Jx * Ex;
  JJ = Jx * Jx';
  
% Reduced Memory Calculation
else
  MR = min(MR,Q);
  Qstop = floor((1:MR)*(Q/MR));
  Qstart = [0 Qstop(1:(end-1))]+1;
  Q2 = Qstop-Qstart+1;

  Pd = batchdiv(Pd,MR,Qstart,Qstop);
  Zb = batchdiv(Zb,MR,Qstart,Qstop);
  Zi = batchdiv(Zi,MR,Qstart,Qstop);
  Zl = batchdiv(Zl,MR,Qstart,Qstop);
  N = batchdiv(N,MR,Qstart,Qstop);
  Ac = batchdiv(Ac,MR,Qstart,Qstop);
  En = batchdiv(En,MR,Qstart,Qstop);

  Em = cell2mat(En{1});
  Ex = Em(:);
  Jx = calcjx(net,Pd{1},Zb{1},Zi{1},Zl{1},N{1},Ac{1},Q2(1),TS);
  JE = Jx * Ex;
  JJ = Jx * Jx';
  for q=2:MR
    Em = cell2mat(En{q});
    Ex = Em(:);
    Jx = calcjx(net,Pd{q},Zb{q},Zi{q},Zl{q},N{q},Ac{q},Q2(q),TS);
    JE = JE + Jx * Ex;
    JJ = JJ + Jx * Jx';
  end
end

normJE = sqrt(JE'*JE);

%===============================================================
function b_div = batchdiv(b,QD,Qstart,Qstop)

size_b = size(b);
len_b = prod(size_b);
b_div = cell(1,QD);
for q=1:QD
  b_div_q = cell(size_b);
  Qind = Qstart(q):Qstop(q);
  for i=1:len_b
    if ~isempty(b{i})
      b_div_q{i} = b{i}(:,Qind);
  end
  end
  b_div{q} = b_div_q;
end

%===============================================================
