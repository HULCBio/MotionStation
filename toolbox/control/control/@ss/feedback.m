function sys = feedback(sys1,sys2,varargin)
%FEEDBACK  Feedback connection of two LTI models. 
%
%   SYS = FEEDBACK(SYS1,SYS2) computes an LTI model SYS for
%   the closed-loop feedback system
%
%          u --->O---->[ SYS1 ]----+---> y
%                |                 |           y = SYS * u
%                +-----[ SYS2 ]<---+
%
%   Negative feedback is assumed and the resulting system SYS 
%   maps u to y.  To apply positive feedback, use the syntax
%   SYS = FEEDBACK(SYS1,SYS2,+1).
%
%   SYS = FEEDBACK(SYS1,SYS2,FEEDIN,FEEDOUT,SIGN) builds the more
%   general feedback interconnection:
%                      +--------+
%          v --------->|        |--------> z
%                      |  SYS1  |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[  SYS2  ]<---+
%
%   The vector FEEDIN contains indices into the input vector of SYS1
%   and specifies which inputs u are involved in the feedback loop.
%   Similarly, FEEDOUT specifies which outputs y of SYS1 are used for
%   feedback.  If SIGN=1 then positive feedback is used.  If SIGN=-1 
%   or SIGN is omitted, then negative feedback is used.  In all cases,
%   the resulting LTI model SYS has the same inputs and outputs as SYS1 
%   (with their order preserved).
%
%   If SYS1 and SYS2 are arrays of LTI models, FEEDBACK returns an LTI
%   array SYS of the same dimensions where 
%      SYS(:,:,k) = FEEDBACK(SYS1(:,:,k),SYS2(:,:,k)) .
%
%   See also LFT, PARALLEL, SERIES, CONNECT, LTIMODELS.

%   P. Gahinet  6-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.25 $  $Date: 2002/04/10 06:01:49 $

ni = nargin;
error(nargchk(2,5,ni));
switch ni
case 2
   sign = -1;
case 3
   sign = varargin{1};
case 4
   sign = -1;   [indu,indy] = deal(varargin{:});
case 5
   [indu,indy,sign] = deal(varargin{:});
end

% Make sure both systems are state-space models
try
   sys1 = ss(sys1);
   sys2 = ss(sys2);
catch
   if issiso(sys1) & issiso(sys2),
      sys = ss(feedback(tf(sys1),tf(sys2),varargin{:}));
      return
   else
      error('FEEDBACK cannot handle improper MIMO models.')
   end
end

% Get dimensions
sizes1 = size(sys1.d);
sizes2 = size(sys2.d);
nsys1 = prod(sizes1(3:end));
nsys2 = prod(sizes2(3:end));

% Determine indexes for v/u and z/y
if ni<4,
   indu = 1:sizes1(2);   
   indy = 1:sizes1(1);
elseif min(size(indu))>1,
   error('Third input FEEDIN must be a row vector.');
elseif min(size(indy))>1,
   error('Fourth input FEEDOUT must be a row vector.');
end

% Check dimension compatibility
nd1 = length(sizes1);
nd2 = length(sizes2);
sizes = sizes1;
if length(indu)~=sizes2(1) | length(indy)~=sizes2(2),
   error('I/O dimensions of SYS2 don''t match feedback channel widths in SYS1.');
elseif nd1>2 & nd2>2 & ~isequal(sizes1(3:end),sizes2(3:end)),
   error('Model arrays SYS1 and SYS2 have incompatible array dimensions.')
elseif nd2>2,
   % Determine size of result
   sizes(3:max(nd1,nd2)) = ...
      max([sizes1(3:end) ones(1,nd2-nd1)],[sizes2(3:end) ones(1,nd1-nd2)]);
end

% LTI inheritance. Use try/catch to keep errors at top level
sys = sys1;
try
   sys.lti = feedback(sys1.lti,sys2.lti,[isstatic(sys1),isstatic(sys2)]);
catch
   rethrow(lasterror)
end

% Check for time delays
Ts = getst(sys);
if hasdelay(sys1) | hasdelay(sys2),
   if Ts, 
      % Discrete-time case: map discrete delays to poles at z=0
      sys1.lti = pvset(sys1.lti,'Ts',Ts);
      sys1 = delay2z(sys1);
      sys2.lti = pvset(sys2.lti,'Ts',Ts);
      sys2 = delay2z(sys2);
   else
      error('FEEDBACK cannot handle time delays.')
   end
