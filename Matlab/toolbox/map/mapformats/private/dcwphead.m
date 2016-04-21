function [field,varlen,description,narrativefile] =  dcwphead(headerstring)
%DCWPHEAD parses the Digital Chart of the World header string
%

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:23:34 $

% Semicolons are breaks between records
semicindx = findstr(headerstring,';');

% colons are breaks between fields. Textual colons are escaped with backslashes

headerstring = strrep(headerstring,'\:','  '); 		% escaped character
headerstring = strrep(headerstring,'-:;','-,:;'); 	% missing comma in some files
breakindx = findstr(headerstring,':');

dquoteindex = findstr(headerstring,'"');

%
% A laborious way to detect colons within double quotes
% (which should not be interpreted as data breaks). Might
% also have single quotes
%

if (~isempty(dquoteindex)) & (mod(length(dquoteindex),2) == 0)

	for i=1:2:length(dquoteindex)

		for j=1:length(breakindx)

			if breakindx(j) >dquoteindex(i) & breakindx(j) < dquoteindex(i+1)
				breakindx(j) = NaN;
			end

		end %for

	end%for

end%if
doindx = find( ~isnan(breakindx)  );
breakindx = breakindx(doindx);

% the header of the header
description = headerstring( semicindx(1)+1:semicindx(2)-1 ) ;
narrativefile = headerstring( semicindx(2)+1:semicindx(3)-1 ) ;

% keep track of variable length records
varlen = [];

% the header records one at a time
start = semicindx(length(semicindx)-1)+1;
for i=1:length(breakindx)

	blockstr = headerstring(start:breakindx(i)); % the record string

	eqindx = findstr(blockstr,'=');
	commaindx = findstr(blockstr,',');

	namestr = blockstr(1:eqindx-1); % dots cause confusion in structure field names
    namestr = strrep(namestr,'.','_');
	field(i).name = leadblnk(deblank(namestr));

	field(i).type = blockstr(eqindx+1:commaindx(1)-1);
	lenstr = blockstr(commaindx(1)+1:commaindx(2)-1) ;
	if strcmp(strtok(lenstr),'*')==1;   % variable length records in this field
		varlen = [varlen i];
		field(i).length = 0;
	else
		field(i).length = str2num( lenstr );
	end
	field(i).keytype =  blockstr(commaindx(2)+1:commaindx(3)-1) ;
	field(i).description =  blockstr(commaindx(3)+1:commaindx(4)-1) ;
	field(i).VDTname =  blockstr(commaindx(4)+1:commaindx(5)-1) ;
	field(i).TIname =  blockstr(commaindx(5)+1:commaindx(6)-1) ;


	start = breakindx(i)+1;
end
