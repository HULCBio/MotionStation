function [Kp,Ki,Kd] = runtrackmm
% RUNTRACKMM demonstrates using FMINIMAX with Simulink.

% The variables a1, and a2 are shared between RUNTRACKMM and TRACKMMOBJ. 
% The variable yout is shared between RUNTRACKMM, TRACKMMOB, and
% TRACKMMCON.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/01 16:13:07 $

optsim
pid0 = [0.63 0.0504 1.9688];
% a1, a2, yout are shared with TRACKMMOBJ and TRACKMMCON
a1 = 3; a2 = 43; % Initialize plant variables in model
yout = []; % Give yout an initial value
options = optimset('Display','iter',...
    'TolX',0.001,'TolFun',0.001);
pid = fminimax(@trackmmobj,pid0,[],[],[],[],[],[],...
    @trackmmcon,options);
Kp = pid(1); Ki = pid(2); Kd = pid(3);

    function F = trackmmobj(pid)
        % Track the output of optsim to a signal of 1
        % Variables a1 and a2 are shared with RUNTRACKMM.
        % Variable yout is shared with RUNTRACKMM and RUNTRACKMMCON.
        
        Kp = pid(1);
        Ki = pid(2);
        Kd = pid(3);

        % Compute function value
        opt = simset('solver','ode5','SrcWorkspace','Current');
        [tout,xout,yout] = sim('optsim',[0 100],opt);
        F = yout;
    end

    function [c,ceq] = trackmmcon(pid)
        % Track the output of optsim to a signal of 1
        % Variable yout is shared with RUNTRACKMM and
        % TRACKMMOBJ

        % Compute constraints.
        % We know objective function TRACKMMOBJ is called before this
        %  constraint function and so yout is current.
        c = -yout(20:100)+.95;
        ceq=[];
    end
end
