function out=execute(c, varargin)
%EXECUTE generates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:23 $

out = [];

if ~rgsf( 'is_parent_valid', c )
		[validity, errMsg] = rgsf( 'is_parent_valid', c );
		compInfo = getInfo( c );
		status(c, sprintf('%s error: this component %s',compInfo.Name, errMsg) ,1);
	return;
end
out=execute(rptproptable,c,varargin{:});