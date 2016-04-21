## PKG_ADD:# Run this only if the package is installed
## PKG_ADD:if (! exist (fullfile (fileparts (mfilename ("fullpath")), "inst"), "dir"))
## PKG_ADD:  dirlist= {"Utilities","DDGOX","ThDDGOX","QDDGOX","METLINES","DDGOXT"};
## PKG_ADD:
## PKG_ADD:  for ii=1:length(dirlist)
## PKG_ADD:     addpath ( [ fileparts( mfilename("fullpath")) "/" dirlist{ii}])
## PKG_ADD:  end
## PKG_ADD:
## PKG_ADD:  __gmsh = file_in_path (EXEC_PATH, "gmsh");
## PKG_ADD:  if (isempty (__gmsh))
## PKG_ADD:    __gmsh = file_in_path (EXEC_PATH, "gmsh.exe");
## PKG_ADD:    if (isempty (__gmsh))
## PKG_ADD:      warning ("gmsh does not seem to be present some functionalities will be disabled");
## PKG_ADD:    endif
## PKG_ADD:  endif
## PKG_ADD:  clear __gmsh;
## PKG_ADD:
## PKG_ADD:  __dx = file_in_path (EXEC_PATH, "dx");
## PKG_ADD:  if (isempty (__dx))
## PKG_ADD:    __dx = file_in_path (EXEC_PATH, "dx.exe");
## PKG_ADD:    if (isempty (__dx))
## PKG_ADD:      warning ("dx does not seem to be present some functionalities will be disabled");
## PKG_ADD:    endif
## PKG_ADD:  endif
## PKG_ADD:  clear __dx;
## PKG_ADD:end

## PKG_DEL:# Run this only if the package is installed
## PKG_DEL:if (! exist (fullfile (fileparts (mfilename ("fullpath")), "inst"), "dir"))
## PKG_DEL:  dirlist= {"Utilities","DDGOX","ThDDGOX","QDDGOX","METLINES","DDGOXT"};
## PKG_DEL:
## PKG_DEL:  for ii=1:length(dirlist)
## PKG_DEL:     rmpath ( [ fileparts( mfilename("fullpath")) "/" dirlist{ii}])
## PKG_DEL:  end
## PKG_DEL:end

