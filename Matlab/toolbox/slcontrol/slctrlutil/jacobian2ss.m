function sys = jacobian2ss(J,model,options,Ts,input_ind,output_ind,input_name,output_name)
%JACOBIAN2SS
%
% SYS = JACOBIAN2SS Obtains a linear model from a the Jacobian structure 
% information from linearization and the IO pairings.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/19 01:32:53 $

%% Extract the upper parts of the LFT
a = J.A; b = J.B; c = J.C; d = J.D; M = J.Mi;

%% Get the model sample rates and block dimensions
[ny,nu] = size(d);
nxz = size(a,1);
Tsx = J.Ts(1:nxz);
Tsy = J.Ts(nxz+1:end);

%% Extract lower parts of the lft
E = J.Mi.E;
F = J.Mi.F;
G = J.Mi.G;
H = J.Mi.H;

%% Get the state names
StateName = J.StateName;

%% Perform block reduction if requested
if strcmpi(options.BlockReduction,'on')
    %% Removing blocks that are not part of the linearization
    blocks = find(~(J.Mi.ForwardMark & J.Mi.BackwardMark));
    nblocks = length(blocks);
    
    %% Get the block handles
    bh = J.Mi.BlockHandles;
    
    %% Extract index elements, tack on the number of states, inputs, and
    %% outputs to account for the last block in the list.  Convert from
    %% C-indexing to Matlab-indexing.
    StateIdx = [J.Mi.StateIdx+1;nxz+1];
    InputIdx = [J.Mi.InputIdx+1;nu+1];
    OutputIdx = [J.Mi.OutputIdx+1;ny+1];
        
    indx = [];indu = [];indy = [];
    for ct = 1:nblocks
        %% Get the block handle
        try
            state_ind = find(strcmp(getfullname(J.Mi.BlockHandles(blocks(ct))),StateName));
            if ~isempty(state_ind)
                indx = [indx;state_ind];
            end
        end
        if (InputIdx(blocks(ct)) ~= InputIdx(blocks(ct)+1))
            indu = [indu,InputIdx(blocks(ct)):(InputIdx(blocks(ct)+1)-1)];
        end
        if (OutputIdx(blocks(ct)) ~= OutputIdx(blocks(ct)+1))
            indy = [indy,OutputIdx(blocks(ct)):(OutputIdx(blocks(ct)+1)-1)];
        end
    end
    
    %% Eliminate states
    if ~isempty(indx) 
        a(indx,:) = [];
        a(:,indx) = [];
        StateName(indx) = [];
        b(indx,:) = [];
        c(:,indx) = [];
        Tsx(indx) = [];
        nxz = length(a);
    end
    %% Eliminate block inputs
    if ~isempty(indu) 
        b(:,indu) = [];
        d(:,indu) = [];
        E(indu,:) = [];
        F(indu,:) = [];
        nu = size(b,2);
    end
    %% Eliminate block outputs
    if ~isempty(indy) 
        c(indy,:) = [];
        d(indy,:) = [];
        E(:,indy) = [];
        G(:,indy) = [];
        Tsy(indy) = [];
        ny = size(c,1);
    end   
end

%% Default is least common multiple of all sample times.  
%% Compute the unique sample times
Ts_all = [Tsx;Tsy];
Tuq = unique(Ts_all(Ts_all >= 0));
if (Ts == -1)
    %% Remove the infinite sample times first.
    Tuq(isinf(Tuq)) = [];
    if (max(Tuq) == 0)
        Ts = 0;
    else
        Ts = local_vlcm(Tuq);
        if isempty(Ts)
            %% If model has fixed step size specified use that
            modelSolver = get_param(model,'Solver');
            modelFixedStepSize = get_param(model,'FixedStep');
            if ( ~strcmpi(modelFixedStepSize,'auto') && ...
                    ( strcmp(modelSolver,'ode5') || ...
                    strcmp(modelSolver,'ode4') || ...
                    strcmp(modelSolver,'ode3') || ...
                    strcmp(modelSolver,'ode2') || ...
                    strcmp(modelSolver,'ode1') || ...
                    strcmp(modelSolver,'FixedStepDiscrete')))
                warning(['No sample time found in the model. ',...
                    'Defaulting to fixed step size']);
                Ts = str2num(modelFixedStepSize);
            else
                warning('No sample time found in the model.  Defaulting to 1');
                Ts = 1;
            end
        end

        %% Find the sample times in Tsy to eliminate since they do not
        %% contribute to the overall sample time
        Tsy(find(Tsy>Ts)) = [];
    end
