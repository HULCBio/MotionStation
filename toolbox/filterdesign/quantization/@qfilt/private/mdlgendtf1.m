function msg = mdlgendtf1(Hq, hTar, warnflag)
%MDLGENDTF1 Simulink filter generator for Direct Form I (DF-I) and Direct
%Form II Transposed (DF-IIT)

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.5 $  $Date: 2002/11/21 15:51:08 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
num = coefs{1};
if iscell(num),
    coefs = num;
    num = num{1};
end
den = coefs{2};
% Form a dfilt df1 or df2t
Hd = dfilt.(filterstructure(Hq))(num,den);

if strcmpi(warnflag, 'on'),
    % Call the dfilt method
    msg = Hd.mdlgen(hTar);
    optimize_mdl(hTar, Hd);
else
    % Call the dfilt method with Hq
    msg = Hd.mdlgen(hTar, Hq);
    optimize_mdl(hTar, Hq);
    
    % Add fixed-point specific blocks (GatewayIn, GatewayOut and Convert)
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

sys = hTar.system;

% Scale filter
dspfwizscalefilter(Hq,hTar);

% Add Convert blocks before 1|a(1) gain (specific to these structures)
dspfwizdtf1convert(Hq, hTar);

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, -0.2, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);

% [EOF]
