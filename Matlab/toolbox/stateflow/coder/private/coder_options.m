function result = coder_options(method,varargin)

%% This is a centralized repository of various coder options
%% that drive Stateflow Code Generation.
%% Usage:
%% sfc('coder_options') 
%% without any arguments returns the options strcuture
%% sfc('coder_options','ignoreChecksums') returns the value of this option
%% sfc('coder_options','ignoreChecksums',1) sets the option to 1
%% For more info on the options, look at the comments in this file.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8.16.1 $  $Date: 2004/04/13 03:12:39 $


persistent sfCoderOptions

if(nargin==0)
    method = '';
end

if( strcmp(lower(method),'reset') | ...
    isempty(sfCoderOptions))

    sfCoderOptions.ignoreChecksums = 0;
    sfCoderOptions.debugBuilds = 0;
    sfCoderOptions.inlineThreshold = 10;
    sfCoderOptions.inlineThresholdMax = 10000;
	 sfCoderOptions.ignoreUnresolvedSymbols = 0;
	 sfCoderOptions.dataflowAnalysisThreshold = -1;
	 sfCoderOptions.algorithmWordsizes = [8 16 32 32];
	 sfCoderOptions.targetWordsizes = [8 16 32 32];
end

if(nargin==0 | isempty(method))
    result = sfCoderOptions;
    return;
end

names = fieldnames(sfCoderOptions);
for i=1:length(names)
	if(strcmp(lower(names{i}),lower(method)))
		if(length(varargin)>0)
	   	sfCoderOptions = setfield(sfCoderOptions,names{i},varargin{1});
    	end
    	result = getfield(sfCoderOptions,names{i});
		return;
	end
end

error(sprintf('Invalid option %s passed to coder_options',method));
