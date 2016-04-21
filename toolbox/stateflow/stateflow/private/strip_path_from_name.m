function [pathName,fileName,fullPathName] = strip_path_from_name(str)

%
%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.5.2.1 $  $Date: 2004/04/15 01:00:46 $

	if isunix
		filesepChar = '/';
	else
		filesepChar = '\';
	end
	seps = find(str==filesepChar);
	if(~isempty(seps))
		fileName = str(seps(end)+1:end);
		if(fileName(1)=='"')
			fileName(1) = [];
		end
		if(fileName(end)=='"')
			fileName(end) = [];
		end
		pathName = str(1:seps(end)-1);
		if(pathName(1)=='"')
			pathName(1) = [];
		end
		if(pathName(end)=='"')
			pathName(end) = [];
		end
	else
		pathName = pwd;
		fileName = str;
		if(fileName(1)=='"')
			fileName(1) = [];
		end
		if(fileName(end)=='"')
			fileName(end) = [];
		end
	end
	fullPathName = [pathName,filesep,fileName];

