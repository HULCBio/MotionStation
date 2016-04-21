function realizemdl(Hq,varargin)
%REALIZEMDL Filter realization (Simulink diagram).
%     REALIZEMDL(Hq) automatically generates architecture model of filter
%     Hq in a Simulink subsystem block using individual sum, gain, and
%     delay blocks, according to user-defined specifications.
%
%     REALIZEMDL(Hq, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates
%     the model with parameter/value pairs.
%
%    EXAMPLES:
%    [b,a] = butter(5,.5);
%    Hq = qfilt{'df1',{b,a});
% 
%    %#1 Default syntax:
%    realizemdl(Hq);
% 
%    %#2 Using parameter/value pairs:
%    realizemdl(Hq, 'BlockType', 'Fixed-point blocks', 'OptimizeZeros', 'on');

%    Author(s): Don Orofino, V. Pellissier
%    Copyright 1999-2003 The MathWorks, Inc.
%    $Revision: 1.9.4.3 $  $Date: 2004/04/12 23:26:05 $

% Check if Signal Processing Blokset is installed
if ~(exist('dspblks') == 7),
    error('Could not find Signal Processing Blockset.');
end

w = warning('off');
Hqc = copyobj(Hq); % copy of Hq
warning(w);

% Parse inputs
[hTar, msg] = parse_inputs(Hqc, varargin{:});
if ~isempty(msg), error(msg); end

% Test if format supported by fixed-point blockset and cast if
% necessary
castformat_if_needed(Hqc);

% Clear gains and delays
hTar.gains = [];
hTar.delays = [];

% Create model
specname = hTar.blockname;
pos = createmodel(hTar);

% Add SubSystem
hsubsys = add_block('built-in/subsystem',hTar.system, 'Tag', 'FilterWizardSubSystem');
% Restore position of the block
set_param(hsubsys,'Position', pos);

% Cascade
if nsections(Hqc)>1 & ~issos(Hqc),
    msg = mdlgencascade(Hqc,hTar,'off');
    
else    
    
    % Generate filter architecture
    filtstruct = get(Hqc, 'FilterStructure');
    switch filtstruct,
        
        case {'df1','df2t'},
            if issos(Hqc) & nsections(Hqc)>1,
                msg = mdlgendtf1sos(Hqc,hTar,'off');
            else
                msg = mdlgendtf1(Hqc,hTar,'off');
            end
            
        case {'df2','df1t','fir','firt'}
            if issos(Hqc) & nsections(Hqc)>1,
                msg = mdlgendtf2sos(Hqc,hTar,'off');
            else
                msg = mdlgendtf2(Hqc,hTar,'off');
            end
            
        case {'antisymmetricfir','symmetricfir'}
            if issos(Hqc) & nsections(Hqc)>1,
                error('Structure not supported.');
            end
            msg = mdlgendfsymfir(Hqc,hTar,'off');
            
        case {'latticearma','latticear','latcallpass','latticema','latcmax', 'latticemaxphase', 'latticeallpass'}
            if issos(Hqc) & nsections(Hqc)>1,
                error('Structure not supported.');
            end
            msg = mdlgenlattice(Hqc,hTar,'off');
            
        case {'latticeca','latticecapc'}
            if issos(Hqc) & nsections(Hqc)>1,
                error('Structure not supported.');
            end
            msg = mdlgencoupledallpass(Hqc,hTar,'off');
            
        otherwise
            error('Structure not supported.');
    end
end

if ~isempty(msg),
    delete_block(hTar.system);
    error(msg);
else
    
    if ~strcmpi(specname,hTar.blockname),
        warning('SPBLKS:realizemdl:NameChanged', ['The generated block has been renamed ', hTar.blockname, '.']);
    end
    
    % Refresh connections
    sys = hTar.system;
    oldpos = get_param(sys, 'Position');
    set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
    set_param(sys, 'Position', oldpos);
    
    % Open system
    sys = hTar.system;
    slindex = findstr(sys,'/');
    open_system(sys(1:slindex(end)-1));
end

%------------------------------------------------------------
function [hTar, msg] = parse_inputs(Hq, varargin)

msg ='';
if nargin==1,
    % Create a default parameter object
    hParam = dspfwiz.parameter(Hq);
elseif nargin==2,
    % Use the parameter object passed as input
    hParam = varargin{1};
else
    % Set p-v pairs of the parameter object
    hParam = dspfwiz.parameter(Hq);
    try
        for i=1:2:nargin-2,
            set(hParam, varargin{i}, varargin{i+1})
        end 
    catch
        msg = lasterr;
    end
end

hTar = get(hParam, 'targetObj');


%------------------------------------------------------------
function castformat_if_needed(Hqc)
% Test if format supported by fixed-point blockset and cast if
% necessary

str = {'CoefficientFormat', 'InputFormat', 'OutputFormat', ...
        'MultiplicandFormat', 'ProductFormat', 'SumFormat'};

for i=1:length(str),
    % Get each quantizer of the qfilt Hqc
    q=feval(lower(str{i}), Hqc);
    if strcmpi(mode(q), 'float'),
        % If data type is float, highest precision is [52 10]
        fmt = format(q);
        idx = fmt>[52 10];
        if all(idx) | idx(2),
            % Saturate exponent to 10 bits, change the total number of bits
            % to keep the same range.
            d = fmt(2)-10;
            q.format = [fmt(1)-d min(fmt(2)-d,52)];
            set(Hqc, str{i}, q);
            warning('SPBLKS:realizemdl:FormatChanged', ...
                [str{i}(1:end-6) ' format cast to [' sprintf('%d', fmt(1)-d) ' ' sprintf('%d', min(fmt(2)-d,52)) '].']);
        elseif idx(1), 
            % Saturate total number of bits to 52
            q.format = [52 fmt(2)]; 
            set(Hqc, str{i}, q);
            warning('SPBLKS:realizemdl:FormatChanged', ...
                [str{i}(1:end-6) ' format cast to [52 ' sprintf('%d', fmt(2)) '].']);
        end
    elseif any(strcmpi(mode(q), {'fixed', 'ufixed'})),
        % For fixed-point data types, highest precision is [128 1022]
        fmt = format(q);
        idx = abs(fmt)>[128 1022];
        if all(idx),
            % Cast to highest precision [128 1022]
            if sign(fmt(2))==1,
                q.format = [128 1022];
                warning('SPBLKS:realizemdl:FormatChanged', ...
                    [str{i}(1:end-6) ' format cast to [128 1022].']);
            else
                q.format = [128 -1022];
                warning('SPBLKS:realizemdl:FormatChanged', ...
                    [str{i}(1:end-6) ' format cast to [128 -1022].']);
            end
            set(Hqc, str{i}, q);
        elseif idx(1), 
            % Saturate wordlength to 128 bits, shift fractionlength
            % accordingly to keep the same range.
            d = fmt(1)-128;
            q.format = [128 fmt(2)-d]; 
            set(Hqc, str{i}, q);
            warning('SPBLKS:realizemdl:FormatChanged', ...
                [str{i}(1:end-6) ' format cast to [128 ' sprintf('%d', fmt(2)-d) '].']);
        elseif idx(2), 
            % Saturate scaling to 2^-1022 or 2^1022
            if sign(fmt(2))==1,
                q.format = [fmt(1) 1022]; 
                warning('SPBLKS:realizemdl:FormatChanged', ...
                    [str{i}(1:end-6) ' format cast to [' sprintf('%d', fmt(1)) ' 1022].']);
            else
                q.format = [fmt(1) -1022]; 
                warning('SPBLKS:realizemdl:FormatChanged', ...
                    [str{i}(1:end-6) ' format cast to [' sprintf('%d', fmt(1)) ' -1022].']);
            end
            set(Hqc, str{i}, q);
        end
    end
end

% [EOF]
