function [checksum,saveDate] = get_checksum_from_dll(machineName,targetName,objectType,libraryName,chartFileNumber)
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.10.2.1 $

   sfunctionName = [machineName,'_',targetName];
	sfunctionFileName = [sfunctionName,'.', mexext];
   sfunctionExists = exist(sfunctionFileName,'file');
   saveDate = 0.0;

	if (sfunctionExists)
		args{1} = 'sf_get_check_sum';
		if(~isempty(objectType))
			args{end+1} = objectType;
			
			if ~isempty(libraryName)
				args{end+1} = libraryName;
			elseif ~isempty(chartFileNumber)
				args{end+1} = chartFileNumber;
			end
		end	
		try,
			checksum = feval(sfunctionName,args{:});
		catch,
			checksum = zeros(1,4);
		end
      if(nargout>1)
         sfunctionDirInfo = dir(which(sfunctionFileName));
         saveDate = sf_date_num(sfunctionDirInfo.date);
      end
   else
		checksum = zeros(1,4);
      if(nargout>1)
         saveDate = 0.0;
      end
	end


