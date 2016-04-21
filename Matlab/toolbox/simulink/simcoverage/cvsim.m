function varargout = cvsim( varargin )
%CVSIM Execute coverage instrumented simulations.
%
%   DATA = CVSIM( TEST ) Execute the cvtest object TEST by starting a 
%   simulation run for the corresponding model.  The results are returned
%   in a cvdata object.
%
%   [DATA,T,X,Y] = CVSIM( TEST ) Save the simulation time vector, T, state 
%   values, X, and output values Y.
%
%   [DATA,T,X,Y] = CVSIM( TEST, TIMESPAN, OPTIONS) Override the default 
%   simulation values.  For more information see SIM
%
%   [DATA1, DATA2, ...] = CVSIM( TEST1, TEST2, ... ) Execute a set of tests
%   and return the results in cvdata objects.
%
%   [DATA1,T,X,Y] = CVSIM( ROOT, LABEL, SETUPCMD) Create and execute a 
%   cvtest object. Refer to CVTEST for a description of ROOT, LABEL, and
%   SETUPCMD.
%
%   See also CVENABLE, CVTEST, SIM

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.17.2.2 $  $Date: 2004/04/15 00:37:01 $


    if check_cv_license==0
        error(['Failed to check out Simulink Verification and Validation license,', ...
               ' required for model coverage']);
    end

    if nargin==0,
        error('CVSIM requires at least one input argument')
    end
    
    varargout = cell(1,nargout);
    
    % Workspace to evaluate the setup commands
    setupWorkspace = 'base';
    
    try,
        if isa(varargin{1},'cvtest')
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Cache the old coverage
            % settings  
            testVar = varargin{1};
            modelH = cv('get',testVar.modelcov,'.handle');

            % Make sure the model is open
            if ~ishandle(modelH)    
                modelName = cv('get',testVar.modelcov,'.name');
                prevError = lasterr;
                try
                    modelH = get_param(modelName,'Handle');
                catch
                    modelH = 0;
                end
                lasterr(prevError);
                if (modelH==0)
                    error(sprintf(['The model %s must be open before a coverage ', ...
                                    'simulation can be executed'],modelName));
                else
                    cv('set',testVar.modelcov,'modelcov.handle',modelH);
                end
            end
            

            prevCovSettings = get_param(modelH,'RecordCoverage');
    
            if nargin == 1,
                %%%%%%%%%%%%%%%%%%%%%%
                % Run a single test
                [testId,modelName,setupCmd] = setup_single_test(varargin{1});
                try
                    evalin(setupWorkspace,setupCmd);
                catch
                    warning(sprintf('Setup command failed: \n%s',lasterr));
                end
                simArgs = {modelName};
                assignin('caller','sIM_cMD_aRGS_fROM_cVSIM',simArgs);                
                try
                    [varargout{2:end}] = evalin('caller','sim(sIM_cMD_aRGS_fROM_cVSIM{:});');
                    evalin('caller','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
                    varargout{1} = cvdata(testId);
                catch
                    warning(sprintf('Simulation failed: %s',lasterr));
                    varargout{1} = [];
                end
                evalin('caller','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
            else
                if isa(varargin{2},'cvtest') 
                    %%%%%%%%%%%%%%%%%%%%%
                    % Check args for a set of tests
                    for i=3:nargin
                        if ~isa(varargin{i},'cvtest'),
                            error(sprintf('Bad input arguement, %d.  This should be a cvtest object',i));
                        end
                    end
                    if(nargout~=nargin)
                        error(['CVSIM requires the same number of input and ouput arguments when\n', ...
                              'running multiple tests']);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%
                    % run the set of tests
                    simArgs = {};
                    for i=1:nargin
                        [testId,modelName,setupCmd] = setup_single_test(varargin{i});
                         try
                            evalin(setupWorkspace,setupCmd);
                         catch
                            warning(sprintf('Setup command failed: \n%s',lasterr));
                         end
    
                        simArgs = {modelName};
                        assignin('caller','sIM_cMD_aRGS_fROM_cVSIM',simArgs);
                        try
                            evalin('caller','sim(sIM_cMD_aRGS_fROM_cVSIM{:});');
                            varargout{i} = cvdata(testId);
                        catch
                            warning(sprintf('Simulation %d failed: %s',i,lasterr));
                            varargout{i} = [];
                        end
                    end
                    evalin('caller','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
                else
                    %%%%%%%%%%%%%%%%%%%%%%
                    % Extra args are for sim
                    [testId,modelName,setupCmd] = setup_single_test(varargin{1});
                    try
                        evalin(setupWorkspace,setupCmd);
                    catch
                        warning(sprintf('Setup command failed: \n%s',lasterr));
                    end
                    simArgs = {modelName,varargin{2:end}};
                    assignin('caller','sIM_cMD_aRGS_fROM_cVSIM',simArgs);
                    try
            			[varargout{2:end}] = evalin('caller','sim(sIM_cMD_aRGS_fROM_cVSIM{:});');
                        evalin('caller','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
                        varargout{1} = cvdata(testId);
                    catch
                        warning(sprintf('Simulation failed: %s',lasterr));
                        varargout{1} = [];
                    end
                end
            end
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % Arguments are for test
            % creation
            testVar = cvtest(varargin{:});
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Cache the old coverage
            % settings  
            modelH = cv('get',testVar.modelcov,'.handle');
            prevCovSettings = get_param(modelH,'RecordCoverage');
    
            [testId,modelName,setupCmd] = setup_single_test(testVar);
            try
                evalin(setupWorkspace,setupCmd);
            catch
                warning(sprintf('Setup command failed: \n%s',lasterr));
            end
            simArgs = {modelName};
            assignin('caller','sIM_cMD_aRGS_fROM_cVSIM',simArgs);
            [varargout{2:end}] = evalin('caller','sim(sIM_cMD_aRGS_fROM_cVSIM{:});');
            evalin('caller','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
            varargout{1} = cvdata(testId);
        end

    catch,

        if evalin('caller','exist(''sIM_cMD_aRGS_fROM_cVSIM'')==1')
            evalin('caller','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
        end

        %%%%%%%%%%%%%%%%%%%%
        % Restore old coverage 
        % settings
        set_param(modelH,'RecordCoverage',prevCovSettings);

        error(lasterr);
    end

    %%%%%%%%%%%%%%%%%%%%
    % Restore old coverage 
    % settings
    set_param(modelH,'RecordCoverage',prevCovSettings);


function [testId,modelName,setupCmd] = setup_single_test(testVar)

     testId = testVar.id;
     modelcovId = testVar.modelcov;
     modelH = cv('get',modelcovId,'.handle');
     modelName = get_param(modelH,'Name');
     
    if(modelH==0)
        try
            modelH = get_param(cv('get',modelcovId,'.name'),'Handle');
            modelName = get_param(modelH,'Name');
        catch
            error('Model is not open');
        end
    end

     % Turn on coverage for the model
     set_param(modelH,'RecordCoverage','on');
    
     % Make this the activeTest
     cv('set',modelcovId,'.activeTest',testId);
    
     % Remove this test from pending test link list
     if cv('get',testId,'.linkNode.parent')==modelcovId,
         cv('PendingTestRemove',modelcovId,testId);
     end
    
     % Execute the setup command
     setupCmd = cv('get',testId,'.mlSetupCmd');
    


