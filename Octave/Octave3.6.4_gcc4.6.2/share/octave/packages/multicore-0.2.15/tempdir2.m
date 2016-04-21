function tempDir2Out = tempdir2
%TEMPDIR2  Return temporary directory.
%		DIR = TEMPDIR2 returns a temporary directory. If the username is
%		contained in the directory returned by function TEMPDIR, the directory
%		<TEMPDIR>/MATLAB is returned. Otherwise, the directory
%		<TEMPDIR>/<USERNAME>/MATLAB is returned.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%		See also USERTEMPDIR, GETUSERNAME.

persistent tempDir2

if isempty(tempDir2)
	tempDir2 = tempdir;
	tempDir2 = fullfile(tempDir2, [getusername '@' gethostname], 'MATLAB');
	if ~exist(tempDir2, 'dir')
		mkdir(tempDir2);
	end
end
tempDir2Out = tempDir2;
