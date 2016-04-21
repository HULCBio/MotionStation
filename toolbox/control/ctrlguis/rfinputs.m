function [sys,SystemName,InputNames,OutputNames,PlotStyle,ExtraArgs] = ...
rfinputs(PlotType,ArgNames,varargin)
%RFINPUTS  Parse input list for time and frequency response functions.
%
%   RFINPUTS parses the argument list for the various time and
%   frequency response functions.
%
%   LOW-LEVEL UTILITY.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.27.4.5 $  $Date: 2004/04/10 23:14:50 $

% Valid syntax:
%    rfinputs(sys_1,PlotStyle_1,...,sys_k,PlotStyle_k,extra)

% Identify input argument of class LTI

ni = length(varargin);
if ni==0
    sys = {};  SystemName = {};
    InputNames = {''};   OutputNames = {''};
    PlotStyle = {};   ExtraArgs   = {};
    return
end
InputClass = zeros(1,ni);
for ct=1:ni,
    argj = varargin{ct};
    if isa(argj,'lti') | isa(argj,'idmodel') | isa(argj,'idfrd')
        InputClass(ct) = 1;
        varargin{ct} = LocalConvert2LTI(argj);
    elseif isa(argj,'char') & ~any(strcmpi(argj,{'inv','zoh','foh'}))
        InputClass(ct) = -1;
    end
end

% Extract LTI systems and their names
isys = find(InputClass>0);
sep = isys(2:end)-isys(1:end-1);
if isempty(isys) | any(sep>2)
    error('Invalid syntax.')
end
sys = varargin(isys);
nsys = length(sys);
SystemName = cell(nsys,1);
SystemName(1:nsys) = ArgNames(isys);

% Find plot style specifiers if any
istyle = find(InputClass<0);
if any(istyle>isys(end)+1) || any(istyle<2)
   error('Invalid syntax.')
end
PlotStyle = cell(1,nsys);
ColorOnly = strcmpi(PlotType,'pzmap');
ilast = 0;
idxsys = 0;
for ct=1:length(istyle)
   idxsys = idxsys + istyle(ct) - (ilast+1);
   Style = varargin{istyle(ct)};
   [a,b,c,msg] = colstyle(Style);
   if ~isempty(msg)
      error(sprintf('Invalid style string "%s"',PlotStyle{ct}))
   elseif ColorOnly
      PlotStyle{idxsys} = b;
   else
      PlotStyle{idxsys} = Style;
   end
   ilast = istyle(ct);
end

% Determine joint I/O names
[InputNames,OutputNames,EmptySys] = mrgios(sys{:});
if any(EmptySys)
    warning('Some of the specified systems have no input and/or output.')
end

% Plot-specific checks
ExtraArgs = varargin(max([isys,istyle])+1:ni);
switch PlotType
    case {'step','impulse'}
        ExtraArgs = LocalTimeCheck(ExtraArgs,sys);
        MaxArg = 1;
    case 'initial'
        ExtraArgs = LocalInitialCheck(ExtraArgs,sys);
        MaxArg = 2;
    case 'lsim'
        ExtraArgs = LocalLsimCheck(ExtraArgs,sys);
        MaxArg = 4;
    case {'bode','bodemag','nyquist','nichols'}
        ExtraArgs = LocalFreqCheck(ExtraArgs);
        MaxArg = 1;
    case 'sigma'
        ExtraArgs = LocalSigmaCheck(ExtraArgs,sys);
        MaxArg = 2;
    case {'pzmap','iopzmap'}
        MaxArg = 0;
    case 'rlocus'
        [ExtraArgs,sys] = LocalRootLocusCheck(ExtraArgs,sys);
        MaxArg = 1;
    otherwise
        MaxArg = Inf;
end
if length(ExtraArgs)>MaxArg
    error('Invalid syntax.')
end

% Check computability of all responses
if strcmp(PlotType,'lsim')
    [t,x0,u] = deal(ExtraArgs{1:3});
    for ct=1:nsys
       [boo,errmsg] = iscomputable(sys{ct},'lsim',true,t,x0,u);
       error(errmsg)
    end
elseif ~strcmp(PlotType,'unspecified')
    for ct=1:nsys
        [boo,errmsg] = iscomputable(sys{ct},PlotType,true,ExtraArgs{:});
        error(errmsg)
    end
end

%---------------- Local Functions --------------------------

%%%%%%%%%%%%%%%%%%
% LocalTimeCheck %
%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalTimeCheck(ExtraArgs,sys)
% Checks extra inputs for STEP, IMPULSE
if isempty(ExtraArgs)
    t = [];
else
    t = ExtraArgs{1};
end
for ct=length(sys):-1:1
    Ts(ct,1) = get(sys{ct},'Ts');
end
ExtraArgs = {LocalTimeVectorCheck(t,0,Ts)};


%%%%%%%%%%%%%%%%%%
% LocalFreqCheck %
%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalFreqCheck(ExtraArgs)
% Checks extra inputs for BODE, BODEMAG, NYQUIST, NICHOLS
if isempty(ExtraArgs)
    ExtraArgs = {[]};
else
    ExtraArgs{1} = FreqVectorCheck(ExtraArgs{1});
end


%%%%%%%%%%%%%%%%%%%%%
% LocalInitialCheck %
%%%%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalInitialCheck(ExtraArgs,sys)
% Checks extra inputs for INITIAL
switch length(ExtraArgs)
    case 0
        error('Initial condition X0 is missing.')
    case 1
        x0 = ExtraArgs{1};  t = [];
    otherwise
        x0 = ExtraArgs{1};  t = ExtraArgs{2};
