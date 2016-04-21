function varargout = simget(varargin)
%SIMGET Get SIM Options structure.
%   Struct = SIMGET(MODEL) returns the current SIM command Options structure
%   for the given Simulink model. The Options structure is used in the SIM and
%   SIMSET commands.
%
%   Value = SIMGET(MODEL,property) extracts the value of the named simulation
%   parameter or solver property from the model.
%
%   Value=SIMGET(OptionStructure,property) extracts the value of the named
%   simulation parameter or solver property from the OptionStructure,
%   returning an empty matrix if the value is not specified in the structure.
%   Property can be a cell array containing the list of parameter and property
%   names of interest.  If a cell array is used, then the output is also a
%   cell array.
%
%   You need to enter only as many leading characters of a property name as
%   are necessary to uniquely identify it. Case is ignored for property names.
%
%   Struct = SIMGET returns the full options structure with fields set to [].
%
%   See also SIM, SIMSET.

%   Loren Dean
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.20.2.2 $


%
% Create an options structure and get its field names
%
OptionsStructure=simset;
FieldNames=fieldnames(OptionsStructure);

switch nargin,
  case 0,
    varargout{1} = OptionsStructure;
    
  case 1,
    % return full options structure
    if isstruct(varargin{1}),
      varargout{1}=LocalGetEmptyFields(varargin{1},FieldNames);
    % Model name passed in, return options structure
    else,
      [varargout{1},ErrMsg]=LocalGetOptionsStructure(varargin{1});
      if ~isempty(ErrMsg),
        error(ErrMsg)
      end % if ~isempty
    end
  case 2,
    if isstruct(varargin{1}),
      Options=varargin{1};
    else,
      [Options,ErrMsg]=LocalGetOptionsStructure(varargin{1});
      if ~isempty(ErrMsg),
        error(ErrMsg)
      end % if ~isempty
    end
    if ~iscell(varargin{2}),
      Name=varargin(2);
    else,
      Name=varargin{2};
    end

    Names=lower(char(FieldNames));
    TempOut=[];
    for CellLp=1:length(Name),
      TempName=lower(Name{CellLp});
      Loc = strmatch(TempName,Names);
      if isempty(Loc), % No matches
        error(['Unrecognized option name '''              ...
                TempName '''.  Type ''help simset''.'] ...
             );

      elseif length(Loc) > 1, % More than one match
        % Check for any exact matches
        TempLoc = strmatch(name,names,'exact');
        if length(TempLoc) == 1,
          Loc = TempLoc;
        else,
         error(['Ambiguous option name ''' name '''.  Type ''help simset''.']);
        end % length
      end % isempty

      % Return a value
      if length(Name)==1,
        TempOut=getfield(Options,FieldNames{Loc});

      % Return a structure
      else,
        TempOut{CellLp}=getfield(Options,FieldNames{Loc});
      end
    end
    varargout{1}=TempOut;
end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetOptionsStructure %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Struct,ErrMsg]=LocalGetOptionsStructure(ModelName)

OpenFlag=1;
ErrMsg='';
ErrorFlag=isempty(find_system(0,'flat','CaseSensitive','off','Name',ModelName));
if ErrorFlag,
  ErrorFlag=~(exist(ModelName)==4);
  if ~ErrorFlag,
    OpenFlag=0;
    load_system(ModelName);
  end
end
if ErrorFlag,
  ErrMsg=[ModelName ' must be the name of a Simulink model.'];
  Struct=[];
  return
end
Struct=simset;
ErrorString={};
[ErrorString,StartTime]=LocalGetVal(ModelName,'StartTime',ErrorString);
[ErrorString,StopTime]=LocalGetVal(ModelName,'StopTime',ErrorString);

Struct.Solver=get_param(ModelName,'Solver');

Struct.RelTol=get_param(ModelName,'RelTol');
if ~isequal(Struct.RelTol,'auto'),
  [ErrorString,Struct.RelTol]=LocalGetVal(ModelName,'RelTol',ErrorString);
end

Struct.AbsTol=get_param(ModelName,'AbsTol');
if ~isequal(Struct.AbsTol,'auto'),
  [ErrorString,Struct.AbsTol]=LocalGetVal(ModelName,'AbsTol',ErrorString);
end

[ErrorString,Struct.Refine]=LocalGetVal(ModelName,'Refine',ErrorString);

Struct.MaxStep=get_param(ModelName,'MaxStep');
if ~isequal(Struct.MaxStep,'auto'),
  [ErrorString,Struct.MaxStep]=LocalGetVal(ModelName,'MaxStep',ErrorString);
end

Struct.MinStep=get_param(ModelName,'MinStep');
if ~isequal(Struct.MinStep,'auto'),
  [ErrorString,Struct.MinStep]=LocalGetVal(ModelName,'MinStep',ErrorString);
end

Struct.InitialStep=get_param(ModelName,'InitialStep');
if ~isequal(Struct.InitialStep,'auto'),
  [ErrorString,Struct.InitialStep]= ...
      LocalGetVal(ModelName,'InitialStep',ErrorString);
end

Struct.MaxOrder=get_param(ModelName,'MaxOrder');

Struct.FixedStep=get_param(ModelName,'FixedStep');
if ~isequal(Struct.FixedStep,'auto'),
  [ErrorString,Struct.FixedStep]= ...
      LocalGetVal(ModelName,'FixedStep',ErrorString);
end

switch get_param(ModelName,'OutputOption'),
  case 'RefineOutputTimes',
    Struct.OutputPoints='all';
  case 'AdditionalOutputTimes',
    Struct.OutputPoints='all';
  case 'SpecifiedOutputTimes',
    Struct.OutputPoints='specified';
end % switch

TTemp=get_param(ModelName,'SaveTime');
XTemp=get_param(ModelName,'SaveState');
YTemp=get_param(ModelName,'SaveOutput');
Val='';
if TTemp(2)=='n',Val=[Val 't'];end
if XTemp(2)=='n',Val=[Val 'x'];end
if YTemp(2)=='n',Val=[Val 'y'];end
Struct.OutputVariables=Val;

if strcmp(get_param(ModelName,'LimitDataPoints'),'off'),
  Struct.MaxDataPoints=0;
else,
 [ErrorString,Struct.MaxDataPoints]= ...
     LocalGetVal(ModelName,'MaxDataPoints',ErrorString);
end

[ErrorString,Struct.Decimation]= ...
    LocalGetVal(ModelName,'Decimation',ErrorString);

if strcmp(get_param(ModelName,'LoadInitialState'),'off'),
  Struct.InitialState=[];
else,
  [ErrorString,Struct.InitialState]= ...
      LocalGetVal(ModelName,'InitialState',ErrorString);
end

if strcmp(get_param(ModelName,'SaveFinalState'),'off'),
  Struct.FinalStateName ='';
else,
  Struct.FinalStateName =get_param(ModelName,'FinalStateName');
end

Struct.Debug          ='off'; % Currently forced off
Struct.Trace          =''; % Currently forced to this
Struct.SrcWorkspace   ='base'; % Currently forced to this value
Struct.DstWorkspace   ='current'; % Currently forced to this value
Struct.ZeroCross      =get_param(ModelName,'ZeroCross');
Struct.SaveFormat     =get_param(ModelName,'SaveFormat');

Struct.ExtrapolationOrder = get_param(ModelName,'ExtrapolationOrder');
Struct.NumberNewtonIterations = get_param(ModelName,'NumberNewtonIterations');

if ~OpenFlag,close_system(ModelName,0);end
if ~isempty(ErrorString),
  ParamString='';
  ReturnChar=sprintf('\n');
  for lp=1:length(ErrorString),
    ParamString=[ParamString '    ' ErrorString{lp} ReturnChar];
  end % for lp
  ParamString(end)='';

  ErrMsg=[
     'All variables used in the Parameters dialog must exist in the ', ...
     'workspace.', ReturnChar, ...
     'The following parameters have variables which are undefined:' , ...
     ReturnChar, ...
     ParamString];
  Struct=[];
  return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetEmptyFields %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OptionsStructure=LocalGetEmptyFields(OptionsStructure,FieldNames)
for lp=1:length(FieldNames),
  if ~isfield(OptionsStructure,FieldNames{lp}),
    OptionsStructure=setfield(OptionsStructure,FieldNames{lp},[]);
  end
end % for

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetVal %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function [ErrorString,OutputVal]=LocalGetVal(ModelName,Parameter,ErrorString)

TestVal=[1.123498768642;9.67894321246];
TestValStr=mat2str(TestVal);

OutputVal=evalin('base',get_param(ModelName,Parameter),TestValStr);
if isequal(OutputVal,TestVal),
  ErrorString{end+1}=Parameter;
end % if
