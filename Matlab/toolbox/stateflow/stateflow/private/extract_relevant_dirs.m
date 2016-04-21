function newSearchDirectories = extract_relevant_dirs(rootDirectory,searchDirectories,customCodeString)

% Copyright 2004 The MathWorks, Inc.

	[s, e] = regexp(customCodeString, '#include\s*\"[^\"]+\"');

	newSearchDirectories = {};
	includedFiles        = {};
	for i=1:length(s)
		includeStr = customCodeString(s(i):e(i));
		[s1, e1]   = regexp(includeStr, '\"[^\"]+\"', 'once');
		fileName   = includeStr(s1+1:e1-1);
		[includedFile, errorStr] = tokenize(rootDirectory, fileName, 'include file', searchDirectories);
		if(isempty(errorStr))
			includedFiles{end+1} = includedFile{1};
		end
	end
	for i=1:length(includedFiles)
		newSearchDirectories{i} = strip_path_from_name(includedFiles{i});
	end
	newSearchDirectories = ordered_unique_paths(newSearchDirectories);
