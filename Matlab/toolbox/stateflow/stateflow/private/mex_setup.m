function errorCode = mex_setup(method, varargin)

% Copyright 2003-2004 The MathWorks, Inc.

	switch method
	case 'create'
		if nargin ~= 3
			error('Bad calling syntax')
		end
		compilerStr    = varargin{1};
		mexOptsPathStr = varargin{2};
		mexOptsFileStr = fullfile(mexOptsPathStr, 'mexopts.bat');
		mexSetupCmd    = ['mex -setup:' compilerStr ' -f ' mexOptsFileStr];
		errorCode      = dos(mexSetupCmd);
		if errorCode == 0
			sf('Private','compilerman', 'set_compiler_info', mexOptsFileStr);
		end
	case 'destroy'
		if nargin ~= 2
			error('Bad calling syntax')
		end
		mexOptsPathStr = varargin{1};
		mexOptsFileStr = fullfile(mexOptsPathStr, 'mexopts.bat');
		sf_delete_file(mexOptsFileStr);
	    sf('Private','compilerman', 'reset_compiler_info');
	otherwise
		error('unknown method');
	end
