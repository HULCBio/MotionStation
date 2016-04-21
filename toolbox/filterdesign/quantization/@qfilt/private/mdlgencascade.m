function msg = mdlgencascade(Hq,hTar,warnflag)
% MDLGENCASCADE Simulink filter generator for cascaded filters.

%    Author(s): Don Orofino, V. Pellissier
%    Copyright 1999-2003 The MathWorks, Inc.
%    $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:25:57 $

error(nargchk(3,3,nargin));

sys = hTar.system;

% Determine horizontal and vertical offset for input:
[x_offset, y_offset] = hvoffset(0);
offset = [x_offset, y_offset, x_offset, y_offset];
p = positions;

% Input:
blk = 'Input';
inport(hTar, blk);
pos = p.input + offset;
set_param([sys '/' blk], 'Position',pos);
last_conn{1,1} = [blk '/1'];

% Sections
qcoefs = quantizedcoefficients(Hq);
for k=1:nsections(Hq),
    
    % Form a qfilt 
    sectcoefs = qcoefs{k};
    filtstruct = get(Hq, 'FilterStructure');
    if length(sectcoefs)>1,
        Hqsect = qfilt(filtstruct, {sectcoefs{1}, sectcoefs{2}});
    else
        Hqsect = qfilt(filtstruct, {sectcoefs{1}});
    end
    
    % Set quantizers
    q = coefficientformat(Hq);
    set(Hqsect, 'CoefficientFormat', q);
    q = inputformat(Hq);
    set(Hqsect, 'InputFormat', q);
    q = outputformat(Hq);
    set(Hqsect, 'OutputFormat', q);
    q = multiplicandformat(Hq);
    set(Hqsect, 'MultiplicandFormat', q);
    q = productformat(Hq);
    set(Hqsect, 'ProductFormat', q);
    q = sumformat(Hq);
    set(Hqsect, 'SumFormat', q);
    
    % Remove intermediate quantizers
    if k>1,
        set(Hqsect, 'InputFormat', quantizer('Mode', 'none'));
    end
    if k<nsections(Hq),
        set(Hqsect, 'OutputFormat', quantizer('Mode', 'none'));
    end

    % Force sys to be the current system
    idx = findstr(sys, '/');
    set_param(0,'CurrentSystem',sys(1:idx(end)-1));

    % Add new subsystem for filter realization:
    section_name = ['Section', sprintf('%d',k)];
    hParamSection = dspfwiz.parameter(Hqsect);
    hTarSection = copy(hTar);
    hTarSection.destination = 'Current';
    idx = findstr(sys, '/');
    if length(idx)==1,
        blockpath = hTar.blockname;
    else
        blockpath = sys(idx(1)+1:end);
    end
    hTarSection.blockname = [blockpath '/' section_name];
    pos = createmodel(hTarSection);
    
    % Add SubSystem
    hsubsys = add_block('built-in/subsystem', hTarSection.system);
    % Restore position of the block
    set_param(hsubsys,'Position', pos);
    subsys = hTarSection.system;

    % Realize this section
    hTarSection.OptimizeZeros = hTar.OptimizeZeros;
    hTarSection.OptimizeOnes = hTar.OptimizeOnes;
    hTarSection.OptimizeNegOnes = hTar.OptimizeNegOnes;
    hTarSection.OptimizeDelayChains = hTar.OptimizeDelayChains;
    
    
    switch filtstruct,
    case {'df1','df2t'},
        msg = mdlgendtf1(Hqsect,hTarSection,warnflag);
    case {'df2','df1t','fir','firt'}
            msg = mdlgendtf2(Hqsect,hTarSection,warnflag);
    case {'antisymmetricfir','symmetricfir'}
        msg = mdlgendfsymfir(Hqsect,hTarSection,warnflag);
    case {'latticearma','latticear','latcallpass','latticema','latcmax'}
        msg = mdlgenlattice(Hqsect,hTarSection,warnflag);
    case {'latticeca','latticecapc'}
        msg = mdlgencoupledallpass(Hqsect,hTarSection,warnflag);
    otherwise
        error('Structure not supported.');
    end
    
    % Determine horizontal and vertical offset for rendering filter stage:
    [x_offset, y_offset] = hvoffset(k);
    offset = [x_offset, y_offset, x_offset, y_offset];
    pos = p.section + offset;
    set_param(subsys,'Position', pos);
    
    % Connect this stage to last stage:
    new_conn{1,1} = [section_name '/1'];
    interstg(hTar, last_conn,new_conn, 12);
    last_conn=new_conn;
    
end

% Determine horizontal and vertical offset for output:
[x_offset, y_offset] = hvoffset(k+1);
offset = [x_offset, y_offset, x_offset, y_offset];

% Output:
blk = 'Output';
outport(hTar, blk);
set_param([sys '/' blk], 'Position', p.output + offset);

% Connect last stage to output:
new_conn{1,1} = [blk '/1'];
interstg(hTar, last_conn,new_conn, 12);


% --------------------------------------------------------------
%                 Utility functions
% --------------------------------------------------------------
function [x_offset, y_offset] = hvoffset(stage)

x_offset = 100*stage;
y_offset = 0;

% --------------------------------------------------------------
function p = positions

p.input     = [90, 52, 120, 67];
p.section   = [65, 40, 140, 80];
p.output    = [80, 52, 110, 67];

% [EOF]
