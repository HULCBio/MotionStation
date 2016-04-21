function str = get_boiler_plate_comment(objectType,objectId)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2.4.1 $  $Date: 2004/04/13 03:12:39 $
	global gMachineInfo gTargetInfo

   if(gTargetInfo.codingSFunction | gTargetInfo.codingRTW)
      str = '';
      return;
   end

SF_CODER_STR='';

SF_CODER_STR=[SF_CODER_STR,sprintf('/*\n')];
		switch(objectType)
		case 'chart'
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Stateflow code generation for chart:\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf(' *    %s\n',sf('FullNameOf',objectId,'/'))];
		case 'machine'
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Stateflow code generation for machine:\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf(' *    %s\n',sf('get',objectId,'.name'))];
		end
SF_CODER_STR=[SF_CODER_STR,sprintf(' * \n')];
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Target Name                          : %s\n',sf('get',gMachineInfo.parentTarget,'target.name'))];
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Stateflow Version                    : %s\n',sf('Version','Number'))];
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Date of code generation              : %s\n',sf('Private','sf_date_str'))];
SF_CODER_STR=[SF_CODER_STR,sprintf(' */\n')];

str = SF_CODER_STR;