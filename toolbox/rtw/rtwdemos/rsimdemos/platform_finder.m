function platform_finder(gui_choice)

origpath = pwd;
platform = computer;
dir_name = lower(platform);
if strcmp(dir_name,'hp700') | strcmp(dir_name,'ibm_rs')
  msgbox('The Rapid Simulation Target is not supported for use on this platform',...
	'Rapid Simulation Target','warn')
  return
end
switch gui_choice
case ''
  % Used when model is first opened to check if it is on a supported platform
case 'matlab_gui'
  chk = dir('rsim_rtp_struct.mat');   
  if isunix
    chk_exe = dir('rsim_param_tuning');
  elseif ispc
    chk_exe = dir('rsim_param_tuning.exe');
  end
  if ~isempty(chk) & ~isempty(chk_exe)
	disp('% ----- STEP 4: Opening the MATLAB RSIM GUI Demo ----- %')
	disp('>>rsim_gui(''rsim_rtp_struct.mat'')')                                                                                         
	rsim_gui('rsim_rtp_struct.mat')                                                                                                     
  else                                                                                                                                
	msgbox('Please run the Demo sequentially by first executing steps 1 through 3.',...
	  'Demo Warning','warn')                              
  end                                
case 'standalone_gui'
%   if strcmp(dir_name,'ibm_rs')
% 	msgbox('The MATLAB C\C++ Graphics Library is not supported for use on this platform'... 
% 	  ,'Rapid Simulation Target','warn')
% 	return
%   end
  cd(fullfile(matlabroot,'toolbox','rtw','rtwdemos','rsimdemos','rsim_gui',dir_name));
  txt = {'% ----- Opening the standalone GUI specific to this platform ----- % ';...
	  'This GUI looks like the MATLAB RSIM GUI Demo.';...
	  'The difference is that this GUI can be executed without MATLAB. It was'; ...
	  'created using the MATLAB C\C++ Graphics Library and the following command:';...
	  '>>mcc -B sgl rsim_gui.m'; ...
	  '';...
	  '% ------- End of Rapid Simulation Target Demo ------- %'};
  hint = {'The standalone version of the MATLAB GUI will be unable to locate the ';...
      'generated MAT-file (rsim_rtp_struct.mat) and the RSIM executable ';...
	  '(rsim_param_tuning) in your current MATLAB working directory. ';...
	  '';...
	  'Please use the ''Load Executable'' option under the Executable menu and the ';...
	  '''Load MAT-file'' option under the MAT-File menu in the standalone GUI to ';...
	  'load the files into the GUI.';...
	  '';...
	  'The files can be found in your current MATLAB working directory where they ';...
	  'were generated: ';...
      '';...
      origpath};
  if strcmp(dir_name,'pcwin')
	disp(char(txt))
    h = helpdlg(char(hint),'Rapid Simulation Target');
    uiwait(h)
	!rsim_gui &	
  else
	disp(char(txt))
	h = helpdlg(char(hint),'Rapid Simulation Target');
    uiwait(h)
    !./rsim_gui &;
  end
  cd(origpath);
end

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/05/16 14:18:53 $
