function sys = idgrey(varargin)
%IDGREY  Create IDGREY model structure
%       
%   M = IDGREY(MfileName,ParameterVector,CDmfile,FileArgument)
%   M = IDGREY(MfileName,ParameterVector,CDmfile,...
%              FileArgument,Ts,'Property',Value,..)
%
%   M: returned as a IDGREY model object describing a user defined
%      linear model structure.
%
%   MfileName is the name of the m-file that describes the structure. 
%     It should have the format
%
%     [A,B,C,D,K,X0] = MfileName(ParameterVector,Ts,FileArgument)
%
%     where the output describes the linear system in innovations form:
%
%      xn(t) = A x(t) + B u(t) + K e(t) ;      x(0) = X0
%       y(t) = C x(t) + D u(t) + e(t)
%
%     in continuous or discrete time. Here xn(t) = x(t+Ts) in 
%     discrete time and xn(t) = d/dt x(t) in continuous time.
%    
%   ParameterVector is the (column) vector of nominal parameters that
%      determine the model matrices. These correspond to the free 
%      parameters to be estimated.
%  
%   CDmfile describes how the user written mfile handles continuous/discrete
%           time models.
%      CDmfile = 'c' means that the user written mfile always returns
%           the continuous time system matrices, no matter the value of Ts.
%           The sampling of the system will be done by the toolbox's 
%           internal algorithms, in accordance with the indicated 
%           data intersample behaviour. (DATA.InterSample).
%      CDmfile = 'cd' means that the mfile is written so that it returns 
%           the continuous time system matrices when the argument Ts = 0,
%           and the discrete time system matrices, obtained by sampling with
%           sampling interval Ts when Ts > 0. In this case the user's choice
%           of sampling routines will override the toolbox's internal sampling
%           algorithms.
%      CDmfile = 'd' means that the mfile always returns discrete
%           time model matrices that may or may not depend on the
%           value of Ts. 
%
%   FileArgument is an extra argument to the mfile that can be used
%      in any suitable way. 
%
%   Ts is the sampling interval of the model. 
%      Default: Ts = 1 if CDmfile = 'd'
%               Ts = 0 if CDmfile = 'c' or 'cd'. (Continuous time model.)
%
%   For more info on IDGREY properties, type IDPROPS IDGREY.
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/04/10 23:16:58 $

ni = nargin;
if ni == 0
    sys = idgrey([],[],'c',[]);
    return
end

if ni & (isa(varargin{1},'ss')|isa(varargin{1},'zpk')|isa(varargin{1},'tf')|...
        (isa(varargin{1},'idmodel')&~isa(varargin{1},'idgrey')))
    error('Conversion of general models to idgrey not possible.')
end

% Quick exit for idgrey objects
if ni & isa(varargin{1},'idproc')
  sys = pvget(varargin{1},'idgrey');
  sys.DisturbanceModel = 'Model';
  return
end

if ni & isa(varargin{1},'idgrey'),
    if ni~=1
        error('Use SET to modify the properties of IDGREY objects.');
    end
    sys = varargin{1};
    return
end

superiorto('idpoly')
superiorto('iddata')
try
    superiorto('lti','zpk','ss','tf','frd')
end

% Dissect input list
PVstart = min(find(cellfun('isclass',varargin(5:end),'char')))+4;
if isempty(PVstart),PVstart=0;end


if nargin<4
    msg = sprintf(['MfileName, ParameterVector, CDmfile and FileArgument must be specified.',...
            '\n(If your Mfile does not require any FileArgument, just add [] as the 4th ',...
            'argument.)']);
    error(msg)
end
mfna = varargin{1};
if ~isempty(mfna)
    if ~isa(mfna,'char')
    error('''MfileName'' must be a string.')
end
end
par = varargin{2}; % Check size
if ~isa(par,'double')
    error('''ParameterVector'' must be a vector of numbers.')
end

par = par(:);
cd = lower(varargin{3});
try
    cd = pnmatchd(cd,{'c';'cd';'d'});
catch
    error(sprintf(['Invalid value for ''CDmfile''.\nShould be one of ''c'', ''d'', or ''cd''.']))
end
arg = varargin{4};

if nargin > 4 &(PVstart==6|PVstart==0)
    Ts = varargin{5};
else
    if cd == 'd'
        Ts = 1;
    else
        Ts = 0;
    end
end

if ~isempty(varargin{1})
    
    try
        [A,B,C,D,K,X0] = feval(mfna,par,Ts,arg);
    catch
        error(sprintf([' Error or mismatch in Mfile and Parameter or FileArgument size.',...
                '\n The error message is: ''',lasterr,'''']))  
    end
    error(abccheck(A,B,C,D,K,X0,'mat'))
    if isempty(B)
        if size(B,1)~=size(A,1)|size(D,1)~=size(C,1)
            error(sprintf(['  MATLAB requires inner dimensions of empty matrices to',...
                    '\n  be consistent. Please edit your mfile so that',...
                    '\n  B = zeros(%d,0) and D = zeros(%d,0)'],size(A,1),size(C,1)))
        end
    end
else
    Ts = 1;D = [];A = []; cd = 'c'; Value =[]; B = []; mfna = [];
end
ny = size(D,1);nx = size(A,1);nu =size(B,2);
sys.MfileName = mfna; 
if nx>0
sys.StateName = defnum([],'x',nx);
else
    sys.StateName = cell(0,1);
end

sys.CDmfile = cd; 
sys.FileArgument = arg;
sys.InitialState = 'Model';
sys.DisturbanceModel = 'Model';
idparent = idmodel(ny, nu, Ts, par, []); 
sys = class(sys, 'idgrey', idparent);
sys = timemark(sys,'c');
% If the parameter vector is a scalar, make sure that it is still indexed:
if length(par)==1
    try
        [A,B,C,D,K,X0] = feval(mfna,[par;1],Ts,arg);
    catch
        warning(sprintf(['When the parameter vector is a scalar, it is still advisable'...
                '\nto address it with index (like par(1)) in the mfile.'...
                '\nThis will allow setting DisturbanceModel and InitialState to Estimate.']))  
    end
end
% Finally, set any PV pairs, some of which may be in the parent.
if PVstart>0
    try
        set(sys, varargin{PVstart:end})
    catch
        error(lasterr)
    end
end
