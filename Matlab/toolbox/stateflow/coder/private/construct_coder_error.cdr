function construct_coder_error(ids,msg,throwFlag)
% CONSTRUCT_CODER_ERROR(IDS,MSG,THROWFLAG)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/04/15 00:51:40 $

	if(nargin<3)
		throwFlag = 0;
	end

	sf('Private','coder_error_count_man','add');
	if(isempty(msg))
		msg = 'Unexpected internal error';
		throwFlag = 1;
	end

	sf('Private','construct_error',ids,'Coder',msg,throwFlag);
