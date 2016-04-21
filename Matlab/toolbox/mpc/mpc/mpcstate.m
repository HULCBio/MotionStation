function this = mpcstate(varargin)
%MPCSTATE Constructor for @mpcstate class. 
%
%   x=mpcstate(mpcobj,xp,xd,xn,u) creates an MPC state object compatible with the mpc object
%   mpcobj with the following fields:
%            Plant  Nxp dimensional array of plant states (including 
%                   possible offsets)
%      Disturbance  Nxd dimensional array of disturbance model states. This 
%                   contains the states of the model for unmeasured disturbance 
%                   input and (appended below) the states of unmeasured 
%                   disturbances added on outputs.
%            Noise  Nxn dimensional array of noise model states
%         LastMove  Nu dimensional array of previous manipulated variables 
%                   (including possible offsets)
% 
%   given the plant state xp, the disturbance model state xd, the noise model state nx,
%   and the previous input u
%
%  x=mpcstate(mpcobj) returns a zero extended initial state compatible with the 
%  mpc object mpcobj, with x.Plant and x.LastMove initialized at mpcobj.Model.Nominal.X and
%  mpcobj.Model.Nominal.U, respectively.
%
%  x=mpcstate (no input arguments) returns an empty mpcstate object.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2004/04/16 22:09:26 $   

if nargin>0
    mpcobj = varargin{1};
    this = mpcdata.mpcstate(mpcobj,varargin{2:end});
    try
        assignin('caller',inputname(1),mpcobj);
    end
else
    this = mpcdata.mpcstate(varargin{:});
end

