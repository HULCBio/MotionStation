function mpcdesign_callback(model, varargin)

% Callback for the 'openfcn' of the double click start button on 
% each MPC Simulink demo

% Copyright 2004 The MathWorks, Inc.

if strcmp(get_param(gcs, 'SimulationStatus'),'stopped')
    switch model
        case 'mpclinearization'
            if ~license('test','Simulink_Control_Design')  
                model = ss(0,1,1,0);
                mpcobj = mpc(model,1);
                assignin('base','mpcobj',mpcobj);
                mpc_mask('open',gcs,[],'mpclinearization/MPC Controller1','mpcobj');
            else  
                mpc_mask('open',gcs,[],'mpclinearization/MPC Controller','');
            end
        case 'TMPdemo'
            load MPCtmpdemo;
            assignin('base','MPC1',MPC1);
            mpctmpinit; % Intialize LTI objects
            mpc_mask('open',gcs,[],'TMPdemo/MPC Controller','MPC1')            
    end
end





