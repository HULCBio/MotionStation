function msg = mdlgendtf2sos(Hq, hTar, warnflag)
%MDLGENDTF2SOS Simulink filter generator for Direct Form II  Second order
%sections (DF-IISOS), Direct Form I Transposed Second order sections
%(DF-ITSOS) and Direct Form FIR Second order sections (DF-FIRSOS)

%    This should be a private method

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/21 19:19:09 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
g = scalevalues(Hq);

% Form a dfilt
switch filterstructure(Hq),
case 'df2',
    sosmat = cell2sos(coefs);
    Hd = dfilt.df2sos(sosmat,g);
case {'fir','firt'},
    nsections = length(coefs);
    sosmat = zeros(nsections,6);
    sosmat(:,4) = 1;
    for i=1:nsections,
        sect = coefs{i}{1};
        sosmat(i,1:length(sect)) = sect;
    end
    if strcmpi(filterstructure(Hq), 'firt'),
        Hd = dfilt.df1tsos(sosmat,g);
    else
        Hd = dfilt.df2sos(sosmat,g);
    end
case 'df1t',
    sosmat = cell2sos(coefs);
    Hd = dfilt.df1tsos(sosmat,g);
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

% Converts before scalers s(i) (specific to these structures sos)
isinputscaled = 0;
scalblk = find_system(sys, 'Regexp', 'on', 'Name', '^s('); 
offset = [-50 0 -45 0];
decal = [-50 0 -50 0];
if ~isempty(scalblk),
    isinputscaled = 1;
    for i=1:length(scalblk),
        conn = get_param(scalblk{i}, 'PortConnectivity');
        srcblk = conn(1).SrcBlock;
        oldpos = get_param(scalblk{i}, 'Position');
        dspfwizaddconvert(Hq, hTar, oldpos + offset, ['S' sprintf('%d', i)], ...
            'right', scalblk{i}, 'destination', srcblk, decal);
    end
end

% Add Convert blocks before 1|a(1) gain in each section (specific to these structures)
dspfwizdtf2convert(Hq, hTar);

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, 0, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);

% [EOF]
