function [ae,be,ce,de] = destim(a,b,c,d,l,e,f)
%DESTIM  Form discrete Kalman estimator.
%
%   [Ae,Be,Ce,De] = DESTIM(A,B,C,D,L) produces the Kalman estimator 
%   based on the discrete system (A,B,C,D) with Kalman gain matrix L 
%   assuming all the outputs of the system are sensor outputs.  The 
%   resulting state-space estimator is
%
%       xBar[n+1] = [A-ALC] xBar[n] + [AL] y[n]
%
%        |yHat|   = |C-CLC| xBar[n] + |CL| y[n]
%        |xHat|     |I-LC |           |L |
%
%   and has estimated sensors yHat and estimated states xHat as 
%   outputs, and sensors y as inputs.  
%
%   [Ae,Be,Ce,De] = DESTIM(A,B,C,D,L,SENSORS,KNOWN) forms the Kalman 
%   estimator using the sensors specified by SENSORS, and the 
%   additional known inputs specified by KNOWN.  The resulting system
%   has estimated sensors and states as outputs, and the known inputs
%   and sensors as inputs.  The KNOWN inputs are non-stochastic inputs
%   of the plant and are usually control inputs.
%
%   See also  DLQE, DLQR, DREG, ESTIM.

%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:34:35 $

error(nargchk(5,7,nargin));
if ~((nargin==5)|(nargin==7)), error('Wrong number of input arguments.'); end

[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[nx,na] = size(a);
[ny,nu] = size(d);

if (nargin==5)
  sensors = [1:ny]; known = [];
end
if (nargin==7)
  sensors = e; known = f;
end

nsens = length(sensors); nknown = length(known);

% Check size of L with number of states and sensors
[nl,ml] = size(l);
if (ml~=nsens)
  error('Number of sensors and size of L matrix don''t match.'); end
if (nl~=nx)
  error('The A and L matrices must have the same number of rows.'); end

inputs = [1:nsens] + nu; outputs = sensors + ny; states = [1:nx] + 2*ny;

% --- Form continuous Kalman estimator ---
ae = a;
be = [b,a*l];
ce = [c;c;eye(nx)];
de = [d, zeros(ny,nsens);d,c*l;zeros(nx,nu), l];
% close sensor feedback loop
[ae,be,ce,de] = cloop(ae,be,ce,de,sensors,-inputs);
[ae,be,ce,de] = ssselect(ae,be,ce,de,[known,inputs],[outputs,states]);
