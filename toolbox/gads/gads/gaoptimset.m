
function options = gaoptimset(varargin)
%GAOPTIMSET Create a genetic algorithm options structure.
%
%   GAOPTIMSET returns a listing of the fields in the options structure as
%   well as valid parameters and the default parameter.
%   
%   OPTIONS = GAOPTIMSET('PARAM',VALUE) creates a structure with the
%   default parameters used for all PARAM not specified, and will use the
%   passed argument VALUE for the specified PARAM.
%
%   OPTIONS = GAOPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,....) will create a
%   structure with the default parameters used for all fields not specified.
%   Those FIELDS specified will be assigned the corresponding VALUE passed,
%   PARAM and VALUE should be passed as pairs.
%
%   OPTIONS = GAOPTIMSET(OLDOPTS,'PARAM',VALUE) will create a structure named 
%   OPTIONS.  OPTIONS is created by altering the PARAM specified of OLDOPTS to
%   become the VALUE passed.  
%
%   OPTIONS = GAOPTIMSET(OLDOPTS,'PARAM1',VALUE1,'PARAM2',VALUE2,...) will
%   reassign those fields in OLDOPTS specified by PARAM1, PARAM2, ... to 
%   VALUE1, VALUE2, ...
%
%GAOPTIMSET PARAMETERS
%   
%   PopulationType      - The type of Population being entered
%                       [ 'bitstring' | 'custom' | {'doubleVector'} ]
%   PopInitRange        - Initial range of values a population may have
%                       [ Matrix  | {[0;1]} ]
%   PopulationSize      - Positive scalar indicating the number of individuals
%                       [ positive scalar | {20} ]
%   EliteCount          - Number of best individuals that survive to next 
%                         generation without any change
%                       [ positive scalar | {2} ]
%   CrossoverFraction   - The fraction of genes swapped between individuals
%                       [ positive scalar | {0.8} ]
%   MigrationDirection  - Direction that fittest individuals from the various
%                         sub-populations may migrate to other sub-populations
%                       ['both' | {'forward'}]  
%   MigrationInterval   - The number of generations between the migration of
%                         the fittest individuals to other sub-populations
%                       [ positive scalar | {20} ]
%   MigrationFraction   - Fraction of those individuals scoring the best
%                         that will migrate
%                       [ positive scalar | {0.2} ]
%   Generations         - Number of generations to be simulated
%                       [ positive scalar | {100} ]
%   TimeLimit           - The total time (in seconds) allowed for simulation
%                       [ positive scalar | {INF} ]
%   FitnessLimit        - The lowest allowed score
%                       [ scalar | {-Inf} ]
%   StallGenLimit       - If after this number of generations there is
%                         no improvement, the simulation will end
%                       [ positive scalar | {50} ]
%   StallTimeLimit      - If after this many seconds there is no improvement,
%                         the simulation will end
%                       [ positive scalar | {20} ]
%   InitialPopulation   - The initial population used in seeding the GA
%                         algorithm
%                       [ Matrix | {[]} ]
%   InitialScores       - The initial scores used to determine fitness; used
%                         in seeding the GA algorithm
%                       [ column vector | {[]} ]
%                       [ positive scalar | {1} ]
%   CreationFcn         - Function used to generate initial population
%                       [ {@gacreationuniform} ]
%   FitnessScalingFcn   - Function used to scale fitness scores.
%                       [ @fitscalingshiftlinear | @fitscalingprop | @fitscalingtop |
%                         {@fitscalingrank} ]
%   SelectionFcn        - Function used in selecting parents for next generation
%                       [ @selectionremainder | @selectionrandom | 
%                         @selectionroulette  |  @selectiontournament | 
%                         {@selectionstochunif} ]
%   CrossoverFcn        - Function used to do crossover
%                       [ @crossoverheuristic | @crossoverintermediate | 
%                         @crossoversinglepoint | @crossovertwopoint | 
%                         {@crossoverscattered} ]
%   MutationFcn         - Function used in mutating genes
%                       [ @mutationuniform | {@mutationgaussian} ]
%   HybridFcn           - Another optimization function to be used once GA 
%                         has normally terminated (for whatever reason)
%                       [ @fminsearch | @patternsearch | @fminunc | {[]} ]
%   Display              - Level of display 
%                       [ 'off' | 'iter' | 'diagnose' | {'final'} ]
%   OutputFcns          - Function(s) called in every generation. This is more   
%                         general than PlotFcns.
%                       [ @gaoutputgen | {[]} ]
%   PlotFcns            - Function(s) used in plotting various quantities 
%                         during simulation
%                       [ @gaplotbestf | @gaplotbestindiv | @gaplotdistance | 
%                         @gaplotexpectation | @gaplotgeneology | @gaplotselection |
%                         @gaplotrange | @gaplotscorediversity  | @gaplotscores | 
%                         @gaplotstopping | {[]} ]
%   PlotInterval        - The number of generations between plotting results
%                       [ positive scalar | {1} ]
%   Vectorized           - Objective function is vectorized and it can evaluate
%                         more than one point in one call 
%                       [ 'on' | {'off'} ]

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.5.6.2 $  $Date: 2004/03/09 16:15:35 $