end
for ct=length(sys):-1:1
    Ts(ct,1) = get(sys{ct},'Ts');
end
t = LocalTimeVectorCheck(t,0,Ts);
if length(x0)~=prod(size(x0))
    error('Initial condition X0 must be a row or column vector.')
end
ExtraArgs(1:2) = {t, x0(:)};


%%%%%%%%%%%%%%%%%%
% LocalLsimCheck %
%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalLsimCheck(ExtraArgs,sys)
% Checks extra inputs for LSIM
% Look for zoh/foh string
ioh = find(strcmpi('zoh',ExtraArgs) | strcmpi('foh',ExtraArgs));
if ~isempty(ioh)
    InterpRule = ExtraArgs{ioh};
    ExtraArgs(ioh) = [];
else
    InterpRule = '';
end
if isempty(ExtraArgs)
    error('Input data U is missing.')
else
    ExtraArgs = [ExtraArgs cell(1,3-length(ExtraArgs))];
    [u,t,x0] = deal(ExtraArgs{1:3});
end

% Compute sample times
nsys = length(sys);
for ct=nsys:-1:1
    Ts(ct,1) = get(sys{ct},'Ts');
end

% Check input vector
if isempty(u),
    % Convenience for systems w/o input
    u = zeros(max([size(u),length(t)]),0);
elseif ndims(u)==2 && size(u,2)~=size(sys{1},2),
    % Transpose U (users often supply a row vector for SISO systems)
    u = u.';
end
su = size(u);

% Check time vector
if isempty(t)
    % If no time vector and all systems discrete or all cts with same Ts then use equisampled t
    Tsref = abs(Ts(1));
    if any(Ts==0)
        error('Time vector T must be supplied for continuous-time models.')
    elseif all(Ts==-1) | (Tsref>0 & all(Ts==Tsref)),
        % All sample times are equal
        t = Tsref * (0:1:su(1)-1)';
    else
        error('Discrete-time models must have matching sample times.')
    end
else
    % T supplied
    t = TimeVectorCheck(t);
end

% Check initial condition is not a row vect
if length(x0)~=prod(size(x0))
    error('Initial condition X0 must be a row or column vector.')
end

ExtraArgs = {t,x0(:),u,InterpRule};  % order consistent with GENTRESP


%%%%%%%%%%%%%%%%%%%
% LocalSigmaCheck %
%%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalSigmaCheck(ExtraArgs,sys)
% Checks extra inputs for SIGMA
w = [];
if ~isempty(ExtraArgs) & ~ischar(ExtraArgs{1}) % for TYPE = 'inv'
    w = ExtraArgs{1};
    ExtraArgs(1) = [];
end
w = FreqVectorCheck(w);
% Type argument
if isempty(ExtraArgs)
    type = 0;
else
    type = ExtraArgs{1};
    if strcmpi(type,'inv')
        type = 1;
    end
end
if ~isequal(size(type),[1 1]) | ~any(type==[0 1 2 3])
    error('Unknown type of singular value plot.')
elseif type>0
    % Check systems are square for TYPE 1,2,3
    for ct=1:length(sys),
        [ny,nu] = size(sys{ct});
        if ny~=nu,
            error('Types 1 through 3 only applicable to square systems.')
        end
    end
end
ExtraArgs = {w type};


%%%%%%%%%%%%%%%%%%%%%%%
% LocalRootLocusCheck %
%%%%%%%%%%%%%%%%%%%%%%%
function [ExtraArgs,sys] = LocalRootLocusCheck(ExtraArgs,sys)
% Checks extra inputs for INITIAL
if isempty(ExtraArgs)
    ExtraArgs = {[]};
end
for ct=1:length(sys)
    if isdt(sys{ct}) & hasdelay(sys{ct})
        % Map delay times to poles at z=0 in discrete-time case
        sys{ct} = delay2z(sys{ct});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTimeVectorCheck %
%%%%%%%%%%%%%%%%%%%%%%%%
function t = LocalTimeVectorCheck(t,t0,Ts)
% Check time input is valid vector or final time.
% Last argument = absolute start time (e.g., t=0 for step)
t = TimeVectorCheck(t,t0);

% Check T against system sample times
lt = length(t);
if lt==0 & any(Ts<0) & any(Ts>0),
    % No time vector or final time specified
    error('Time vector must be specified when mixing specified and unspecified sample times.')
elseif lt==1 & all(Ts==-1) & ~isequal(t,round(t))
    % Final time specified
    error('Final time must be an integer (no. of samples) when sample times are unspecified.');
end


%%%%%%%%%%%%%%%%%%%%
% LocalConvert2LTI %
%%%%%%%%%%%%%%%%%%%%
function sys = LocalConvert2LTI(sys)
% Convert all models to @lti subclasses
if ~isa(sys,'lti')
    % Must comes from IDENT at this point
    % Check the number of inputs to the model
    nu = size(sys,'nu');
    if nu > 0
        % If the model is not a time series or output spectrum extract the
        % model from the input channels to output channels.
        sys = sys('m');
    elseif nu == 0 & isa(sys,'idfrd')
        % If the model is an output spectrum model error out.
        error('Cannot plot output spectra of idfrd models.')
    else
        % If the model is a time series idmodel extract the model from the
        % noise channels to output channels
        sys = sys('n');
    end
    % Perform the conversion of the IDENT models to LTI Models
    if isa(sys,'idss')
        sys = ss(sys);
    elseif isa(sys,'idfrd')
        sys = frd(sys);
    else
        sys = tf(sys);
    end
end
