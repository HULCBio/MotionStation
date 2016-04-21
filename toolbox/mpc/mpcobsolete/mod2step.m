function [plant, dplant] = mod2step(mod, tfinal, delt2, nout)

%MOD2STEP Calculate step response model from a SS model in MPC Mod format.
%     	plant = mod2step(mod,tfinal)
%  	[plant, dplant] = mod2step(mod, tfinal, delt2, nout)
%
% Inputs:
%    mod:      appropriate MPC state-space format model of system.
%    tfinal:   truncation time for step response model.
%    delt2:    desired sampling interval for step response model.
%              Optional; default value is minfo(1) of mod.
%    nout:     Optional output stability indicator. For stable systems,
%              set it equal to number of outputs, ny. For systems
%              with one or more integrating outputs, define a
%              vector of length ny with nout(i)=0 indicating an
%              integrating output and nout(i)=1 indicating a stable output.
%              Default value is nout=ny (only stable outputs).
%
% Outputs:
%    plant:    step response coefficient matrix to the manipulated
%              variables.
%   dplant:    step response coefficient matrix to the disturbances.
%              Optional.
%
% See also PLOTSTEP, SS2STEP, TFD2STEP.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('usage: [plant, dplant] = mod2step(mod, tfinal, delt2, nout)')
   return
end

if (nargin < 2 | nargin > 4)
   error( ' incorrect number of input arguments.')
end;

[A,B,C,D,minfo] = mod2ss(mod);
T  = minfo(1);
ny = sum(minfo(1,6:7));

if (nargin == 2)
   delt2= T;
   nout = ny;
elseif (nargin == 3)
   nout = ny;
   if isempty(delt2)
      delt2= T;
   end
else
   if isempty(nout)
      nout=ny;
   else
      nout=nout(:);    % allows either column or row vector input
   end
end

% contribution from manipulated variables
iu=[1:minfo(3)];% this index points to the columns for the man. vars.
[plant] = ss2step(A, B(:,iu), C, D(:,iu), tfinal, minfo(1), delt2, nout);

% contribution from disturbances
if (sum(minfo(1,4:5))~=0 & nargout > 1)
   id=[minfo(3)+1:sum(minfo(3:5))]; % points to disturbance input columns.
   [dplant] = ss2step(A, B(:,id), C, D(:,id), tfinal, minfo(1), delt2, nout);
end

% end of function MOD2STEP.
