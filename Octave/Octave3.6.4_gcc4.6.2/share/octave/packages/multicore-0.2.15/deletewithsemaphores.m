function deletewithsemaphores(fileList)
%DELETEWITHSEMAPHORES  Delete files using semaphors.
%   DELETEWITHSEMAPHORES(FILELIST) deletes the files in cell array FILELIST
%   using semaphores.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%   See also SETFILESEMAPHORE, REMOVEFILESEMAPHORE.

if ischar(fileList)
	fileList = {fileList};
end

for fileNr = 1:length(fileList)
	sem = setfilesemaphore(fileList{fileNr});
	if exist(fileList{fileNr}, 'file')
		delete(fileList{fileNr});
	end
	removefilesemaphore(sem);
end
