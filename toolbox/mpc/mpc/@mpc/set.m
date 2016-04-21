function Out = set(MPCobj,varargin)
%SET  Set properties of MPC controllers.
%
%   SET(MPCOBJ,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the MPC model MPCOBJ to the value VALUE.  An equivalent syntax 
%   is 
%       MPCOBJ.PropertyName = VALUE .
%
%   SET(MPCOBJ,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   MPC property values with a single statement.
%
%   SET(MPCOBJ,'Property') displays legitimate values for the specified
%   property of MPCOBJ.
%
%   SET(MPCOBJ) displays all properties of MPCOBJ and their admissible 
%   values.  Type HELP MPCPROPS for more details on MPC properties.
% 
%   See also GET, MPCPROPS, MPC.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2004/04/10 23:35:11 $   

ni = nargin;
no = nargout;
if ~isa(MPCobj,'mpc'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',MPCobj,varargin{:});
   return
elseif no & ni>2,
   error('mpc:set:out','Output argument allowed only in SET(MPCOBJ) or SET(MPCOBJ,Property)');
end

% Get properties and their admissible values when needed
if ni<=2,
   [AllProps,AsgnValues] = pnames(MPCobj);
else
   AllProps = pnames(MPCobj);
end

% Handle read-only cases
if ni==1,
   % SET(MPCOBJ) or S = SET(MPCOBJ)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues));
   end
   return

elseif ni==2,
   % SET(MPCOBJ,'Property') or STR = SET(MPCOBJ,'Property')
   
   Property = varargin{1};
   if ~ischar(Property),
      error('mpc:set:string','Property names must be single-line strings.')
   end

   % Return admissible property value(s)
   imatch = strmatch(lower(Property),lower(AllProps));
   aux=PropMatchCheck(length(imatch),Property);
   if ~isempty(aux),
       error('mpc:set:match',aux);
   end
   if no,
      Out = AsgnValues{imatch};
   else
      disp(AsgnValues{imatch})
   end
   return

end

MPCData=MPCobj.MPCData;

% Now left with SET(MPCOBJ,'Prop1',Value1, ...)

if MPCData.isempty,
    error('mpc:set:empty','Cannot SET properties of empty mpc objects - Please use the constructor MPC instead');
end

% Retrieve info about previously stored properties

p=MPCobj.PredictionHorizon;
moves=MPCobj.ControlHorizon;
mvindex=MPCData.mvindex;
mdindex=MPCData.mdindex;
myindex=MPCData.myindex;
unindex=MPCData.unindex;
nutot=MPCData.nutot;
ny=MPCData.ny;
nu=MPCData.nu;
ts=MPCobj.Ts;
QP_ready=MPCData.QP_ready;
L_ready=MPCData.L_ready;
Model=MPCobj.Model;
Weights=MPCobj.Weights;
ManipulatedVariables=MPCobj.ManipulatedVariables;
OutputVariables=MPCobj.OutputVariables;
DisturbanceVariables=MPCobj.DisturbanceVariables;
WeightsDefault=MPCData.WeightsDefault;

name = inputname(1);
if isempty(name),
   error('mpc:set:first','First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
   error('mpc:set:pair','Property/value pairs must come in even number.')
end

% Initialize flags indicating which properties will be changed. These
% are stored in the structure Chg, having the same fieldnames of the MPC object

for i=1:length(AllProps);
   %eval(['Chg.' AllProps{i} '=0;']);
   Chg.(AllProps{i})=0;
end

for i=1:2:ni-1,
   % Set each PV pair in turn
   PropStr = varargin{i};
   if ~isstr(PropStr),
      error('mpc:set:string','Property names must be single-line strings.')
   end
   
   propstr=lower(PropStr);
   
   % Handle multiple names
   if strcmp(propstr,'mv') | strcmp(propstr,'manipulated') | strcmp(propstr,'input'),
      propstr='manipulatedvariables';
   elseif strcmp(propstr,'ov') | strcmp(propstr,'controlled') | strcmp(propstr,'output'),
      propstr='outputvariables';
   elseif strcmp(propstr,'dv') | strcmp(propstr,'disturbance'),
      propstr='disturbancevariables';
   end
   

   imatch = strmatch(propstr,lower(AllProps));
   aux=PropMatchCheck(length(imatch),PropStr);
   if ~isempty(aux),
       error('mpc:set:match',aux);
   end
   Property = AllProps{imatch};
   Value = varargin{i+1};
   
   % Just sets what was required, will check later on when all 
   % properties have been set
      
   %eval(['MPCobj.' Property '=Value;']);
   %eval(['Chg.' Property '=1;']);
   MPCobj.(Property)=Value;
   Chg.(Property)=1;
end   

% if Chg.MPCData,
%     % Update changes
%     MPCData=MPCobj.MPCData;
% end


% Modify properties   

default=mpc_defaults;

%-----------------%

try
    if Chg.Ts,
        % Check consistency of sampling time.
        mpc_chkts(MPCobj.Ts);
        Chg.Ts=~isequal(MPCobj.Ts,ts);
    end

    %-----------------%

    if Chg.Model | Chg.Ts,

        % Prediction model

        if isa(MPCobj.Model,'lti'), % |~isa(MPCobj.Model,'fir'), % FIR objects not yet available ...
            MPCobj.Model=struct('Plant',MPCobj.Model);
        end

        if ~isa(MPCobj.Model,'struct'),
            error('mpc:set:model','''Model'' must be an LTI object or a structure of models and offsets')
        end

        % Check the Model structure and consistencies
        [MPCobj.Model,nu_,ny_,nutot_,mvindex_,mdindex_,unindex_,myindex_]=...
            mpc_prechkmodel(MPCobj.Model,MPCobj.Ts);
    
    else
        nu_=nu;
        ny_=ny;
        nutot_=nutot;
        mvindex_=mvindex;
        mdindex_=mdindex;
        unindex_=unindex;
        myindex_=myindex;
    end

    if Chg.PredictionHorizon | Chg.Model | Chg.Ts,
        % Check correctness of prediction horizon
        [MPCobj.PredictionHorizon,p_defaulted]=mpc_chkp(MPCobj.PredictionHorizon,default.p,MPCobj.Model,MPCobj.Ts);

        % Is PredictionHorizon changed ?
        Chg.PredictionHorizon=~isequal(MPCobj.PredictionHorizon,p);

    end
    p_defaulted=MPCData.p_defaulted;

    %-----------------%
    
    Chg.Model=~isequal(Model,MPCobj.Model);
    Chg.nu=(nu_~=nu);
    Chg.ny=(ny_~=ny);
    Chg.nutot=(nutot_~=nutot);
    Chg.mvindex=~isequal(mvindex_(:),mvindex(:));
    Chg.mdindex=~isequal(mdindex_(:),mdindex(:));
    Chg.unindex=~isequal(unindex_(:),unindex(:));
    Chg.myindex=~isequal(myindex_(:),myindex(:));
    Chg.ModelPlant=~isequal(Model.Plant,MPCobj.Model.Plant);
    Chg.ModelDisturbance=~isequal(Model.Disturbance,MPCobj.Model.Disturbance);
    Chg.ModelNoise=~isequal(Model.Noise,MPCobj.Model.Noise);
    Chg.ModelNominal=~isequal(Model.Nominal,MPCobj.Model.Nominal);
    
    %-----------------%

    if Chg.ControlHorizon | Chg.PredictionHorizon,
        % Check correctness of input horizon/blocking moves
        MPCobj.ControlHorizon=mpc_chkm(MPCobj.ControlHorizon,MPCobj.PredictionHorizon,default.m);

        Chg.ControlHorizon=~isequal(MPCobj.ControlHorizon,moves);
    end

    %-----------------%

    if Chg.Weights|Chg.nu|Chg.ny|Chg.PredictionHorizon,
        MPCobj.Weights=mpc_chkweights(MPCobj.Weights,MPCobj.PredictionHorizon,nu_,ny_);
        Chg.Weights=~isequal(MPCobj.Weights,Weights);

        WeightsDefault=isempty(MPCobj.Weights);           
    end

    %-----------------%
    if Chg.DisturbanceVariables|Chg.nutot|Chg.nu|Chg.PredictionHorizon|...
            Chg.ModelPlant|Chg.mdindex|Chg.unindex,
        MPCobj.DisturbanceVariables=mpc_specs(MPCobj.DisturbanceVariables,nutot_-nu_,...
            'DisturbanceVariables',MPCobj.PredictionHorizon,[],...
            MPCobj.Model.Plant.InputName,[mdindex_(:);unindex_(:)],Chg.ModelPlant);
    end

    %-----------------%

    if Chg.ManipulatedVariables|Chg.nu|Chg.PredictionHorizon|...
            Chg.ModelPlant|Chg.mvindex,
        MPCobj.ManipulatedVariables=mpc_specs(MPCobj.ManipulatedVariables,nu_,'ManipulatedVariables',...
            MPCobj.PredictionHorizon,[],MPCobj.Model.Plant.InputName,mvindex_,Chg.ModelPlant);
        Chg.ManipulatedVariables=~isequal(MPCobj.ManipulatedVariables,ManipulatedVariables);
    end

    %-----------------%

    if Chg.Optimizer,
        MPCobj.Optimizer=mpc_chkoptimizer(MPCobj.Optimizer);
    end

    %-----------------%

    if Chg.OutputVariables|Chg.ny|Chg.PredictionHorizon|Chg.ModelPlant,
        MPCobj.OutputVariables=mpc_specs(MPCobj.OutputVariables,...
            ny_,'OutputVariables',MPCobj.PredictionHorizon,...
            MPCobj.Optimizer.MinOutputECR,MPCobj.Model.Plant.OutputName,1:ny_,Chg.ModelPlant);
        Chg.OutputVariables=~isequal(MPCobj.OutputVariables,OutputVariables);
    end

    %-----------------%
    if Chg.History,
        % Check consistency of history field and possibly convert it to DATEVEC (=CLOCK) format.
        MPCobj.History=mpc_chkhistory(MPCobj.History);
    end

    %-----------------%
    if Chg.Notes,
        % Check consistency of Notes field 
        if ~iscell(MPCobj.Notes),
            error('mpc:set:notes','MPC notes must be a cell array of strings');
        end
    end
    %-----------------%

%     % Keep Model.Plant names and 'Name' fields in Specs consistent
%     
%     Chg.MVname=0;
%     for i=1:nu,
%         Chg.MVname=Chg.MVname | ~isequal(ManipulatedVariables(i).Name,MPCobj.ManipulatedVariables(i).Name);
%     end
% 
%     Chg.MDname=0;
%     for i=1:length(mdindex)+length(unindex),
% 
%         Chg.MDname=Chg.MDname | ~isequal(DisturbanceVariables(i).Name,MPCobj.DisturbanceVariables(i).Name);
%     end
% 
%     Chg.OVname=0;
%     for i=1:ny,
%         Chg.OVname=Chg.OVname | ~isequal(OutputVariables(i).Name,MPCobj.OutputVariables(i).Name);
%     end
% 
%     
%     if Chg.MVname,
%         for i=1:nu,
%             MPCobj.Model.Plant.InputName{mvindex(i)}=MPCobj.ManipulatedVariables(i).Name;
%         end
%     end
%     if Chg.OVname,
%         for i=1:ny,
%         MPCobj.Model.Plant.OutputName{i}=MPCobj.OutputVariables(i).Name;
%         end
%     end
%     if Chg.MDname,
%         nv=length(mdindex);
%         for i=1:nv,
%             MPCobj.Model.Plant.InputName{mdindex(i)}=MPCobj.DisturbanceVariables(i).Name;
%         end
%         for i=1:length(unindex),
%             MPCobj.Model.Plant.InputName{unindex(i)}=MPCobj.DisturbanceVariables(nv+i).Name;
%         end
%     end
    
catch
    rethrow(lasterror);
end

% if Chg.MPCData,
% 
% % The following check slows down a bit, so was removed ...
% %         fields={'p_defaulted','mvindex','mdindex','myindex','unindex',...
% %             'nutot','ny','nu','QP_ready','L_ready','Init','isempty','OutDistFlag'};
% %         for i=1:length(fields),
% %             if ~isfield(MPCobj.MPCData,fields{i}),
% %                 error('MPCData is not a valid MPC data structure');
% %             end
% %         end
% 
%     % Update flags
%     QP_ready=MPCData.QP_ready;
%     L_ready=MPCData.L_ready;
% end

%-----------------%


% Update flags for readiness of QP matrices and estimator gain
QP_ready=QP_ready & ~Chg.PredictionHorizon & ~Chg.Model & ~Chg.ControlHorizon & ...
   ~Chg.mvindex & ~Chg.mdindex & ~Chg.unindex & ~Chg.Weights & ...
   ~Chg.ManipulatedVariables & ~Chg.OutputVariables & ~Chg.Ts;

L_ready=L_ready & ~Chg.Model & ...
   ~Chg.mvindex & ~Chg.mdindex & ~Chg.unindex & ~Chg.myindex & ~Chg.Ts;


MPCData.p_defaulted=p_defaulted;
MPCData.mvindex=mvindex_;
MPCData.mdindex=mdindex_;
MPCData.myindex=myindex_;
MPCData.unindex=unindex_;
MPCData.nutot=nutot_;
MPCData.ny=ny_;
MPCData.nu=nu_;
MPCData.QP_ready=QP_ready;
MPCData.L_ready=L_ready;

if ~QP_ready|~L_ready,
    MPCData.Init=0;
end

MPCData.WeightsDefault=WeightsDefault;
MPCobj.MPCData=MPCData;

% Finally, assign MPCobj in caller's workspace
assignin('caller',name,MPCobj);


% subfunction PropMatchCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errmsg = PropMatchCheck(nhits,Property)
% Issues a standardized error message when the property name 
% PROPERTY is not uniquely matched.

if nhits==1,
   errmsg = '';
elseif nhits==0,
   errmsg = ['Invalid property name "' Property '".']; 
else
   errmsg = ['Ambiguous property name "' Property '". Supply more characters.'];
end