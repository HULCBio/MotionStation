function mdrows = mpcblockiotable(io, mpcblockname, varargin)

% Copyright 2003-2004 The MathWorks, Inc.

% Returns the indices of MD inputs in the linearized model produced by the 
% object io. The following checks are also performed and  
% corrective measures are applied
% 1. mv linearization i/p exist and are open loop and active
% 2. mo linearizaton o/p exist and are open loop and active
% 3. Width of additional active linearization inputs = nmo+nmd
 
if nargin>=3
    model = varargin{1};
else
    model = gcs;
end
deactivatedflag = false;

%% Model must be compiled to get port width
if strcmp(get_param(model, 'SimulationStatus'),'stopped')
    feval(model,[],[],[],'compile');
end

%% Extract the source for the MO port
portconection = get_param(mpcblockname, 'PortConnectivity');
ports = get_param(mpcblockname, 'PortHandles');
moport = handle(ports.Inport(1));
nmo = moport.compiledportwidth;
mosrcblk = getfullname(portconection(1).SrcBlock);

%% Get the MD port width
nmd = 0;
if strcmp(get_param(mpcblockname,'md_inport'),'on')
    mdport = handle(ports.Inport(3));
    % If MD port is disconnected mnd = 0
    if portconection(3).SrcBlock ~=-1
        nmd = get(mdport,'compiledportwidth');
    end
end

%% Build input table
Iin = find(strcmp(get(io,{'Type'}),'in'));
row = 1;
inwidth = 0;
mvlinpoints = 0;
mdrows = [];
for k=1:length(Iin)
    porthandles = get_param(io(Iin(k)).Block,'PortHandles');
    portwidth = get(porthandles.Outport(io(Iin(k)).PortNumber), ...
        'CompiledPortWidth');
    % If this is an MV lin input is must be open loop and active
    if strcmp(io(Iin(k)).Block,mpcblockname)
       mvlinpoints = mvlinpoints+1;
       row = row+portwidth;
       inwidth = inwidth+portwidth;
       if strcmp(io(Iin(k)).Active,'off') || strcmp(io(Iin(k)).OpenLoop,'off')
           msg = ['Temporarily converting the MV port into active open loop ',...
                 'linearization input point to linearize the plant model'];
           postText(slctrlexplorer,msg);
           set(io(Iin(k)),'Active','on','OpenLoop','on')     
       end
    % Inputs i/o points whcih are not at the MV port are considered MD
    % inputs
    elseif strcmp(io(Iin(k)).Active,'on')
        % If the md port is disconnected, deactivate all non mv input points
        if nmd>0
           if strcmp(io(Iin(k)).Block,mosrcblk)
              errordlg('Active input lin pts cannot be assigned to MPC block MO inputs',...              
                 'Model Predictive Control Toolbox','modal')
              error('mpcblockiotable:linintoMO', ...
                 'Active input lin pts cannot be assigned to MPC block MO inputs')
           end  
            
           mdrows = [mdrows row:row+portwidth-1];
           row = row+portwidth;
           inwidth = inwidth+portwidth;
        else
            set(io(Iin(k)),'Active','off')
            deactivatedflag = true;
        end
    end
end

%% Get MPC block outport info
outPortHandle = ports.Outport(1);
nmv = get(outPortHandle,'CompiledPortWidth');

%% If no mv input exists then create one
if mvlinpoints==0
    msg = ['No MPC MV (input) linearization points have been defined ',...
           'in the model. A temporary MV output linearization point will ',...
           'be added to perform the linearization'];
    mvpt = LinearizationObjects.LinearizationIO;
    set(mvpt,'Block',mpcblockname,'OpenLoop','on','Type','in', ...
        'PortNumber',1,'Active','on');
    io = [io; mvpt];
    mvlinpoints = 1;
    porthandles = get_param(mpcblockname,'PortHandles');
    inwidth = inwidth+nmv;
end
    
%% There should be exactly 1 mv linearization point
if mvlinpoints>1
%    errordlg('There must be one open loop active linearization point at the MV port',...
%        'MPC Toolbox')
   feval(model,[],[],[],'term');
   error('mpcblockiotable:nomv','Wrong number of mv linearization pts')
end

%% If the width of the input linearization points does not match nmo+nmd 
%% thow an error - should be caught
if inwidth~=(nmv+nmd)
    msg = ['There is a mismatch between the MD port width (' sprintf('%d',nmd) ')' ...
           ' and the width of the additional (non MO,MV) linearization points ('  ...
           sprintf('%d',inwidth-nmo) ') .Cannot perform linearization.'];
    errordlg(msg,'Model Predictive Control Toolbox')
    feval(model,[],[],[],'term');
    error('mpcblockiotable:nmdnismatch', ...
        'Linearization mismatch between block i/o and linearization i/o')
end
    
%% Build output table
Iout = find(strcmp(get(io,{'Type'}),'out'));
row = 1;
outwidth = 0;
molinpts = 0;
for k=1:length(Iout)
    % If this is an MO lin output is must be open loop and active
    if strcmp(io(Iout(k)).Block,mosrcblk)
       porthandles = get_param(io(Iout(k)).Block,'PortHandles');
       portwidth = get(porthandles.Outport(io(Iout(k)).PortNumber), ...
           'CompiledPortWidth');
       molinpts = molinpts+1;
       if strcmp(io(Iout(k)).Active,'off') || strcmp(io(Iout(k)).OpenLoop,'off')
           postText(slctrlexplorer, ...
               'MO output is being modified to have active, open loop status');
           set(io(Iout(k)),'Active','on', 'OpenLoop','on')
       end
       row = row+portwidth;
       outwidth = outwidth+portwidth;
    else % Deactivate all outputs which are not MOs
       set(io(Iout(k)),'Active','off')
       deactivatedflag = true;
    end
end

%% If no mo output exists then create one
if molinpts==0
    msg = ['No MPC MO (output) linearization points have been defined ',...
           'in the model. A temporary MO output linearization point has ',...
           'been added to preform the linearization'];
    postText(slctrlexplorer,msg);
    mopt = LinearizationObjects.LinearizationIO;
    set(mopt,'Block',mosrcblk,'OpenLoop','on','Type','out', ...
        'PortNumber',1,'Active','on');
    io = [io; mopt];
    molinpoints = 1;
    porthandles = get_param(mosrcblk,'PortHandles');
    outwidth = outwidth+get(porthandles.Outport(1),'CompiledPortWidth');
end
   
%% There should be exactly 1 mo linearization point
if molinpts>1
   errordlg('There must be one open loop active linearization point at the MO port',...
        'Model Predictive Control Toolbox','modal')
   feval(model,[],[],[],'term');
   error('mpcblockiotable:nomo','Wrong number of mo linearization pts')
end

if deactivatedflag
    msg = ['Additional linearization points which are not associated ',...
           'with the MPC block MO or MV ports have been ignored when ',...
           'performing the linearization'];
    postText(slctrlexplorer,msg);
end
    
%% Update simulink model
setlinio(model, io);

%% Terminate simulation
if ~strcmp(get_param(model, 'SimulationStatus'),'stopped')
       feval(model,[],[],[],'term');
end
