function varargout = cpmmodparams(mode,modeParams,L,N)
%*********************************************************************
% Function Name:    cpmmodparams
% Description:      Define the modulation pulse shapes
% Inputs:           Mode, mode specific parameters, pulse length
%                   Samples per symbol
% Return Values:    Parameter structure containing:
%                   ecode (0 = no error, 1 = error, 2 = warning)
%                   emsg
%                   params
%********************************************************************

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/03/24 02:03:11 $

%   Generation of g (frequency transition pulse shape).
%   g is generated so that it compensates for the error that results from
%   integration of samples (as compared to integration of a continuous fcn)
%   for low values of N, the closed form for g is evaluated for all values on
%   a fine time line.  These values are collected into groups of R_up and
%   averaged, creating a warped version of g, g_warp, that, when integrated,
%   creates a q that is within about 0.01% of the correct value for q (using a
%   min_oversample value of 64.

min_os_ratio = 64;
R_up = ceil(min_os_ratio/N); % Upsampling ratio for pulse shape estimation
TSym = 1;                % Notional symbol period
Ts   = TSym/(N*R_up);    % Notional oversampling period
Offset = Ts/2;           % = Ts/2 (Trapezoidal integration rule)

% fine-grained time index for generating g to create
t = (Offset:Ts:L*TSym-Ts+Offset)';

ecode = 0;
emsg  = '';
% --- Define the phase transitions
switch upper(mode)
case 'LRC'
    g = (1/(2*L*TSym))*(1 - cos(2*pi*t/(L*TSym)));
    q = Ts*cumsum(g);

case 'TFM'
    t = t - TSym*(L/2); % Offset to pulse centre
    g = (g0(t-TSym,TSym) + 2*g0(t,TSym) + g0(t+TSym,TSym))/8;
    q = Ts*cumsum(g);
    g = g * 0.5/q(end); % Normalise so that the total phase transition is 0.5

case 'LSRC'
    Lmain = modeParams.mainLobePulseLength;
    beta = modeParams.beta;
    t = t - TSym*(L/2); % Offset to pulse centre
    t(find(t==0))=eps;
    denom = Lmain * TSym;
    g = (1/denom)*(sin(2*pi*t/denom)./(2*pi*t/denom)) .* cos(beta*2*pi*t/denom)./(1 - (4*beta*t/denom).^2);
    q = Ts*cumsum(g);
    g = g * 0.5/q(end); % Normalise so that the total phase transition is 0.5

case 'GMSK'
    Bb = modeParams.BT;
    K = 2*pi*Bb/sqrt(log(2));
    t = t - TSym*(L/2); % Offset to pulse centre
    g = (1/(2*TSym))*(qfun(K*(t-TSym/2)) - qfun(K*(t+TSym/2)));
    q = Ts*cumsum(g);
    g = g * 0.5/q(end); % Normalise so that the total phase transition is 0.5

case 'LREC'
    g = ones(size(t))/(2*L*TSym);
    q = Ts*cumsum(g);

otherwise
    emsg  = 'Unknown mode.';
    ecode = 1;
    g = [];
    q = [];
end;

% --- Assign these to a structure (scale so that sum(params.g) = Ts*sum(g) = 0.5 )
g_warp = mean(reshape(g,R_up,size(g,1)*size(g,2)/R_up),1)';
params.g = Ts*R_up*g_warp;
params.q = Ts*R_up*q(R_up:R_up:end);

% --- Return the required values
varargout{1} = ecode;
varargout{2} = emsg;
varargout{3} = params;

return;

%*********************************************************************
% Function Name:    g = g0(t,TSym)
% Description:      TFM fundamental frequency shape
% Inputs:           time vector, symbol period
% Return Values:    g
%********************************************************************
function g = g0(t,TSym)
    t(find(t==0))=eps;
    arg = pi*t/TSym;
    g   = (1/TSym)*((sin(arg)./arg) - (((pi^2)./(24*arg.^3)) .* (2*sin(arg) - 2*arg.*cos(arg) - (arg.^2).*sin(arg))));
return;

%*********************************************************************
% Function Name:    y=qfun(t)
% Description:      Gaussian tail function
% Inputs:           x
% Return Values:    q(x)
%********************************************************************
function y=qfun(t)
    y = 0.5*(1-erf(t/sqrt(2)));
return;

