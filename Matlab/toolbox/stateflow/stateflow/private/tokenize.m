function [tokenList,errorStr] = tokenize(rootDirectory,str,description,searchDirectories)

%
%	Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.8.2.2 $  $Date: 2004/04/15 01:01:10 $

	 if(nargin<4)
		searchDirectories = {};
	 end
    if(nargin<3)
		description = str;
	 end
    errorStr = '';
    tokenList = {};
	if(isempty(str))
		return;
	end

	dollarLocs = find(str=='$');
	if(length(dollarLocs)/2~=floor(length(dollarLocs)/2))
		errorStr = sprintf('Mismatched $ characters. Cannot proceed with\nsubstitution in %s.',description);
		return;
	end

	%% since we are modifying the newStr, lets traverse
	%% the string backwards
	if(length(dollarLocs))
		newStr = str;
		for i=(length(dollarLocs)):-2:2
			s = dollarLocs(i-1);
			e = dollarLocs(i);
			evalStr = str(s+1:e-1);
			[prevErrMsg, prevErrId] = lasterr;
			try,
				evalStrValue = evalin('base',evalStr);
				if(~ischar(evalStrValue))
					errorStr = sprintf('$ encapsulated token ''%s'' is not a string in base workspace\nfor substitution in %s.',evalStr,description);
					return;
				end
			catch
			    lasterr(prevErrMsg, prevErrId);
				errorStr = sprintf('Error evaluating $ encapsulated token ''%s'' in base workspace\nfor substitution in %s.',evalStr,description);
				return;
			end

			if(s>1 & e<length(str))
				newStr = [newStr(1:s-1),evalStrValue,newStr(e+1:end)];
			elseif(s==1 & e<length(str))
				newStr = [evalStrValue,newStr(e+1:end)];
			elseif(s>1 & e==length(str))
				newStr = [newStr(1:s-1),evalStrValue];
			else
				% begin and end with a $
				newStr = evalStrValue;
			end
		end
		str = newStr;
	end

	if isunix
		wrongFilesepChar = '\';
		filesepChar = '/';
	else
		wrongFilesepChar = '/';
		filesepChar = '\';
	end

	seps = find(str==wrongFilesepChar);
	if(~isempty(seps))
		str(seps) = filesepChar;
	end

	[tokenType,token] = sf('TokenizePath',str);
	while(~isempty(token))
		quoted = 0;
		if(token(1)=='"')
			token = token(2:end-1);
		end
		% strip the trailing slash
		% (for include directory paths this was causing problems for msvc make)
		if(token(end)=='/' | token(end)=='\')
			token = token(1:end-1);
		end
		if(~isempty(token))
			if(token(1)=='.')
				% definitely a relative path
				token = fullfile(rootDirectory,token);
			else
				if(ispc & length(token)>=2)
					% absolute path son PC start with drive letter or \\(for UNC paths)
					isAnAbsolutePath = (token(2)==':') | (token(1)=='\' & token(2)=='\');
				else
					% absolute paths on unix start with '/'
					isAnAbsolutePath = token(1)=='/';
				end
				if(~isAnAbsolutePath)
					% if it is not an absolute path, check to see if
					% it exists in any of the searchDirectories
					if(length(searchDirectories))
						found = 0;
						for i=1:length(searchDirectories)
							fullToken = fullfile(searchDirectories{i},token);
							if(exist(fullToken))
								found = 1;
								break;
							end
						end
						if(found)
							token = fullToken;
						else
							errorStr = sprintf('%s specified in %s does not exist in any\nof the following search directories:',token,description);
							for i=1:length(searchDirectories)
								errorStr = sprintf('%s\n\t"%s"',errorStr,searchDirectories{i});
							end
							return;
						end
					else
						token = fullfile(rootDirectory,token);
					end
				end
			end
			tokenList{end+1} = token;
      end
		[tokenType,token] = sf('TokenizePath');
	end

