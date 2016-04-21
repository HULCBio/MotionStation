function view(varargin)
%VIEW  Plot various characteristics of models
%   This routine requires the Control Systems Toolbox, and invokes LTIVIEW.
%   
%   VIEW(Mod)
%
%   Mod is any IDMODEL (IDGREY, IDARX, IDPOLY or IDSS) or an IDFRD model.
%   VIEW gives access to the LTIVIEW function in the CSTB and graphs
%   step responses, impulse responses, bode, nyquist, and nichols plots,
%   as well as poles and zeros.
%
%   No covariance and uncertainty information will be shown. Use the 
%   commands BODE, NYQUIST, STEP, IMPULSE or PZMAP to see confidence
%   intervals.
%
%   For models with a measurable input, only the characteristics of the
%   transfer functions from these inputs to the outputs will be shown.
%   To see the properties of the transfer function from the noise sources
%   to the outputs, use VIEW(m('n')) ('n' for 'noise'). The noise transfer 
%   functions are then first normalized using the NoiseVariance of the
%   model so that the noise sources are white noise with a unit covariance
%   matrix.
%
%   For time-series models (no measured input) the transfer functions from
%   normalized noise sources (see above) are shown.
%
%   Several models are compared by VIEW(Mod1,Mod2,....,ModN). The plot styles
%   (color, marker, linestyle) for the different models can be specified by
%   VIEW(Mod1,'PlotStyle1',Mod2,'PlotStyle2',...,ModN,'PlotStyleN')
%   PlotStyle takes values like 'b', 'b+:', etc. See HELP PLOT.
%   
%   Add as a last argument any string 
%   'step','impulse','bode','nyquist','nichols','sigma','pzmap', or 'iopzmap';
%   to initialize the plot at the corresponding type. A cell array of
%   several (up to 6) of these can also be used for multi-plots.
%
%   VIEW does not support output disturbance spectra for IDFRD models 
%   (obtained by SPA or ETFE)
%
%   VIEW does not cover all the options of LTIVIEW. To utilize the full
%   functionality of LTIVIEW use the Control Toobox command ltiview.  
%   The models will not be required to be converted to lti objects since they
%   can be directly imported.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 22:47:01 $

if ~exist('ltiview')
    error(sprintf(['Using VIEW for idmodels requires the Control System Toolbox',...
            '\nUse BODE, NYQUIST, STEP, IMPULSE, or PZMAP instead.']))
end
ValidStrings = {'step';
    'impulse';
    'bode';
    'nyquist';
    'nichols';
    'sigma';
    'pzmap';
    'lsim';
    'iopzmap';
    'initial';
    'current'; 
    'clear'};

plottype = 'bode';
test = varargin{end};
if ischar(test)
    if any(strcmp(lower(test),ValidStrings))
        plottype = test;
        varargin = varargin(1:end-1);
    end
elseif iscell(test)
    plottype = test;
    varargin = varargin(1:end-1);
end

ltiview(plottype,varargin{:})