if (nargin == 0) && (nargout == 0)
    fprintf('          PopulationType: [ ''bitstring''      | ''custom''    | {''doubleVector''} ]\n');
    fprintf('            PopInitRange: [ matrix           | {[0;1]} ]\n');
    fprintf('          PopulationSize: [ positive scalar  | {20} ]\n');
    fprintf('              EliteCount: [ positive scalar  | {2} ]\n');
    fprintf('       CrossoverFraction: [ positive scalar  | {0.8} ]\n\n');
    
    fprintf('      MigrationDirection: [ ''both''           | {''forward''} ]\n');
    fprintf('       MigrationInterval: [ positive scalar  | {20} ]\n');
    fprintf('       MigrationFraction: [ positive scalar  | {0.2} ]\n\n');
    
    fprintf('             Generations: [ positive scalar  | {100} ]\n');
    fprintf('               TimeLimit: [ positive scalar  | {Inf} ]\n');
    fprintf('            FitnessLimit: [ scalar           | {-Inf} ]\n\n');
    fprintf('           StallGenLimit: [ positive scalar  | {50} ]\n');
    fprintf('          StallTimeLimit: [ positive scalar  | {20} ]\n');
    
    fprintf('       InitialPopulation: [ matrix           | {[]} ]\n');
    fprintf('           InitialScores: [ column vector    | {[]} ]\n\n');
    
    fprintf('             CreationFcn: [ function_handle  | {@gacreationuniform} ]\n');
    fprintf('       FitnessScalingFcn: [ function_handle  | @fitscalingshiftlinear  | @fitscalingprop  | \n');
    fprintf('                            @fitscalingtop   | {@fitscalingrank} ]\n');
    fprintf('            SelectionFcn: [ function_handle  | @selectionremainder    | @selectionrandom | \n');
    fprintf('                            @selectionroulette | @selectiontournament   | {@selectionstochunif} ]\n');
    fprintf('            CrossoverFcn: [ function_handle  | @crossoverheuristic  | @crossoverintermediate | \n'); 
    fprintf('                            @crossoversinglepoint | @crossovertwopoint | {@crossoverscattered} ]\n');
    fprintf('             MutationFcn: [ function_handle  | @mutationuniform | {@mutationgaussian} ]\n');
    fprintf('               HybridFcn: [ @fminsearch | @patternsearch | @fminunc | {[]} ]\n\n');
    
    fprintf('                 Display: [ off | iter | diagnose | {final} ]\n');
    fprintf('              OutputFcns: [ function_handle  | @gaoutputgen | {[]} ]\n');
    fprintf('                PlotFcns: [ function_handle  | @gaplotbestf | @gaplotbestindiv | @gaplotdistance | \n');
    fprintf('                            @gaplotexpectation | @gaplotgeneology | @gaplotselection | @gaplotrange | \n');
    fprintf('                            @gaplotscorediversity  | @gaplotscores | @gaplotstopping  | {[]} ]\n');
    fprintf('            PlotInterval: [ positive scalar  | {1} ]\n\n');
        
    fprintf('              Vectorized: [ ''on''  | {''off''} ]\n');
    return; 
end     

numberargs = nargin; 

%Return options with default values and return it when called with one output argument
options=struct('PopulationType', 'doubleVector', ...
               'PopInitRange', [0;1], ...
               'PopulationSize', 20, ...
               'EliteCount', 2, ...
               'CrossoverFraction', 0.8, ...
               'MigrationDirection','forward', ...
               'MigrationInterval',20, ...
               'MigrationFraction',0.2, ...
               'Generations', 100, ...
               'TimeLimit', inf, ...
               'FitnessLimit', -inf, ...
               'StallGenLimit', 50, ...
               'StallTimeLimit', 20, ...
               'InitialPopulation',[], ...
               'InitialScores', [], ...
               'PlotInterval',1, ...
               'CreationFcn',@gacreationuniform, ...
               'FitnessScalingFcn', @fitscalingrank, ...
               'SelectionFcn', @selectionstochunif, ...
               'CrossoverFcn',@crossoverscattered, ...
               'MutationFcn',@mutationgaussian, ...
               'HybridFcn',[], ...
               'Display', 'final', ...
               'PlotFcns', [], ...
               'OutputFcns', [], ...
               'Vectorized','off');   


