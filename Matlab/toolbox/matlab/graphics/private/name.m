function pj = name( pj )
%NAME Method to check or create valid filename.
%   Validate FileName in PrintJob object. If empty, no name passed to PRINT 
%   command, but one is required by the driver, image file formats, we invent 
%   a name and tell the user what it is. Also invent name, but do not tell 
%   user, for temporary PS file created on disk when when printing directly 
%   to output device or for GhostScript conversion.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/10 23:29:07 $

%Generate a name we would use if had to in various circumstances.
if isfigure( pj.Handles{1}(1) )
    objName = ['figure' int2str( pj.Handles{1}(1) )];
else
    objName = get_param(pj.Handles{1}(1),'name');
end

tellUserFilename = 0;
if isempty(pj.FileName)
    if pj.DriverExport & ~strcmp(pj.DriverClass,'MW')
        %These kinds of files shouldn't go to printer, generate file on disk
        pj.FileName = objName;
        tellUserFilename = 1;
        
    else
        %File is going to be sent to an output device by OS or us.
        if strcmp( pj.DriverClass, 'MW' )
            %PC code can handle empty string, but not empty matrix
            filename = '';
        else
            %Going to a file, invent a name
            pj.FileName = tempname;
            pj.PrintOutput = 1;
        end
    end
else
	%Both / and \ are commonly used, but in MATLAB we recognize only \
	pj.FileName = strrep( pj.FileName, '/', filesep );
end

%Append appropriate extension to filename if 
% 1) it doesn't have one, and 
% 2) we've determined a good one
if ~isempty( pj.DriverExt ) & ~isempty( pj.FileName )
    %Could assert that ~isempty( pj.FileName )
    [p,n,e,v] = fileparts( pj.FileName );
    if isempty( e )
        pj.FileName = fullfile( p, [n '.' pj.DriverExt v] );
    end
end

if tellUserFilename
    %Invented name above because of device or bad filename
    if tellUserFilename == 1
        errStr1 = sprintf( 'Files produced by the ''%s'' driver cannot be sent to printer.\n', pj.Driver);
    else
        errStr1 = '';
    end
    
    warning( '%sFile saved to disk under name ''%s''.', errStr1, pj.FileName ) 
end

% Check that we can write to the output file
if ~isempty(pj.FileName)
  % first check if readable file already exists there
  fidread = fopen(pj.FileName,'r');
  didnotexist = (fidread == -1);
  if ~didnotexist
    fclose(fidread);
  end
  % now check if file is appendable (will create file if not there)
  fidappend = fopen(pj.FileName,'a');
  if fidappend ~= -1
    fclose(fidappend);
    % check if we have to delete the created file
    if didnotexist
      % @todo Replace This once we have a flag on delete 
      % for disabling the recycle.
      ov=recycle('off');
      delete(pj.FileName);
      recycle(ov);
    end
  else
    error(['Cannot create output file ''' pj.FileName '''']);
  end
end

%A little business to clear up.
%Now that we found good extension and all that for GS driver,
%we swap in a PS driver and temporary name for later conversion
%to a file whose name we just prettied up.
if strcmp( pj.DriverClass, 'GS' )
    %Remember actual device, get MATLAB to produce PostScript
    %for later conversion by GhostScript
    pj.GhostDriver = pj.Driver;
    if pj.DriverColor
        pj.Driver = 'psc';
    else
        pj.Driver = 'ps';
    end
    pj.GhostName = pj.FileName;
    pj.FileName = [tempname '.ps'];
end