end

%% Linearize without discrete states if the user desires, otherwise perform
%% the discrete linearization if there are discrete states.
if ((Ts == 0)) && (strcmp(options.IgnoreDiscreteStates,'on') || ...
        (all(find(Tsx==0))))
    
    % Remove discrete states
    if any(Tsx)
        warning(['Ignoring discrete states']);
        ix = find(Tsx ~= 0);
        a(ix,:) = [];
        a(:,ix) = [];
        b(ix,:) = [];
        c(:,ix) = [];
        StateName(ix) = [];
    end
    
    P = speye(size(d,1)) - d*E;
    Q = P \ c;
    R = P \ d;
    
    % Close the LFT
    a = a + b * E * Q;
    b = b * (F + E * R * F);
    c = G * Q;
    d = H + G * R * F;
    
else
    [ny,nu] = size(d);
    nxz = size(a,1);
    Tslist = [ Tuq ; Ts ];
    Eslow  = E;
    for k=1:length(Tslist)-1
        % Start with the fastest rate
        ts_current = Tslist(k);
        ts_next    = min(Ts, Tslist(k+1));
        
        xix = find(Tsx == ts_current);
        nix = find(Tsx ~= ts_current);
        
        % Close the fastest loops
        [ix,jx,px] = find(Eslow);
        ux    = ismember(jx, find(Tsy==ts_current));
        Efast = sparse(ix(ux),jx(ux),px(ux),nu,ny);
        
        % And mark them as closed (remove them from interconnection matrix)
        Eslow = Eslow - Efast;
        P = speye(ny) - d*Efast;
        
        % But leave the matrices "full-sized" for later connection 
        c = P \ c;
        d = P \ d;
        a = a + b * Efast * c;
        b = b * (speye(nu) + Efast*d);
        
        % if the target rate is the slowest rate we are done
        if ts_current ~= ts_next
            
            % Otherwise use c2d/d2d/d2c to reach the next rate
            nxfast = length(xix);
            atmp = full(a(xix,xix));
            
            if isinf(ts_current)
                if ts_next ~= 0
                    Phi = eye(size(atmp));
                    Gam = zeros(size(b(xix,:)));
                else
                    Phi = zeros(size(atmp));
                    Gam = zeros(size(b(xix,:)));                    
                end
            else
                sysold = ss(atmp,eye(nxfast),zeros(0,nxfast),zeros(0,nxfast),ts_current);
                if ts_current ~= 0
                    if ts_next ~= 0
                        sysnew = d2d(sysold,ts_next);
                    else
                        sysnew = d2c(sysold);
                    end
                else
                    sysnew = c2d(sysold,ts_next);
                end
                Phi = sysnew.a;
                Gam = sysnew.b;
                
                a(xix,xix) = Phi;
                if length(nix)
                    a(xix,nix) = Gam*a(xix,nix);
                end
                if nu
                    b(xix,:) = Gam*b(xix,:);
                end
            end                
        end
        Tsx(xix) = ts_next;
    end
    
    % Apply analysis input and output selection
    b = b * F;
    c = G * c;
    d = H + G * d * F;
    
end

%% Reorganize the IO due to back propagation
Bnew = b(:,input_ind);
Cnew = c(output_ind,:);
Dnew = d(output_ind,:);
Dnew = Dnew(:,input_ind);

%% Create the linear model
try
    sys = ss(full(a),full(Bnew),full(Cnew),full(Dnew),Ts); 
    %% Set the labels
    sys.InputName = input_name;
    sys.OutputName = output_name;
    sys.StateName = StateName;
catch
    sys = ss([],[],[],[]);
end

%---

function M = local_vlcm(x)
%% VLCM  find least common multiple of several sample times

%% Protect against a few edge cases, remove zeros before computing LCM
x(~x) = [];
if isempty(x), M = []; return; end;

[a,b]=rat(x);
v = b(1);
for k = 2:length(b), v=lcm(v,b(k)); end
d = v;

y = round(d*x);         % integers
v = y(1);
for k = 2:length(y), v=lcm(v,y(k)); end
M = v/d;
