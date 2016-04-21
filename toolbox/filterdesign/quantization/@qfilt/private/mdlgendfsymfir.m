function msg = mdlgendfsymfir(Hq, hTar, warnflag)
%MDLGENDFSYMFIR Simulink filter generator for Symmetric and Anti-Symmetric FIR.

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.6 $  $Date: 2002/11/21 15:51:11 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
num = coefs{1};
if iscell(num),
    num = num{1};
end

% Form a dfilt
switch filterstructure(Hq),
case 'symmetricfir',
    Hd = dfilt.dfsymfir(num);
case 'antisymmetricfir',
    Hd = dfilt.dfasymfir(num);
end

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
% Add fixed-point specific blocks (GatewayIn, GatewayOut and Convert)

sys = hTar.system;

% Scale filter
dspfwizscalefilter(Hq,hTar);

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, -0.1, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);

% Add Convert blocks before Gain blocks
gainblks = hTar.gains;
% Remove invalid handles
gainblks = gainblks(find(ishandle(gainblks)));
for i=1:length(gainblks),
    pos = get_param(gainblks(i),'Position') + [-25 0 -25 0];
    gain_fullname = [sys '/' get_param(gainblks(i), 'Name')];
    dspfwizaddconvert(Hq, hTar, pos, sprintf('%d', i), ...
        'right', gain_fullname, 'destination', ...
        gain_fullname, [25 0 25 0]);
end

% [EOF]
