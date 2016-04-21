function [Kp,Ki,Kd] = runtracklsq
% RUNTRACKLSQ demonstrates using LSQNONLIN with Simulink.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/01 16:13:06 $

optsim                       % Load the model
pid0 = [0.63 0.0504 1.9688]; % Set initial values
a1 = 3; a2 = 43;             % Initialize plant variables in model
options = optimset('LargeScale','off','Display','iter',...
      'TolX',0.001,'TolFun',0.001);
pid = lsqnonlin(@tracklsq, pid0, [], [], options);
Kp = pid(1); Ki = pid(2); Kd = pid(3); 

    function F = tracklsq(pid)
        % Track the output of optsim to a signal of 1
        
        % Variables a1 and a2 are shared with RUNTRACKLSQ
        Kp = pid(1);
        Ki = pid(2);
        Kd = pid(3);

        % Compute function value
        simopt = simset('solver','ode5','SrcWorkspace','Current');  % Initialize sim options
        [tout,xout,yout] = sim('optsim',[0 100],simopt);
        F = yout-1;

    end
end

