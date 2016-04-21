function ios = getlinio(model);
%GETLINIO Get linearization I/O settings for Simulink model.
%
%   IO = GETLINIO('sysl) Finds all linearization annotations in a Simulink
%   model, 'sys'.  The vector of objects returned from this function call 
%   has an entry for each linearization annotation in a model.  
%
%   Usage:
%   1. Right click on the lines of a Simulink model to specify linearization
%      I/O points including loop openings.
%   2. At the command line run the function:
%      >> io = getlinio('f14')
%   3. A formatted display of the linearization I/Os can be obtained by the
%      following syntax
%      >> io
%
%       Linearization IOs: 
%   --------------------------
%   Block f14/u, Port 1 is marked with the following properties:
%    - No Loop Opening
%    - An Input Perturbation
%    
%   Block f14/Gain5, Port 1 is marked with the following properties:
%    - An Output Measurement
%    - No Loop Opening
%
%   4. There is the ability to adjust the linearization points by setting object
%      properties.
%      >> set(io(1),'Type','out');
%
%   I/O Object properties:
%
%   Active ('on','off')   - Flag to set if this I/O will be used for 
%                           linearization.
%   Block  (string)       - The block that this I/O is referenced.
%   OpenLoop ('on','off') - Flag to set if this I/O has a loop opening.
%   PortNumber (int)      - The output port that this I/O is referenced.
%   Type                  - Sets the linearization I/O type. See the
%                           available types below.
%   Description           - String description of the I/O object
%       
%   Available linearization I/O types are: 
%       'in', linearization input point 
%       'out', linearization output point 
%       'inout', linearization input then output point 
%       'outin', linearization output then input point 
%       'none', no linearization input/output point 
%
%   You can edit this I/O object to change its properties. Alternatively, 
%   you can change the properties of io using the set function. To upload 
%   an edited I/O object to the Simulink model diagram, use the SETLINIO 
%   function. Use I/O objects with the function linearize to create linear 
%   models.
%
%   See also LINIO, SETLINIO

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:35:10 $

%% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
    preloaded = 0;
    load_system(model);
else
    preloaded = 1;
end

%% Find systems with linear analysis inputs
in = find_system(model,'findall','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','on',...
        'LinearAnalysisOutput','off');

%% Find systems with linear analysis outputs
out = find_system(model,'findall','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','off',...
        'LinearAnalysisOutput','on');

%% Find systems with linear analysis inputs then outputs
inout = find_system(model,'findall','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','on',...
        'LinearAnalysisOutput','on',...
        'LinearAnalysisLinearizeOrder','off');
    
%% Find systems with linear analysis outputs then inputs
outin = find_system(model,'findall','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisInput','on',...
        'LinearAnalysisOutput','on',...
        'LinearAnalysisLinearizeOrder','on');

%% Find systems with linear analysis open loop properties
openloop = find_system(model,'findall','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'LinearAnalysisOpenLoop','on',...
        'LinearAnalysisInput','off',...
        'LinearAnalysisOutput','off');
    
% Construct the linearization object
h = LinearizationObjects.LinearizationIO; 
ios = [];

for ct = 1:size(in,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(ct),...
        'Block',regexprep(get_param(in(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(in(ct),'PortNumber'),...
        'Type','in',...
        'OpenLoop',get_param(in(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(out,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(out(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(out(ct),'PortNumber'),...
        'Type','out',...
        'OpenLoop',get_param(out(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(inout,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(inout(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(inout(ct),'PortNumber'),...
        'Type','inout',...
        'OpenLoop',get_param(inout(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(outin,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(outin(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(outin(ct),'PortNumber'),...
        'Type','outin',...
        'OpenLoop',get_param(outin(ct),'LinearAnalysisOpenLoop'));
end

for ct = 1:size(openloop,1)
    ios =  [ios;h.copy];
    % Remove the new line and carriage returns in the model/block name
    set(ios(end),...
        'Block',regexprep(get_param(openloop(ct),'Parent'),'\n',' '),...
        'PortNumber',get_param(openloop(ct),'PortNumber'),...
        'Type','none',...
        'OpenLoop','on');
end

%% Close the system if it has not been loaded.
if ~preloaded
    close_system(model);
end