function opspec = getNominal(h,opspecin)

% Copyright 2003-2004 The MathWorks, Inc.

% Retrieves nominal data from MPC GUI node and assigns it to the operating
% condition specification object opspec. The method also checks for the
% compability of the i/o tables and the operating spec object by counting
% the number of MVs and MOs in each and testing that they match

% Copy the input object. Cannot work solely with opsecin as a handle
% since addoutputspec creates a copy
opspec = opspecin.copy;
        
%% Obtain the poitions of MV and MO in the op constraint obj
Iobjmv = find(strcmp(get(opspec.outputs,{'Block'}),h.Block));
if length(Iobjmv)~=1
    opspec = addoutputspec(opspec,h.Block,1);
    mpcports = get_param(h.Block,'PortHandles');
    Iobjmv = length(opspec.Outputs);
end

%% Find the position of the MO output constraint
ports = get_param(h.Block, 'PortHandles');
portcon = get_param(h.Block,'PortConnectivity');
mosrcblk = getfullname(portcon(1).SrcBlock);
Iobjmo = find(strcmp(get(opspec.outputs,{'Block'}),mosrcblk));
if length(Iobjmo)~=1
    opspec = addoutputspec(opspec,mosrcblk,portcon(1).SrcPort+1); 
    Iobjmo = length(opspec.Outputs);
end

%% Get the i/o table data and check for empty tables 
outtabledata = h.outUDD.CellData;
intabledata = h.inUDD.CellData;
if size(outtabledata,1)==0 || size(intabledata,1)==0 
    msg = sprintf('%s%s','One or both of the input/output tables is empty.',...
        ' Consequently the operating condition cannot be derived from this source.'); 
    errordlg(msg,'Model Predictive Control Toolbox','modal')
    opspec = []; % Clear the returned opspec so the error can be trapped
    return
end

%% Check that the number of MO rows match the MO port width
Itablemo = find(strcmp(outtabledata(:,2),'Measured'));
if length(Itablemo)~= length(opspec.outputs(Iobjmo).y)
    msg = ['Misimatch between the width of the MOs in operating condition ' ...
           'constraint and the number of MOs in the i/o table. '];
    errordlg(msg,'Model Predictive Control Toolbox')
    return
end

%% Check that the number of MV rows match the MV port width
Itablemv = find(strcmp('Manipulated',intabledata(:,2)));
if length(Itablemv)~= length(opspec.outputs(Iobjmv).y)
    msg = ['Misimatch between the width of the MVs in operating condition ' ...
           'constarint and the number of MVs in the i/o table. '];
    errordlg(msg,'Model Predictive Control Toolbox')
    return
end

%% Extract the MO/MV constraints from the nominal values in the i/o table
for k=1:length(Itablemo)
    if ischar(outtabledata{Itablemo(k),end})
        mo(k) = str2num(outtabledata{Itablemo(k),end});
    else
        mo(k) = outtabledata{Itablemo(k),end};
    end
end
for k=1:length(Itablemv)
    if ischar(intabledata{Itablemv(k),end})
       mv(k) = str2num(intabledata{Itablemv(k),end});
    else
       mv(k) = intabledata{Itablemv(k),end};
    end
end

%% Check that the i/o table has at least one mv & mo row
if length(Itablemv)<=0 || length(Itablemo)<=0
    msg = 'The MPC i/o table must have at least one MV and MO';
    errordlg(msg,'Model Predictive Control Toolbox')
    return
end

%% Assign controller output constraints to the MV and MO values in the
%% i/o table
set(opspec.outputs(Iobjmv),'y', mv(:),'Known', true*ones(size(mv(:))));
Itablemo = find(strcmp('Measured',outtabledata(:,2)));
if length(Itablemo)>=1
    set(opspec.outputs(Iobjmo),'y', mo(:),'Known', true*ones(size(mo(:))));
end
