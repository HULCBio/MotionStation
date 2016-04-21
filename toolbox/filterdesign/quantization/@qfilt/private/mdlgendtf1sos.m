function msg = mdlgendf1sos(Hq, hTar, warnflag)
%MDLGENDF1SOS Simulink filter generator for Direct Form I Second order
%sections (DF-ISOS) and Direct Form II Transposed Second order
%sections(DF-IITSOS)

%    Author(s): V. Pellissier
%    Copyright 1999-2003 The MathWorks, Inc.
%    $Revision: 1.5.4.2 $  $Date: 2004/04/12 23:25:58 $

error(nargchk(3,3,nargin));

coefs = quantizedcoefficients(Hq);
sosmat = cell2sos(coefs);
g = scalevalues(Hq);

% Form a dfilt
switch filterstructure(Hq),
case 'df1',
    Hd = dfilt.df1sos(sosmat,g);
case 'df2t',
    Hd = dfilt.df2tsos(sosmat,g);
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

% Convert before scalers s(1) (specific to these structures sos)
scalblk = find_system(sys, 'Name', 's(1)'); 
offset = [-50 0 -45 0];
decal = [-50 0 -50 0];
if ~isempty(scalblk),
        conn = get_param(scalblk{1}, 'PortConnectivity');
        srcblk = conn(1).SrcBlock;
        oldpos = get_param(scalblk{1}, 'Position');
        dspfwizaddconvert(Hq, hTar, oldpos + offset, ['S' sprintf('%d', 1i)], ...
            'right', scalblk{1}, 'destination', srcblk, decal);
end

% Converts after scalers s(i) (specific to these structures sos)
scalblk = find_system(sys, 'Regexp', 'on', 'Name', '^s(');
if any(strcmpi(scalblk,['s(',num2str(nsections(Hq)+1),')'])),
    scalblk(end)=[];
end
offset = [0 0 5 0];
decal = [-50 0 -50 0];
if ~isempty(scalblk),
    for i=1:length(scalblk),
        conn = get_param(scalblk{i}, 'PortConnectivity');
        srcblk = conn(1).SrcBlock;
        set_param(srcblk, 'Position', get_param(srcblk, 'Position') + decal);
        oldpos = get_param(scalblk{i}, 'Position');
        dspfwizaddconvert(Hq, hTar, oldpos + offset, ['S' sprintf('%d', i)], ...
            'right', scalblk{i}, 'source', scalblk{i}, decal);
    end
end

% Add Convert blocks before 1|a(1) gain in each section (specific to these structures)
dspfwizdtf1convert(Hq, hTar);

% Add a Convert block followed by a GatewayOut block before Output block
dspfwizaddgatewayout(Hq, hTar, -0.2, 'convert');

% Add a GatewayIn after Input block
dspfwizaddgatewayin(Hq, hTar);


% [EOF]
