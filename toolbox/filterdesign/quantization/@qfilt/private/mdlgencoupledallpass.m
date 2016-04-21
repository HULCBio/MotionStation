function msg = mdlgencoupledallpass(Hq, hTar, warnflag)
%MDLGENCOUPLEDALLPASS Simulink filter generator for coupled allpass lattice.

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.5 $  $Date: 2002/11/21 15:51:14 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
K1 = coefs{1};
if iscell(K1),
    coefs = K1;
    K1 = K1{1};
end
K2 = coefs{2};

% Form a dfilt
switch filterstructure(Hq),
case 'latticeca',
    Hd = dfilt.calattice(K1,K2);
case 'latticecapc',
    Hd = dfilt.calatticepc(K1,K2);
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

% Add a Convert after Input block if filter not scaled
scalblk = find_system(sys, 'Name', 'ConvertS1'); 
if isempty(scalblk),
    inblk = find_system(sys, 'BlockType', 'Inport');
    oldpos = get_param(inblk{1}, 'Position');
    offset = [10 -7 10 8];
    dspfwizaddconvert(Hq, hTar, oldpos + offset, 'In', 'right', inblk{1}, 'source', inblk{1}, [-50 0 -50 0]);
end

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, -0.2, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);

% Add Convert blocks before Gain blocks
gainblks = hTar.gains;
% Remove invalid handles
gainblks = gainblks(find(ishandle(gainblks)));
N = length(gainblks)-3;
for i=1:N,
    oldpos = get_param(gainblks(i),'Position');
    gain_fullname = [sys '/' get_param(gainblks(i), 'Name')];
    % Lattice gains
    dspfwizaddconvert(Hq, hTar, oldpos + [23,5,28,-5], sprintf('%d', i), ...
        'left', gain_fullname, 'destination', ...
        gain_fullname, [-20 0 -20 0]);
end

% Last two convert blocks for 'beta' and 'conj(beta)' gains
for i=N+2:N+3,
    oldpos = get_param(gainblks(i),'Position');
    gain_fullname = [sys '/' get_param(gainblks(i), 'Name')];
    % Lattice gains
    dspfwizaddconvert(Hq, hTar, oldpos + [-23,5,-23,-5], sprintf('%d', i), ...
        'right', gain_fullname, 'destination', ...
        gain_fullname, [35 0 35 0]);
end

% [EOF]