% If we pass in a function name then return the defaults.
if (numberargs==1) && (ischar(varargin{1}) || isa(varargin{1},'function_handle') )
    if ischar(varargin{1})
        funcname = lower(varargin{1});
        if ~exist(funcname)
            msg = sprintf( ...
                'No default options available: the function ''%s'' does not exist on the path.',funcname);
            error('gads:GAOPTIMSET:functionNotFound',msg)
        end
    elseif isa(varargin{1},'function_handle')
        funcname = func2str(varargin{1});
    end
    try 
        optionsfcn = feval(varargin{1},'defaults');
    catch
        msg = sprintf( ...
            'No default options available for the function ''%s''.',funcname);
        error('gads:GAOPTIMSET:noDefaultOptions',msg)
    end
    % To get output, run the rest of psoptimset as if called with gaoptimset(options, optionsfcn)
    varargin{1} = options;
    varargin{2} = optionsfcn;
    numberargs = 2;
end

Names = fieldnames(options);
m = size(Names,1);
names = lower(Names);

i = 1;
while i <= numberargs
    arg = varargin{i};
    if ischar(arg)                         % arg is an option name
        break;
    end
    if ~isempty(arg)                      % [] is a valid options argument
        if ~isa(arg,'struct')
            error('gads:GAOPTIMSET:invalidArgument',['Expected argument %d to be a string parameter name ' ...
                    'or an options structure\ncreated with GAOPTIMSET.'], i);
        end
        for j = 1:m
            if any(strcmp(fieldnames(arg),Names{j,:}))
                val = arg.(Names{j,:});
            else
                val = [];
            end
            if ~isempty(val)
                if ischar(val)
                    val = deblank(val);
                end
                [valid, errmsg] = checkfield(Names{j,:},val);
                if valid
                    options.(Names{j,:}) = val;
                else
                    error('gads:GAOPTIMSET:invalidOptionField',errmsg);
                end
            end
        end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error('gads:GAOPTIMSET:invalidArgPair','Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= numberargs
    arg = varargin{i};
    
    if ~expectval
        if ~ischar(arg)
            error('gads:GAOPTIMSET:invalidArgFormat','Expected argument %d to be a string parameter name.', i);
        end
        
        lowArg = lower(arg);
        j = strmatch(lowArg,names);
        if isempty(j)                       % if no matches
            error('gads:GAOPTIMSET:invalidParamName','Unrecognized parameter name ''%s''.', arg);
        elseif length(j) > 1                % if more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,names,'exact');
            if length(k) == 1
                j = k;
            else
                msg = sprintf('Ambiguous parameter name ''%s'' ', arg);
                msg = [msg '(' Names{j(1),:}];
                for k = j(2:length(j))'
                    msg = [msg ', ' Names{k,:}];
                end
                msg = sprintf('%s).', msg);
                error('gads:GAOPTIMSET:ambiguousParamName',msg);
            end
        end
        expectval = 1;                      % we expect a value next
        
    else           
        if ischar(arg)
            arg = (deblank(arg));
        end
        [valid, errmsg] = checkfield(Names{j,:},arg);
        if valid
            options.(Names{j,:}) = arg;
        else
            error('gads:GAOPTIMSET:invalidParamVal',errmsg);
        end
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error('gads:GAOPTIMSET:invalidParamVal','Expected value for parameter ''%s''.', arg);
end


%-------------------------------------------------
function [valid, errmsg] = checkfield(field,value)
%CHECKFIELD Check validity of structure field contents.
%   [VALID, MSG] = CHECKFIELD('field',V) checks the contents of the specified
%   value V to be valid for the field 'field'. 
%

valid = 1;
errmsg = '';
% empty matrix is always valid
if isempty(value)
    return
end

switch field
    case {'PopulationType','MigrationDirection'}
        if ~isa(value,'char') 
            valid=0;
            errmsg = sprintf('Invalid value for OPTIONS parameter %s.',field);
        end
        
    case {'FitnessScalingFcn','SelectionFcn','CrossoverFcn','MutationFcn',...
                'CreationFcn','HybridFcn','PlotFcns','OutputFcns'}
        if iscell(value) ||  isa(value,'function_handle')
            valid = 1;
        else
            valid = 0;
            errmsg = sprintf('Invalid value for OPTIONS parameter %s.',field);
        end
        
    case {'PopulationSize','EliteCount','CrossoverFraction','MigrationInterval','PlotInterval', ...
                'MigrationFraction','Generations','TimeLimit','StallTimeLimit','FitnessLimit','StallGenLimit'} 
        if ~isa(value,'double')  
            valid = 0;
            if ischar(value)
                errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive number (not a string).',field);
            else
                errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive number.',field);
            end
        end
    case {'PopInitRange','InitialPopulation','InitialScores'}
        valid = 1;
    case {'Display'}
        if ~isa(value,'char') || ~any(strcmpi(value,{'off','iter','diagnose','final'}))
            valid=0;
            errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be ''off'',''iter'', ''diagnose'', or ,''final''.',field);
        end
    case {'Vectorized'}
        if ~isa(value,'char') || ~any(strcmp(value,{'on','off'}))
            valid = 0;
            errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be ''off'' or ''on''.',field);
        end
    otherwise
        error('gads:GAOPTIMSET:unknownOptionsField','Unknown field name for Options structure.')
end    

