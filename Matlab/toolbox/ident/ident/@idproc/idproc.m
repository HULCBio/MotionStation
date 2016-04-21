function sys = idproc(varargin)
%IDPROC  Create the continuous time Process Model IDPROC model structure
%       
%   M = IDPROC(TYPE)
%   M = IDPROC(TYPE,'Property',Value,..)
%
%   M: returned as a IDPROC model object describing a continuous time
%      process model structure
%   The models are of the general type gain + time constant + delay as in
%
%             Kp
%   G(s) = ---------  exp(-Td*s)
%          1 + Tp1*s
%
%   A more general case has up to three real poles and a possible zero:
%
%                      1+Tz*s
%   G(s) = Kp -------------------------- exp(-Td*s)
%             (1+Tp1*s)(1+Tp2*s)(1+Tp3*s)
%
%   Two of the poles may be underdamped (complex)  
%                           1+Tz*s
%   G(s) = Kp --------------------------------- exp(-Td*s)
%             (1+2*Zeta*Tw*s+(s*Tw)^2)(1+Tp3*s)
%
%   In all these cases an integration may be enforced, as in
%               Kp
%   G(s) = ------------  exp(-Td*s)
%           s(1 + Tp1*s)
%
%   The argument TYPE is a string that defines special model structures 
%   of these kinds. It is of the character TYPE = 'P2ZDUI', explained as follows:
%
%   'Pk': means a process with k poles (not including a possible integration)
%   'Z': means that a Zero (numerator Tz~=0) is included.
%   'D': means that a deadtime Td~=0 is included
%   'I': means that an integrating process is chosen.
%   'U': means that the model is underdamped: The first two poles are complex.
%
%   The characters  after 'P0', 'P1', 'P2' or 'P3' may appear in any order.
%   Examples of model characterizations are 'P1D', 'P2U', 'P3ZID'.
%   
%   Multi-input single output models are supported. For several inputs,
%   let TYPE be a cell array with an entry for each input: {'P1','P2D'}.
%
%   The properties of IDPROC are the coefficients above: 'Kp', 'Td', 'Tp1',
%   'Tw' etc with a possibility to constrain to min and max values.
%   See IDPROPS IDPROC for exact definitions of these properties.
%   
%   Moreover, any IDMODEL propery can be defined, and also
%
%   DisturbanceModel: Describes a possible additive noise model.
%        'None': Means no noise model is used.
%        'ARMA1': A first order ARMA model us used.
%        'ARMA2': A second order ARMA model is used.
%
%   InitialState: How to deal with initial filter values
%        'Zero': Initial states are fixed to zero
%        'Estimate': Estimate the initial state as extra parameters
%        'Backcast': The initialization is estimated as the best LS fit
%        'Auto': An automatic choice between the above
%
%   InputLevel: How to deal with the levels of the input signals. See
%   IDPROPS IDPROC.
%
%   For more info on IDPROC  properties, type IDPROPS IDPROC.
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/04/10 23:17:09 $

ni = nargin;

if ni & (isa(varargin{1},'ss')|isa(varargin{1},'zpk')|isa(varargin{1},'tf')|...
        (isa(varargin{1},'idmodel')&~isa(varargin{1},'idproc')))
    error('Conversion of general models to idproc not possible.')
end

% Quick exit for idgrey objects
if ni & isa(varargin{1},'idproc'),
    if ni~=1
        error('Use SET to modify the properties of IDPROC objects.');
    end
    sys = varargin{1};
    return
end
try
    superiorto('lti','zpk','ss','tf','frd')
end

superiorto('idpoly')
superiorto('idfrd')
superiorto('iddata')
% Dissect input list
PVstart = min(find(cellfun('isclass',varargin(2:end),'char')))+1;
if isempty(PVstart)
    DoubleInputs = ni;
else
    DoubleInputs = PVstart - 1;
end

if nargin<1
    typec = 'P1D';
else
    typec = varargin{1};
end

if ~iscell(typec),typec={typec};end
nu = length(typec);
for ku = 1:nu
    type = typec{ku};
if ~isa(type,'char')|lower(type(1))~='p'
    error('Type must be a string starting with ''P''.')
end
Type='';
Type(1)='P';
if any(findstr(type,'0'))
    Type(2)='0';
    npar = 1;
elseif any(findstr(type,'1'))
    Type(2)='1';
    npar = 2;
elseif any(findstr(type,'2'))
    Type(2)='2';
    npar = 3;
elseif any(findstr(type,'3'))
    Type(2)='3';
    npar = 4;
else
    error('The second character of Type must be ''0'',''1'', ''2'' or ''3''.')
end
nr=3;
if any(findstr(lower(type),'d'))
    Type(nr) ='D';
    nr = nr+1;
    npar = npar +1;
end
if any(findstr(lower(type),'z'))
    if eval(Type(2))==0
        error('A model zero is not allowed for a zeroth order model.')
    end
    Type(nr) = 'Z';
    nr = nr+1;
    npar = npar +1;
end
if any(findstr(lower(type),'i'))
    Type(nr) = 'I';
    nr = nr+1;
end
if any(findstr(lower(type),'u'))
    if eval(Type(2))<2
        error('Underdamped modes are not possible for 0:th and 1:st order models.')
    end
    Type(nr) = 'U';
    nr = nr+1;
end
Typec{ku}=Type;
end
if length(Typec)==1,Typec=Typec{1};end
[pp{1:10}] = type2pp(Typec);
%pp={1,2,3,4,5,6,7,8};
%sys = struct('Kp',pp{1}..
sys.Kp = pp{1};
sys.Tp1 = pp{2};
sys.Tp2 = pp{3};
sys.Tp3 = pp{4};
sys.Tz = pp{5};
sys.Tw = pp{6};
sys.Zeta = pp{7};
sys.Td = pp{8};
sys.Integration =  pp{9};
sys.InputLevel = pp{10};
par = NaN*ones(npar,1);
[par,type,pnr] = parproc(NaN*ones(8*nu,1),Typec);
aux ={Typec,'zoh','None',[],pnr,[],[],sys.InputLevel};
idparent = idgrey('procmod',par,'cd',aux,0);
sys = class(sys, 'idproc', idparent);
sys = timemark(sys,'c');
% defaults

sys = pvset(sys,'DisturbanceModel','None','InitialState','Auto');

% Finally, set any PV pairs, some of which may be in the parent.
if ~isempty(PVstart)
    try
        set(sys, varargin{PVstart:end})
    catch
        error(lasterr)
    end
end
%sys = setpname(sys);

    