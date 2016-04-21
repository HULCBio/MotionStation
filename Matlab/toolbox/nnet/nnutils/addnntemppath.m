function addnntemppath
%ADDNNTEMPPATH Add NNT temporary directory to path.

%   $Revision: 1.2 $  $Date: 2002/04/14 21:19:15 $
% Copyright 1992-2002 The MathWorks, Inc.
  
%persistent done
%if isempty(done)
    nntempdir=fullfile(tempdir,'matlab_nnet');
    if ~exist(nntempdir,'dir')
        mkdir(tempdir,'matlab_nnet')
    end
    if isempty(findstr(path,nntempdir))
        path(path,nntempdir);
    end
%    done=1;
%end
