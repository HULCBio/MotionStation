function msg = mdlgenlattice(Hq, hTar, warnflag)
%MDLGENLATTICE Simulink filter generator for Lattice ARMA, Lattice AR,
%Lattice AR All-Pass, Lattice MA and Lattice Max-Phase.

%    This should be a private method

%    Author(s): V. Pellissier
%    Copyright 1999-2003 The MathWorks, Inc.
%    $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:25:59 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
K = coefs{1};
if iscell(K),
    coefs = K;
    K = K{1};
end

switch filterstructure(Hq),
case 'latticearma',
    V = coefs{2};
    Hd = dfilt.latticearma(K,V);
case 'latticear',
    V = 1;
    Hd = dfilt.latticearma(K,V);
case {'latcallpass','latticeallpass'},
    Hd = dfilt.latticeallpass(K);
case 'latticema',
    Hd = dfilt.latticemamin(K);
case {'latcmax','latticemaxphase'},
    Hd = dfilt.latticemamax(K);
end

if strcmpi(warnflag, 'on'),
    % Call the dfilt method
    msg = Hd.mdlgen(hTar);
    optimize_mdl(hTar, Hd);
else
    % Call the dfilt method with Hq
    msg = Hd.mdlgen(hTar, Hq);
    optimize_z(hTar, Hq);
    
    % Add fixed-point specific blocks (GatewayIn, GatewayOut, Scalers and Converts) 
    addfxptblocks(Hq,hTar);
    optimize_u(hTar, Hq);
    
end

% --------------------------------------------------------------
function optimize_z(hTar, H)

% Optimize zero gains
if strcmpi(hTar.OptimizeZeros, 'on'),
     hTar.optimizezerogains(H);
end

% Optimise delay chains
if strcmpi(hTar.OptimizeDelayChains, 'on'),
    optimizedelaychains(hTar);
end

% --------------------------------------------------------------
function optimize_u(hTar, H)

% Optimize unity gains
if strcmpi(hTar.OptimizeOnes, 'on'),
     hTar.optimizeonegains(H);
end

% Optimize -1 gains
if strcmpi(hTar.OptimizeNegOnes, 'on'),
     hTar.optimizenegonegains(H);
end

% --------------------------------------------------------------
function addfxptblocks(Hq,hTar)
% Add fixed-point specific blocks (GatewayIn, GatewayOut, Scalers and Converts)

sys = hTar.system;

% Scale filter
dspfwizscalefilter(Hq,hTar);

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, -0.2, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);

% Add Convert blocks before Gain blocks
gainblks = hTar.gains;
gainblks = gainblks(find(ishandle(gainblks))); % Remove invalid handles
for i=1:length(gainblks),
    oldpos = get_param(gainblks(i),'Position');
    gain_fullname = [sys '/' get_param(gainblks(i), 'Name')];
    orient = get_param(gainblks(i),'Orientation');
    if strcmpi(orient, 'left'),
        % Lattice gains: ARMA, AR, All-Pass
        offset = [23,0,28,0];
        decal = [-20 0 -20 0];
    elseif strcmpi(orient, 'right'),
        % Lattice gains: MA, Max-Phase
        offset = [-28,0,-23,0];
        decal = [20 0 20 0];
    else
        % Ladder gains
        offset = [-2,-25,3,-25];
        decal = [0 25 0 25];
    end
    dspfwizaddconvert(Hq, hTar, oldpos + offset, sprintf('%d', i), ...
        orient, gain_fullname, 'destination', ...
        gain_fullname, decal);
end


% [EOF]
