function data = sf_get_icon_data(type)
%
% Reads icon data from file.
%

%   Jay Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9.2.1 $  $Date: 2004/04/15 00:59:33 $

%
% try bitmap first
%
filename = [sf_root,'private',filesep,type,'.bmp'];

if isequal(exist(filename, 'file'), 2),
	try, data = imread(filename,'bmp');
	catch, error(['Problem loading icon for class: ',type]);
	end;
else,
	%
	% try MAT-file next
	%
	filename = [sf_root,'private',filesep,type,'.mat'];
	try, load(filename);
	catch, error(['Problem loading icon for: ',type]);
	end;
end;

