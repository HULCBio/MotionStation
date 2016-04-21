function fis = fuzblockmask(CB,fis)
%FUZBLOCKMASK  Initialize Mask for Fuzzy block.
%
%  This function is meant to be called by the Fuzzy Block mask.
%
%  See also FUZBLOCK.

%   Authors: P. Gahinet and R. Jang
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.2 $ $Date: 2004/04/10 23:15:25 $

% RE: * Used both for initializing and updating after Apply
%     * The mask variable FISMAT is automatically reevaluated in the 
%       proper workspace when the mask init callback is executed.
Model = bdroot(CB);
Dirty = get_param(Model,'Dirty');
LastWarn = lastwarn;
WarnState = warning('off');

% Get FIS data structure
if ~isempty(fis)
    switch class(fis)
    case 'char'
        % Try reading FIS file
        try
            fis = readfis(fis);
        catch
            LocalError('Invalid FIS file name.')
        end
    case 'double'
        % Try converting FIS matrix to FIS structure
        try 
            fis = convertfis(fis);
        catch
            LocalError('Invalid FIS matrix.')
        end
    case 'struct'
        if ~isfield(fis,'defuzzMethod')
            LocalError('Invalid FIS structure.')
        end
    otherwise
        LocalError('Invalid type for FIS parameter.')
    end
end

% Generate masked subsystem
if ~isempty(fis) & ...
        StandardMF(fis) & ...
        StandardAndMethod(fis) & ...
        StandardOrMethod(fis) & ...
        StandardImpMethod(fis) & ...
        StandardDefuzzMethod(fis) & ...
        StandardAggMethod(fis) & ...
        all([fis.rule.antecedent]>=0);
    % Use Fuzzy wizard to build block diagram representation of FIS (optimal for RTW)
    SFFIS = find_system(CB,'SearchDepth',1,...
        'FollowLinks','on','LookUnderMasks','all','BlockType','S-Function');
    if ~isempty(SFFIS)
        % Replace by FIS Wizard block
        SFFIS = SFFIS{1};
        Position = get_param(SFFIS,'Position');
        delete_block(SFFIS);
        load_system('fuzwiz');
        add_block('fuzwiz/FIS Wizard',sprintf('%s/FIS Wizard',CB),...
            'Position',Position,...
            'MaskValueString','fis');
    end
else
    % Use S-function SFFIS
    FISWIZ = find_system(CB,'SearchDepth',1,...
        'FollowLinks','on','LookUnderMasks','all','MaskType','FIS Wizard');
    if ~isempty(FISWIZ)
        % Replace by FIS Wizard block
        FISWIZ = FISWIZ{1};
        Position = get_param(FISWIZ,'Position');
        delete_block(FISWIZ);
        load_system('fuzwiz')
        add_block('fuzwiz/FIS S-function',sprintf('%s/FIS S-function',CB),...
            'Position',Position);
    end
end

warning(WarnState);
lastwarn(LastWarn);
set_param(Model,'Dirty',Dirty)


%--------------- Local Functions ---------------------------------------

function LocalError(msg)
% Display error messages
errordlg(msg,'Fuzzy Controller Block Error','replace');


function boo = StandardMF(fis)
% Checks if FIS uses built-in MF 
MFList = {'dsigmf','gaussmf','gauss2mf','gbellmf','pimf','psigmf',...
        'smf','sigmf','trapmf','trimf','zmf'};
% Gather input MF types
InputMFTypes = cell(1,0);
for ct=1:length(fis.input)
    if ~isempty(fis.input(ct).mf)
        InputMFTypes = [InputMFTypes , {fis.input(ct).mf.type}];
    end
end
% Gather output MF types
OutputMFTypes = cell(1,0);
for ct=1:length(fis.output)
    if ~isempty(fis.output(ct).mf)
        OutputMFTypes = [OutputMFTypes , {fis.output(ct).mf.type}];
    end
end
% Check if MF are supported in wizard
if strcmpi(fis.type,'sugeno')
    boo = all(ismember(InputMFTypes,MFList)) & all(ismember(OutputMFTypes,{'constant','linear'}));
else
    boo = all(ismember([InputMFTypes,OutputMFTypes],MFList));
end


function boo = StandardAndMethod(fis)
% Checks if FIS uses built-in AND methods
boo = any(strcmp(fis.andMethod, {'min','prod'}));


function boo = StandardOrMethod(fis)
% Checks if FIS uses built-in OR methods
boo = any(strcmp(fis.orMethod, {'max','probor'}));


function boo = StandardImpMethod(fis)
% Checks if FIS uses built-in IMPLY methods
boo = any(strcmp(fis.impMethod, {'min','prod'}));


function boo = StandardDefuzzMethod(fis)
% Checks if FIS uses built-in Defuzzification methods
if strcmpi(fis.type,'sugeno')
    boo = any(strcmpi(fis.defuzzMethod,{'wtsum','wtaver'}));
else
    boo = strcmpi(fis.defuzzMethod,'centroid');
end


function boo = StandardAggMethod(fis)
% Checks if FIS uses built-in Aggregation methods
boo = strcmpi(fis.type,'sugeno') | any(strcmp(fis.aggMethod, {'max','probor','sum'}));
