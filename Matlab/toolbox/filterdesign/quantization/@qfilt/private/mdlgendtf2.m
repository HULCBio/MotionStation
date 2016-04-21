function msg = mdlgendtf2(Hq, hTar, warnflag)
%MDLGENDTF2 Simulink filter generator for Direct Form II (DF-II), Direct
%Form I transposed (DF-IT) and direct form FIR (DF-FIR)

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.5 $  $Date: 2002/11/21 15:51:09 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
num = coefs{1};
if iscell(num),
    coefs = num;
    num = num{1};
end
den = 1;
if length(coefs)>1,
    den = coefs{2};
end

% Form a dfilt
switch filterstructure(Hq),
case {'df2', 'fir'},
    Hd = dfilt.df2(num,den);
case {'df1t', 'firt'},
    Hd = dfilt.df1t(num,den);
end

if strcmpi(warnflag, 'on'),
    % Call the dfilt method
    msg = Hd.mdlgen(hTar);
    optimize_mdl(hTar, Hd);
else
    % Call the dfilt method with Hq
    msg = Hd.mdlgen(hTar, Hq);
    optimize_mdl(hTar, Hq);
    
    % Add fixed-point specific blocks (GatewayIn, GatewayOut, Scalers and Converts)
    addfxptblocks(Hq,hTar);
end

% --------------------------------------------------------------
function optimize_mdl(hTar, H)

% Optimize zero gains
if strcmpi(hTar.OptimizeZeros, 'on'),
     hTar.optimizezerogains(H);
end

% Optimize unity gains
if strcmpi(hTar.OptimizeOnes, 'on'),
     hTar.optimizeonegains(H);
end

% Optimize -1 gains
if strcmpi(hTar.OptimizeNegOnes, 'on'),
     hTar.optimizenegonegains(H);
end

% Optimise delay chains
if strcmpi(hTar.OptimizeDelayChains, 'on'),
    optimizedelaychains(hTar);
end


% --------------------------------------------------------------
function addfxptblocks(Hq,hTar)
% Add fixed-point specific blocks (GatewayIn, GatewayOut, Scalers and Converts)

sys = hTar.system;

% Scale filter
dspfwizscalefilter(Hq,hTar);

% Add the Convert block specific to these structures (before 1|a(1) gain)
dspfwizdtf2convert(Hq, hTar);

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, -0.1, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);

% [EOF]