end

% Predimension A,C,D,E arrays
ArraySizes = [sizes(3:end) 1 1];
sys.a = cell(ArraySizes);
sys.b = cell(ArraySizes);
sys.c = cell(ArraySizes);
sys.e = cell(ArraySizes);

% Loop over each model
% Use try/catch to guard against algebraic loop errors
[e1,e2] = ematchk(sys1.e,sys1.a,sys2.e,sys2.a);
try
   for k=1:max(nsys1,nsys2),
      k1 = min(k,nsys1);
      k2 = min(k,nsys2);
      
      % Close loop for k-th pair of models
      [sys.a{k},sys.b{k},sys.c{k},sys.d(:,:,k),sys.e{k}] = feed2d(...
         sys1.a{k1},sys1.b{k1},sys1.c{k1},sys1.d(:,:,k1),e1{k1},...
         sys2.a{k2},sys2.b{k2},sys2.c{k2},sys2.d(:,:,k2),e2{k2},indu,indy,sign);
   end
catch
   rethrow(lasterror)
end

% State names and E matrix
sys.e = ematchk(sys.e);
sys.StateName = [sys1.StateName ; sys2.StateName];

% Adjust state names
Nx = size(sys,'order');
if length(Nx)>1 | Nx~=length(sys.StateName),
   % Uneven number of states: delete state names
   sys.StateName = repmat({''},[max(Nx(:)) 1]);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [af,bf,cf,df,ef] = feed2d(a1,b1,c1,d1,e1,a2,b2,c2,d2,e2,indu,indy,sign)
%FEED2D  Feedback for a single pair of models

sizes1 = size(d1);  
ny1 = sizes1(1);  nu1 = sizes1(2);
ny2 = length(indu); nu2 = length(indy);
nx1 = size(a1,1);   nx2 = size(a2,1);
ne1 = size(e1,1);   ne2 = size(e2,1);

% Form open-loop interconnection  
%     .
%     X  = A * X  + B1  * W + B2  * U
%     Z  = C1 * X + D11 * W + D12 * U
%     Y  = C2 * X + D21 * W + D22 * U
% where 
%     X = [x1 ; x2],   W = [v ; u],   Z = [z ; y]
%     U = [in1 ; in2]    (u+in1 = second input to SYS1, in2 = input to SYS2)
%     Y = [out2 ; out1]  (out1 = second output of SYS1, out2 = output of SYS2)
%
A = [a1 , zeros(nx1,nx2) ; zeros(nx2,nx1) , a2];
B1 = [b1 ; zeros(nx2,nu1)];
B2 = [b1(:,indu) , zeros(nx1,nu2); zeros(nx2,ny2) , b2];
C1 = [c1 , zeros(ny1,nx2)];
C2 = [zeros(ny2,nx1) c2 ; c1(indy,:) , zeros(nu2,nx2)];
D12 = [d1(:,indu) , zeros(ny1,nu2)];
D21 = [zeros(ny2,nu1) ; d1(indy,:)];

% Close the loop by setting
%      in1 = sign * out2,   in2 = out1
% i.e.,  
%      Y = [sign*I 0;0  I] * U
%
% Form  M = I - D22:
M = [diag(sign*ones(1,ny2)) -d2 ; -d1(indy,indu) eye(nu2)];

% Balance M  before inverting it to avoid "algebraic loop" 
% error when, e.g, M = [1 1e30;0 1] - possible in SISOTOOL
MM = max(abs(M(:,:,:)),[],3);
MM(abs(MM)<eps) = 1/max(MM(:));  
[T,MM] = balance(MM);
Ti = diag(1./diag(T));

% LU factorize and test for singularity (algebraic loop)
[L,U,P] = lu(Ti*M*T);
if rcond(U)<eps,
   error('Algebraic loop: feedback interconnection is non causal.')
end

% Compute  Cf and Df such that U = Cf X + Df W
Cf = T*(U\(L\(P*(Ti*C2))));
Df = T*(U\(L\(P*(Ti*D21))));

% Derive state-space realization of feedback system
af = A + B2 * Cf;
bf = B1 + B2 * Df;
cf = C1 + D12 * Cf;
df = d1 + D12 * Df;
ef = [e1 zeros(ne1,ne2) ; zeros(ne2,ne1) e2];


