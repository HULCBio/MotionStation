% *****FOR INTERNAL MATHWORKS USE ONLY********
% SFEXIT closes all Stateflow diagrams and exits the Stateflow environment.
% *****FOR INTERNAL MATHWORKS USE ONLY********

%
%   E. Mehran Mestchian
%	Jay R. Torgerson
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.17.2.2 $  $Date: 2004/04/15 01:01:37 $

clear global SF_LOAD_ALL_CHARTS_CLOSED
[m__,x__]=inmem;

SFStateflowPresent__ = 0;

for i__=1:length(x__)
	if strcmp(x__{i__},'sf')
		SFStateflowPresent__ = 1;
	end
end


if SFStateflowPresent__
   cancel__ = sf('Private','closemachines','force');
   if cancel__==0
      switch get(0,'showhidden')
      case 'off'
         set(0,'showhidden','on');
         delete(findobj('Type','figure','Tag','DEFAULT_SFCHART'));
         delete(findobj('Type','figure','Tag','SFCHART'));
         delete(findobj('Type','figure','Tag','SF_SAFEHOUSE'));
         set(0,'showhidden','off');
      case 'on'
         delete(findobj('Type','figure','Tag','DEFAULT_SFCHART'));
         delete(findobj('Type','figure','Tag','SFCHART'));
         delete(findobj('Type','figure','Tag','SF_SAFEHOUSE'));
      end;
      sf('unlock');
      clear('sf');
   end
   clear('cancel__');
end
clear('m__');
clear('x__');
clear('i__');
clear('j__');
clear( 'SFStateflowPresent__' );
clear( 'allInstances__' );
