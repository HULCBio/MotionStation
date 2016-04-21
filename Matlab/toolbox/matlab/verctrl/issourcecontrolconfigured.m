function [config, system] = issourcecontrolconfigured
%ISSOURCECONTROLCONFIGURED Determines if revision control is setup.
%   ISSOURCECONTROLCONFIGURED Checks if a version control system 
%   has been specified.  
%
%   ISSOURCECONTROLCONFIGURED returns 1 if source control is configured
%   and 0 otherwise.

%   Copyright 1999-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $   $Date: 2002/04/15 03:17:12 $

if (strcmpi(cmopts, 'none'))
	config = 0;
    system = '';
else
	config = 1;
    if (ispc) % For backward compatibility reasons.
        sc = cmopts;
        if (strcmpi(sc, 'Microsoft Visual SourceSafe'))
            system = 'sourcesafe';
        elseif (strcmpi(sc, 'ClearCase'))
            system = 'clearcase';
        elseif (strcmpi(sc, 'RCS'))
            system = 'rcs';
        elseif (strcmpi(sc, 'CVS'))
            system = 'cvs';
        elseif (strcmpi(sc, 'PVCS Source Control'))
            system = 'pvcs';
        else
            system = '';
            config = 0;
        end
    else
        system = cmopts;
    end    
end