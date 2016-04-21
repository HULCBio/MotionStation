function outDir = fixquote(inDir)
%FIXQUOTE  Double up any single quotes appearing in a directory name
%   outDir = FIXQUOTE(inDir) turns any instance of a single quote into two
%   single quotes.

% Copyright 1984-2003 The MathWorks, Inc. 

outDir = inDir;
sq = '''';
if findstr(inDir,sq)
    outDir = strrep(inDir,sq,[sq sq]);
end
