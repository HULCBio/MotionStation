%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Multivariable controller synthesis for the Stewart platform.        % 
%                                                                         %
%        Authors(s) G. W. Wood, J. M. Wendlandt, D. C. Kennedy            %
%                                                                         %
%              Copyright 2002-2003 The MathWorks, Inc.
%                                                                         %
%  This M-script synthesizes a robust multivariable controller for        %
%  the linearized plant model of the Stewart platform. The synthesis      %
%  procedure uses the H_infinity loopshaping design procedure originating %
%  in (1) and is closely related to achieving optimal robustness in the   %
%  gap metric (2).                                                        %
%                                                                         %
%  BE SURE to at least OPEN the mech_stewart_control model ONCE before    %
%  running this script.                                                   %
%                                                                         %    
%  All commands are standard in the mu-Analysis and Synthesis Toolbox.    %
%                                                                         %
%  (1) K. Glover and D. C. McFarlane. Robust stabilization of normalised  %
%  comprime factor plant descriptions with H_infinity bounded             %
%  uncertainty. IEEE Trans. on Automatic Control, 34:821-830, 1989.       %
%                                                                         %
%  (2) T. T. Georgiou and M. C. Smith. Optimal robustness in the gap      %
%  metric. IEEE Trans. on Automatic Control, 35(6):673-687, 1990.         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Linearization
sim('mech_stewart_control_equil'); nomForces = Forces'; % Extract the equilibrating forces. 
[A,B,C,D] = linmod('mech_stewart_control_plant',[],nomForces); % Linearize the model about the equilibrium configuration.
[A,B,C,D] = minreal(A,B,C,D); % Obtain a minimal realization of the linearized model.

% Path check for Mu Toolbox
if isempty(findstr('mutools',path))
    disp('mu-Analysis and Synthesis Toolbox is not installed on your path.');
    return
end

% Synthesis
Kv = daug(-Kd,-Kd,-Kd,-Kd,-Kd,-Kd); % Introduce velocity feedback.
P = pck(A,[B B],C,[D D]); % Pack the state matrices into a model.
P = starp(P,Kv,6,6); % Close the velocity feedback loop.

w = logspace(-1,3,100);
W1 = nd2sys([Kp Ki],[1 0],10); % Loopshaping weight with integral action.
W = daug(W1,W1,W1,W1,W1,W1); % Apply the same weight to each channel.
Pw = mmult(P,W); % Multiply the nominal plant and the loopshaping weight.

wg = frsp(Pw,w);
vplot('liv,lm',vsvd(wg)); % Plot the shaped frequency response to check crossover frequency etc.

[sysk,emax,sysobs] = ncfsyn(Pw,1.1,'ref'); % Synthesis an optimal loopshaping controller.
[Ak,Bk,Ck,Dk] = unpck(sysk); % Unpack the state matrices for the controller.
[Aw,Bw,Cw,Dw] = unpck(W); % Unpack the state matrices for the weight.

% Compute DC gain equalization matrix
[Ap,Bp,Cp,Dp] = unpck(Pw); % Unpack the state matrics of the weighted plant
Pwn = pck(Ap,Bp,[Cp;Cp],[Dp;Dp]); % Augment the weighted plant.
cl = starp(Pwn,sysk,6,6); % Introduce the feedback controller.
[A,B,C,D] = unpck(cl); % Obtain the closed loop state matrices.
D = dcgain(A,B,C,D); % Extract the DC gain matrix.
D = inv(D); % Invert to get the equalization matrix.

% Save the H_inf controller data
save mech_stewart_control_Hinf Aw Bw Cw Dw Ak Bk Ck Dk D nomForces;