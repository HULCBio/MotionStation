function rsimdemo2
%RSIMDEMO2 - Runs ten RSim simulations with different chirp inputs.
%   RSIMDEMO2 illustrates the use of the Rapid Simulation Target (RSim)
%   for running a Simulink model as a compiled simulation using new
%   signal data that is read from a .mat file and used in a From File 
%   block.
%
%   In this example, we create a set of chirp signals that are used as 
%   input simulation data for a series of RSim compiled simulations.
%
%   By running 5 separate simulations, we sweep the frequency
%   range from 4 rads/sec to nearly 1000 rads/sec.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $

  %-----------------------------------------------------------%
  % Check for UNC directory on Windows or under MATLABROOT    %
  % on all platforms to avoid corrupting product directories. %
  %-----------------------------------------------------------%
  rtw_checkdir;

  % The MAT-File rsim_tfdata.mat is required in the local directory.
  if ~isempty(dir('rsim_tfdata.mat')),
    delete('rsim_tfdata.mat');
  end
  str1 = fullfile(matlabroot,'toolbox','rtw','rtwdemos','rsimdemos','rsim_tfdata.mat');   
  str2 = ['copyfile(''', str1, ''',''rsim_tfdata.mat'',''writable'')'];
  eval(str2);
  
  % Prevent overwriting user's variables
  w_true = evalin('base','exist(''w'')');
  zeta_true = evalin('base','exist(''zeta'',''var'')');
  if w_true | zeta_true
    msg = ['Please SAVE and CLEAR your variables ''w'' and ''zeta'' before ',...
	   'running rsimdemo1 or rsimdemo2'];
    error(msg)
  end
  
  % Load the model "rsimtfdemo" if it isn't already loaded
  openModels = find_system('SearchDepth',0,'Name','rsimtfdemo');
  if isempty(openModels)
    open_system('rsimtfdemo')
  end
  pause(.25);
  
  % Transfer function parameters used in this demonstration.
  
  evalin('base','w = 70;')
  evalin('base','zeta = 0.1;')
  
  % Build the RSim executable using the default template 
  % makefile for your compiler.
  make_rtw
  
  % Set up a time vector and an initial frequency vector.
  % The time vector has 4096 points in the event we want
  % to do windowing and spectral analysis on simulation results.
  dt = .001;
  nn = [0:1:4095];
  t = dt*nn; [m,n] = size(t);
  wlo = 1; whi = 4; 
  omega = [wlo:((whi-wlo)/n):whi - (whi-wlo)/n];
  
  % Create 5 sets of signal data called
  % sweep1.mat, sweep2.mat, and so on.
  disp('Creating .mat files with chirp data.')
  figure
  for i = 1:5
    wlo = whi; whi = 3*whi; % keep increasing frequencies
    omega = [wlo:((whi-wlo)/n):whi - (whi-wlo)/n];
    % in a real application we recommend shaping the chirp
    % using a windowing function (hamming or hanning window, etc.)
    % This example does not use a windowing function.
    u      = sin(omega.*t);
    tudata = [t;u];
    % at each pass, save one more set of tudata to the next
    % .mat file.
    savestr = strcat('save sweep',num2str(i),'.mat tudata');
    eval(savestr)
    % display each chirp. Note that this is only input data.
    % Simulations have not been run yet.
    plot(t,u)
    pause(0.3)
  end
  
  % Run the RSim compiled simulation using new signal data to
  % replace the original signal data (rsim_tfdata.mat) with 
  % the files sweep1.mat, sweep2.mat, and so on. 
  disp('Starting batch simulations.')
  for i = 1:5
    % Bang out and run the next set of data with RSim
    runstr = strcat('!',pwd,filesep,'rsimtfdemo -f rsim_tfdata.mat=sweep',num2str(i),'.mat');
    runstr = strcat(runstr,' -v -tf 4.096');
    eval(runstr);
    
    % Load the data to MATLAB and plot the results.
    load rsimtfdemo.mat
    plotstr = strcat('subplot(5,1,',num2str(i),');');
    eval(plotstr);
    plot(rt_tout, rt_yout); axis([0 4.1 -3 3]);
  end
  zoom on
  % cleanup
  evalin('base','clear w zeta')
  disp('This example illustrates a sequence of 5 plots. Each plot shows')
  disp('the simulation results for the next frequency range. Using your')
  disp('mouse, zoom in on each signal to observe signal amplitudes.')
  
%endfunction rsimdemo2

% [EOF] rsimdemo2.m
