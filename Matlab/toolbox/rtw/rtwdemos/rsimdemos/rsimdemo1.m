function rsimdemo1
%RSIMDEMO1 - Runs ten RSim simulations while altering damping coefficient.
%   RSIMDEMO1 illustrates the use of the Rapid Simulation Target (RSim)
%   for running a Simulink model as a compiled simulation using new
%   parameter data that is read from a .mat file.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.16 $
% 

  %-------------------------------------------------------------------%
  % Check for UNC directory on Windows or under MATLABROOT on all     %
  % platforms to avoid corrupting product/project directories.        %
  %-------------------------------------------------------------------%
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
  

  % 0pen the Simulink model "rsimtfdemo" if it isn't already loaded
  openModels = find_system('SearchDepth',0,'Name','rsimtfdemo');
  if isempty(openModels)
    open_system('rsimtfdemo')
  end
  pause(.25);
  
  % create 10 parameters sets and save each set to 
  % files called: params1.mat, params2.mat, ...
  evalin('base','w = 70;')
  evalin('base','zeta = 1.0;')
  disp('Building compiled RSim simulation.')
  make_rtw
  
  disp('Creating rtP data files')
  for i=1:10
    % extract current rtP structure using new damping factor.
    [rtpstruct]=evalin('base','rsimgetrtp(''rsimtfdemo'');');
    savestr = strcat('save params',num2str(i),'.mat rtpstruct');
    eval(savestr)
    evalin('base','zeta = zeta - .1;');   
  end
  disp('Finished creating parameter data files.')
  
  % run 10 RSim simulations using new parameter sets
  % and plot the results
  figure
  for i=1:10
    % bang out and run a simulation using new parameter data
    runstr = ['!',pwd,filesep, 'rsimtfdemo -p params',num2str(i),'.mat', ' -v'];
    eval(runstr)
    
    % load simulation data into MATLAB for plotting.
    load rsimtfdemo.mat; 
    axis([0 1 0 2]);
    plot(rt_tout, rt_yout)
    hold on
  end
  
  % cleanup
  evalin('base','clear w zeta')
  disp('This RSim demonstration has completed 10 simulations while using')
  disp('a new damping factor for each simulation.')
  
%endfunction rsimdemo1


% [EOF] rsimdemo1.m
