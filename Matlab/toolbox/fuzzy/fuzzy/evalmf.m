function y=evalmf(x,params,type)
%EVALMF Evaluate membership function.
%EVALMF Generic membership function evaluation.
%   Synopsis
%   y = evalmf(x,mfParams,mfType)
%   Description
%   evalmf evaluates any membership function, where x is the variable range for
%   the membership function evaluation, mfType is a membership function from
%   the toolbox, and mfParams are appropriate parameters for that function.
%   If you want to create your own custom membership function, evalmf will
%   still work, because it will still evaluate any membership function whose
%   name it doesn’t recognize.
%   Examples
%   x=0:0.1:10;
%   mfparams = [2 4 6];
%   mftype = 'gbellmf';
%   y=evalmf(x,mfparams,mftype);
%   plot(x,y)
%   xlabel('gbellmf, P=[2 4 6]')
%
%   See also DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF,
%   SIGMF, SMF, TRAPMF, TRIMF, ZMF.

%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/14 22:20:05 $
  
if (type == 1) | (strcmp(type,'trimf')),
    y = trimf(x, params);
    return;
elseif (type == 2) | (strcmp(type,'trapmf')),
    y = trapmf(x, params);
    return;
elseif (type == 3) | (strcmp(type,'gaussmf')),
    y = gaussmf(x, params);
    return;
elseif (type == 4) | (strcmp(type,'gauss2mf')),
    y = gauss2mf(x, params);
    return;
elseif (type == 5) | (strcmp(type,'sigmf')),
    y = sigmf(x, params);
    return;
elseif (type == 6) | (strcmp(type,'dsigmf')),
    y = dsigmf(x, params);
    return;
elseif (type == 7) | (strcmp(type,'psigmf')),
    y = psigmf(x, params);
    return;
elseif (type == 8) | (strcmp(type,'gbellmf')),
    y = gbellmf(x, params);
    return;
elseif (type == 9) | (strcmp(type,'smf')),
    y = smf(x, params);
    return;
elseif (type == 10) | (strcmp(type,'zmf')),
    y = zmf(x, params);
    return;
elseif (type == 11) | (strcmp(type,'pimf')),
    y = pimf(x, params);
    return;
else
    % Membership function is unknown
    % We assume it is user-defined and evaluate it here
    evalStr=[type '(x, params)'];
    y = eval(evalStr);
    return;
end
