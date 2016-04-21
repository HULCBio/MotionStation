function result = eml_evalin_matlab( cmd, varargin )

% Companion M-FILE called from eml_man to evaluate the eML script in
% MATLAB environment. To this end the following process is followed:
%
%   1- To make use of this functionality you need to have a global var
%      ENABLE_EML_EVALIN_MATLAB.
%
%   1- Input connectivity is examined and direct Constant block sources
%      are evaluated to build input arguments. The values of these
%      arguments are also examined for their type and complexity. This is
%      used to update the data dictionary properties of Simulink input data
%      to the eML block.
%
%   2- An external file is auto created from the eML script. The generated
%      file is comprised of an outer main function calling subfunction whoes
%      body is the actual eML script. The name of external file may be
%      explicitly defined in the block name (e.g. ## File: foo.m ##). This
%      file is overwritten as part of every evaluation. In the absence of
%      an explicit file name, a temporary file is auto created in MATLAB
%      tempdir. This file is deleted after evaluation.
%
%   3- The output result of evaluation is used to update the data
%      dictionary properties of Simulink output data belonging to  the eML
%      block.
%
%   4- The output connectivity to special eML assertion blocksis examined.
%      The expected results for each connected output is propagated to the
%      masked parameterds of associated test blocks

%   E. Mehran Mestchian
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2004/04/22 01:37:26 $

switch cmd
    case 'tol_calc'
        tolPCWIN = varargin{1};
        tolGLNX86 = varargin{2};
        tolSOL2 = varargin{3};
        tolMAC = varargin{4};
        
        switch upper(computer)
            case 'PCWIN'
                result = tolPCWIN;
            case 'GLNX86'
                result = tolGLNX86;
            case 'SOL2'
                result = tolSOL2;
            case 'MAC'
                result = tolMAC;
            otherwise
                result =tolPCWIN;
        end;
        if isempty(result)
            result =tolPCWIN;
        elseif ischar(result)
            result = str2num(result);
        end
        if (length(result)==1)
            result = [result result];
        end
    case 'eval' % called from eml_man.m
        % Check existence of the eML test directory
        DO_EVALIN = sf('Feature','eML evalin MATLAB') ...
            && isequal(exist(fullfile(matlabroot,'test','toolbox','eml')),7);
        if ~DO_EVALIN, return; end
        objectId = varargin{1};
        [mdlH, machineId, chartId] = bdroot_of(objectId);
        if model_is_a_library(mdlH), return; end
        [stdout,evalMode,rebuildAll] = eval_mode(mdlH);
        if isempty(evalMode'), return; end;
        % pass the mdlH, machineId, chardId, objectId, stdout
        called_from_eml_man(mdlH, machineId, chartId, objectId, stdout,evalMode,rebuildAll);
    case 'eMLstop'
        blkH = gcbh;
        mdlH = bdroot(blkH);
        stopTime = get_param(blkH,'stopTime');
        evalinMode = get_param(blkH,'evalinMode');
        if isequal(get_param(blkH,'rebuildAll'),'on')
            rebuildAll = 'RebuildAll';
        else
            rebuildAll = '';
        end
        result = sprintf('STOP at T==%s (s)\neML evalin mode: %s\n%s' ...
            ,stopTime ,evalinMode, rebuildAll);
    case 'icon'
        tol = abs(varargin{1});
        geck = varargin{2};
        if isempty(geck) || isequal(geck,0)
            if isequal(tol(1),tol(2))
                % Just display the double precision tol
                if tol(1)>0 && tol(1)<100*eps
                    if tol(1)<2*eps, result = sprintf('|eML-ML| <= eps');
                    else,            result = sprintf('|eML-ML| <= %g*eps',round(tol(1)/eps));
                    end
                else
                    result = sprintf('|eML-ML| <= %g',tol(1));
                end
            else
                result = sprintf('|eML-ML| <= [ %g, %g]',tol(1),tol(2));
            end
        else
            result = sprintf('|eML-ML| <= Inf (G%g)',geck);
        end
    case 'failure'
        parentBlk = get_param(gcb,'Parent');
        msg = [10,'FAILED "|eML-ML| <= Tol" while expecting valid result(s) from',10, ...
                   '     output: ',get_param(parentBlk,'emlSource'),10];
        [stdout,evalMode] = eval_mode(bdroot(parentBlk));
        switch (evalMode)
            case 'InBaT'
                disp(msg);
            case 'Silent'
                msg = [msg,...
                   '     for more info evaluate:',10,...
                   '         open_system([''',...
                   regexprep(parentBlk,'\n',''',10,''')...
                   '''],''force'')',10];
                disp(msg);
        otherwise
            error(msg);
        end
    otherwise
        error('Invalid cmd.');
    end
return;



function result = called_from_eml_man(mdlH, machineId, chartId, objectId, stdout, evalMode, rebuildAll)
try
    if ~is_eml_chart(chartId), return; end    
    r = sfroot;
    emlChart = r.idToHandle(chartId);
    nameToken = regexp(emlChart.Name,'#\s*\|\s*eML\s*-\s*ML\s*\|\s*(\w+\.m)?\s*#','tokens','once');
    if isempty(nameToken)
        disp(['eML evalin MATLAB: eML Chart ' emlChart.Name ' does not match required naming convention.' 10 ...
           'It will therefore not be considered by eML evalin MATLAB, and may result in errors.' 10 ... 
           'The naming convention is # | eML - ML | optional.m #.' ...
        ]);
        return;
    end

    %%% WISH: EMM - 2/25/03 review the instance code below with Vijay or
    %%%                     Yao
    instance = sf('get',emlChart.Id,'.instances');
    blkH = sf('get',instance(1),'.simulinkBlock');
    blkName = full_script_name(blkH,emlChart);
    %%%%get_param(blkH,'Name'); blkName(find(blkName==10))='_';
    fprintf(stdout,'%s\n',[datestr(now,13),' -- |eML-ML| for "',blkName,'"']);
    done = evalute_in_matlab( emlChart, blkH, stdout, evalMode, nameToken );
    fprintf(stdout,'eML evalin ML %s\n',done);
    if rebuildAll
        switch get_param(mdlH,'SimulationStatus')
            case {'updating','initializing'}
                sfunNameNoExt = [sf('get',machineId,'.name'),'_sfun'];
                sfunName = which([sfunNameNoExt,'.',mexext]);
                if ~isempty(sfunName) && ischar(sfunName)
                    try
                        clear(sfunNameNoExt);
                        sf_delete_file(sfunName);
                        fprintf(stdout,'Deleted %s.\n',sfunName);
                    catch
                        fprintf(stdout,'Failed to delete %s.\n',sfunName);
                    end
                end
            otherwise
        end
    end
catch
    fprintf(stdout,'%s\n',lasterr);
end
return;

%%%%%%%%
function add_eml_lib_paths
emlLibrary = fullfile(matlabroot,'toolbox','eml','lib');
% addpath(fullfile(emlLibrary,'dsp'),'-begin');
% addpath(fullfile(emlLibrary,'matlab'),'-begin');


%%%%%%%%
function [signature, ioPort, callStr] = calling_signature( ioPort, prefixStr )
numOfPorts = length(ioPort);
if numOfPorts == 0
   signature = struct;
   callStr = '';
   return;
end
portNumber = zeros(1,numOfPorts);
for i=1:numOfPorts
    portNumber(ioPort(i).PortNumber) = i;
end
ioPort = ioPort(portNumber); % sorted according to port numbers
signature = struct;
signature.(ioPort(1).Name) = [];
callStr = [prefixStr,ioPort(1).Name];
for i=2:numOfPorts
    signature.(ioPort(i).Name) = [];
    callStr = [callStr,',',prefixStr,ioPort(i).Name];
end
return;

%%%%%%%%
function value = evaluate_src_and_update_input_data( src, blk, input,stdout )
% must be an input connection => extract value of sourced
% constant block otherwise return zero
if ishandle(src) && isequal(get_param(src,'BlockType'),'Constant')
    % input is connected to a Constant block
     value = evalin('base',get_param(src,'Value'),'0');
else
    % input not connected or connected but not driven by a
    % Constant block
    value = 0;
    fprintf(stdout,'%s\n',['              Input "',input.Name,...
            '" is not directly sourced by a Constant block => will default to zero']);
end
% examine the size and complexity of value, and update input data
isComplex = (isreal(value)==0);
if(isComplex ~= input.IsComplex)
    input.IsComplex = isComplex;
end
[m,n]=size(value);
str =  sprintf('[%d,%d]',m,n);
if ~isequal(input.Props.Array.Size,str)
    input.Props.Array.Size = str;
end
if ~isequal(input.Props.Array.FirstIndex,'1')
    input.Props.Array.FirstIndex = '1';
end
str = class(value);
if isequal(str,'logical')
    str = 'boolean';
end
if ~isequal(input.DataType,str)
    input.DataType = str;
end
return;

%%%%%%%%
function done = evalute_in_matlab( emlChart, blk, stdout, evalMode, nameToken)

done = 'failed.';

output = emlChart.Outputs; % find('-isa','Stateflow.Data','Scope','OUTPUT_DATA');
input = emlChart.Inputs; % find('-isa','Stateflow.Data','Scope','INPUT_DATA');


connection = get_param(blk,'PortConnectivity');
[inputSignature, input, inputCallStr] = calling_signature(input,'');
[outputSignature, output, outputCallStr] = calling_signature(output,'out.');

if ~isempty(connection)
    for i=1:length(connection)
        src = connection(i).SrcBlock;
        if ~isempty(src)
            % must be an input connection => extract value of sourced
            % constant block otherwise return zero
            portNumber = sscanf(connection(i).Type,'%d');
            inputSignature.(input(portNumber).Name) = ...
                evaluate_src_and_update_input_data(src,blk, input(portNumber),stdout);
        end
    end
end

inputArg = struct2cell(inputSignature);

% the following checks for an explicit external eML file name
%%%%%%%% WORK NEEDED on evalMode
switch (evalMode)
case {'Verbose','Silent'}
    externalFile = lower(nameToken{1});
otherwise
    externalFile = '';
end

if ~isempty(strfind(pwd,fullfile(matlabroot,'toolbox')))
  fprintf(stdout,...
     ['  Can not create file ''%s'' in a MATLAB toolbox directory.\n', ...
      '  Will use TEMPDIR & a TEMPNAME instead.\n'],...
     externalFile);
  externalFile = '';
end

for i=1:2
    if isempty(externalFile)
        fileName = [tempname,'.m'];
    else
        fileName = externalFile;
    end
    [pathstr,fname] = fileparts(fileName);
    if fname_is_ok(fname)
        break; % out of this for loop
    end
    externalFile = '';
    fprintf(stdout,'Can not feval(''%s''), will try using TEMPNAME.\n',fname);
end
try
    initalDir = pwd;
    initalPath = path;
    
    emlFuncName = sf('get',emlChart.Id,'chart.eml.name');
    if ~isempty(inputCallStr)
        inputCallStr = ['(',inputCallStr,')'];
    end
    if ~isempty(outputCallStr)
        outputCallStr = ['[',outputCallStr,'] = '];
    end
    fullScriptName = full_script_name(blk,emlChart);
    
    headerStr = [ ...
            'function out = ',fname, inputCallStr, 10 ...
            '   % Auto generated on ',datestr(now,0),' from eML script', 10 ...
            '   %    "',fullScriptName,'"', 10 ...
            ,10, ...
            '   out = struct;', 10 ...
            '   ',outputCallStr, emlFuncName, inputCallStr,';', 10 ...
            '   ','return;', 10, 10 ...
        ];
    % creating the external eML file
    f = 0; c = 0;
    f = fopen(fileName,'wt');
    c = fwrite(f,headerStr);
    c = fwrite(f,emlChart.Script);
    fclose(f);f = 0;
    if isempty(externalFile)
        cd(tempdir);
    end
    
    add_eml_lib_paths;

    % FMS: clear is important as it blows away persistent state.
    clear(fname);
    try
    expectedResult = feval_fname(fname,inputArg);
        done ='done.';
    catch
        expectedResult = [];
        fprintf(stdout,'%s\n',lasterr);
    end
    
    if isempty(externalFile)
        sf_delete_file(fileName);
        c = 0;
    end
    cd(initalDir);
    path(initalPath);
catch
    script = '';
    cd(initalDir);
    path(initalPath);
    if f~=0, fclose(f); end
    if c~=0 && isempty(externalFile)
        sf_delete_file(fileName);
    end
    expectedResult = [];
    error(lasterr);
end

% update the output data size and complexity
% also propagate the expected output to any downstream destination
% eML asserrion systems
if isempty(expectedResult)
    out = cell(size(output));
    for i=1:length(output)
        out{i}=NaN;
    end
else
out = struct2cell(expectedResult);
end    
for i=1:length(output)
    % examine the size and complexity of value, and update onput data
    if isempty(out{i}), continue; end
     isComplex = (isreal(out{i})==0);
     if (isComplex ~= output(i).IsComplex)
        output(i).IsComplex = isComplex;
    end
    [m,n]=size(out{i});
    str = sprintf('[%d,%d]',m,n);
    if ~isequal(output(i).Props.Array.Size,str)
        output(i).Props.Array.Size = str;
    end
    if ~isequal(output(i).Props.Array.FirstIndex,'1')
        output(i).Props.Array.FirstIndex = '1';
    end
    str = class(out{i});
    if isequal(str,'logical')
        str = 'boolean';
    end
    if ~isequal(output(i).DataType,str)
        output(i).DataType = str;
    end
end

if ~isempty(connection)    
    for i=1:length(connection)
        src = connection(i).SrcBlock;
        if isempty(src)
            % must be an output connection => examine connectivity to a
            % "|eML-ML| <= Tol" block, and update the corresponding
            % expected values.
            dst = connection(i).DstBlock;
            if ~isempty(dst) && ishandle(dst) ...
                    && isequal(get_param(dst,'MaskType'),'|eML-ML| <= Tol')
                % is connected to a "|eML-ML| <= Tol" block
                portNumber = sscanf(connection(i).Type,'%d');
                if isempty(expectedResult)
                    r = NaN;
                    realStr = 'NaN ';
                else
                r = double(expectedResult.(output(portNumber).Name));
                realStr = num2str(real(r),'%.17g ');
                end
                if ~isreal(r)
                    complexStr = num2str(imag(r),'%.17g ');
                else
                    complexStr = '';
                end
                if size(realStr,1)>1
                    % reshape the string from a multi-row matrix into a row
                    % string matrix instrumented with newline (10) chars
                    realStr(:,end+1) = char(10);
                    realStr = realStr';
                    realStr = realStr(:)';
                    if ~isempty(complexStr)
                        complexStr(:,end+1) = char(10);
                        complexStr = complexStr';
                        complexStr = complexStr(:)';
                    end
                end
                realStr = ['[',realStr,']'];
                if ~isempty(complexStr)
                    complexStr = ['+[',complexStr,']*i'];
                end
                emlSource = sprintf('"%s/%s.%s in eML Script"(#%d)',...
                    regexprep(get_param(blk,'Name'),'\n.*$','...'),...
                    emlFuncName, output(portNumber).Name, emlChart.Id);
                str = [realStr,complexStr];
                if ~isequal(str,get_param(dst,'expected'))
                    set_param(dst,'expected',str);
                end
                if ~isequal(str,get_param(dst,'emlSource'))
                    set_param(dst,'emlSource', emlSource);
                end
                % Precision is now handled via a callback in eml_evalin_matlab_lib.mdl               
            end
        end
    end
end
return

%%%%%%%%
function result = fname_is_ok( fname )
switch exist(fname)
    case {1,3,4,5,6}
        result = 0; % because feval would not pickup <fname>.m
    otherwise
        result = 1;
end
return


%%%%%%%%
function expectedResult = feval_fname(fname, inputArg)
if isempty(inputArg)
    expectedResult = feval(fname);
else
    expectedResult = feval(fname,inputArg{:});
end

%%%%%%%%
function [mdlH,machineId,chartId] = bdroot_of( objectId )
    chartId = sf('get',objectId,'.chart');
    machineId = sf('get',chartId,'.machine');
    mdlH = sf('get',machineId,'.simulinkModel');

%%%%%%%%
function result = model_is_a_library(modelH),
	if strcmp(lower(get_param(modelH,'BlockDiagramType')),'library'), result = 1;
	else, result = 0;
	end;

%%%%%%%%
function [stdout,evalMode,rebuildAll] = eval_mode(mdlH)
%%%%%  stdout = -1 => not defained
%                0 => null display
%                1 => standard out
%
%      evalMode = 0 => normal mode of autobuild
%                 1 => rebuild mode for every eML block

stopBlk = find_system(mdlH, ...
    'SearchDepth',1, ...
    'BlockType','SubSystem', ...
    'MaskType','eML STOP at T==?');

if isempty(stopBlk)
    %%% Could not find an eML Stop Block is not at the root level
    %%% Reutn early
    stdout = [];
    evalMode = [];
    rebuildAll = 0;
    return;
end

if (length(stopBlk)>1)
    warning('Multiple eML STOP blocks at root level. Will continue using first one!');
    stopBlk = stopBlk(1);
end

evalMode = get_param(stopBlk,'evalinMode');
if iscell(evalMode)
    %%% EMM - 2/25/03 Looks like a bug in Simulink!!!
    %%% How come this is a string in all SimulationStatus mode except
    %%% running?
    evalMode = evalMode{1};
end

switch evalMode
    case {'Verbose'}
        stdout = 1;
    otherwise
        stdout = 0;
end
rebuildAll = get_param(stopBlk,'rebuildAll');
if iscell(rebuildAll)
    rebuildAll = rebuildAll{1}; %%% EMM - 2/25/03 Looks like a bug in Simulink!!!
end
switch rebuildAll
    case 'on'
        rebuildAll = 1;
    otherwise
        rebuildAll = 0;
end
%% In case of verbose and rebuildAll check for BaT global overwrite for eML
%% evalin MATLAB
if (rebuildAll==0) && (stdout==0) && ...
    isempty(whos('global','ENABLE_EML_EVALIN_MATLAB'))
    return;
end
global ENABLE_EML_EVALIN_MATLAB
if isequal(ENABLE_EML_EVALIN_MATLAB,'INBAT')
    rebuildAll = 0; % this will be done by the eML BaT test-harness
    stdout = 0; % BaT does not like verbose mode
    evalMode = 'InBaT';
end

%%%%%%%%
function fullScriptName = full_script_name( blk, emlChart )
    fullScriptName = [get_param(bdroot(blk),'Name'),'/',...
            regexprep(emlChart.Name,'\n\s*##.*$','...')];
    fullScriptName = regexprep(fullScriptName,'\n','\\n');
    return;
       
