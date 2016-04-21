function fcn = slpmloadfunction(cleanup)
%SLPMLOADFUNCTION - utility function that manages load functions
%  for physical modeling clients.  In order to use this
%  functionality, clients should place a function named pmloadfunction
%  on the path.  The function may be a .m or .p file.
  
% Copyright 2003 The MathWorks, Inc.
  
% $Revision: 1.1.6.1 $ $Date: 2003/12/31 19:53:44 $
% Author: Nathan E. Brewton
  ;
  mlock;
  
  %
  % initialize an empty list of functions
  %
  fcns = {};
  
  %
  % gather all load functions
  %
  l_load_pmloadfunctions;
  
  %
  % return a handle to call the load functions function
  %
  fcn  = @l_call_pmloadfunctions;

  function l_load_pmloadfunctions
  %L_LOAD_PMLOADFUNCTIONS - search the path for load functions.
  %  This function is fairly expensive but should only be called
  %  at the beginning of the session or after each clear.
    ;
    %
    % name of the load function
    %
    pmloadfunction = 'pmloadfunction';
    
    %
    % empty set of directories
    %
    directories = {};
    
    %
    % now find all .m and .p files
    %
    directories = cat(1, directories, which([pmloadfunction '.m'], '-all'));
    directories = cat(1, directories, which([pmloadfunction '.p'], '-all'));
  
    %
    % strip off the extensions
    %
    directories = strrep(directories, [pmloadfunction '.m'], '');
    directories = strrep(directories, [pmloadfunction '.p'], '');
    
    %
    % get a unique set of directories as one directory may have
    % both a .m function and a .p function.  unique also
    % sorts directories so our calls are consistent from session
    % to session
    %
    directories = unique(directories);
  
    %
    % cache the current directory
    %
    ret_dir = pwd;
  
    %
    % for each directory
    %
    for i = 1:length(directories)
      try
        %
        % check to see if a load function exists
        %
        if l_check_for_pmloadfunction(directories{i});
          %
          % if so, add a handle to the load function to the list
          % of functions
          %
          l_add_pmloadfunction(directories{i});
        end
      catch
        %
        % in case of error, issue a warning and keep going
        %
        warning(lasterror);
        lasterr('');
      end
    end
    
    %
    % go back to the original directory and exit
    %
    cd(ret_dir);
  
    function hasit = l_check_for_pmloadfunction(directory)
    %L_CHECK_FOR_PMLOADFUNCTION - actually check the contents
    %  of the directory for the load function.  Path caching
    %  can make us think a directory is there when there
    %  isn't one.
      ;
      %
      % get the contents
      %
      contents = dir(directory);
      
      %
      % look for files named pmloadfunction
      %
      files = ~[contents(:).isdir];
      names = {contents(find(files)).name};
    
      %
      % return true if any files bear that name
      %
      hasit = any( strcmp(names, [pmloadfunction '.p']) | ...
                   strcmp(names, [pmloadfunction '.m']) );
    end
  
    function l_add_pmloadfunction(directory)
    %L_ADD_PMLOADFUNCTION - cd to directory and capture the
    %  handle to the load function in that directory
      ;
      cd(directory);
      fcns{end+1} = str2func(pmloadfunction);
    end
  end
  
  function l_call_pmloadfunctions(bd)
  %L_CALL_PMLOADFUNCTIONS - loop through each function
  %  calling it as we go.  bd should be a handle to
  %  a block diagram.  Attempt to call all functions
  %  and collect all errors.  Report them all when done.
    ;
    errors = {};
    for i = 1:length(fcns)
      try
        feval(fcns{i}, bd);
      catch
        errors{end+1} = lasterror;
      end
    end
    
    if ~isempty(errors)
      msg = '';
      for i = 1:length(errors)
        msg = sprintf('%s%s\n', msg, errors{i}.message);
      end
      error('SIMULINK:slpmloadfunction', '%s', msg);
    end
  end
end

% [EOF] slpmloadfunction.m
