function removefilesemaphore(semaphore)
%REMOVEFILESEMAPHORE  Remove semaphore after file access.
%   REMOVEFILESEMAPHORE(SEMAPHORE) removes the semaphore(s) set by function
%   SETFILESEMAPHORE to allow file access for other Matlab processes.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%   See also SETFILESEMAPHORE.

% remove semaphore files
for fileNr = 1:length(semaphore)
	if exist(semaphore{fileNr}, 'file')
		try
			% do not use function deletewithsemaphores.m here!

			% sometimes deletion permission is not given, so try several times to
			% delete the file

			fileDeleted = false;
			warning off MATLAB:DELETE:Permission
			for k=1:5
				lastwarn('');
				delete(semaphore{fileNr});
				if isempty(lastwarn)
					fileDeleted = true;
					break
				end
			end
			warning on  MATLAB:DELETE:Permission

			if ~fileDeleted
				% try one last time with display of warning message
				delete(semaphore{fileNr});
			end

		catch
			% in very very very unlikely cases two processes might have generated
			% the same semaphore file name, in very very very very unlikely cases
			% they might try to delete the file at the same time
			
			% do nothing
		end
	end
end
