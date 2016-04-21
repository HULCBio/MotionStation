function bfithelp(cmd)
% BFITHELP Displays help for Basic Fitting and Data Statistics
%   BFITHELP('bf') displays Basic Fitting Help  
%   BFITHELP('ds') displays Data Statistics Help  

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.2 $

switch cmd
case 'bf'
	try
       helpview([docroot '/techdoc/math/math.map'], ...
           'basic_fitting_interface' ,'CSHelpWindow'); 
	catch
	   bfitcascadeerr(['Unable to display help for Basic Fitting:' ...
	         sprintf('\n') lasterr ], 'Basic Fitting');
	end

case 'ds' 
	try
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'], ...
            'plotting_basic_stats2' ,'CSHelpWindow'); 
	catch
	   bfitcascadeerr(['Unable to display help for Data Statistics' ...
	         sprintf('\n') lasterr ], 'Data Statistics');
	end
end
