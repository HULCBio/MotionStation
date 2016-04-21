function close_models(iMdls)
%CLOSE_MODELS Closes the sepecfied models.

% Copyright 2003 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $
%  By: Murali Yeddanapudi, 14-May-2003

  nMdls = length(iMdls);
  for i=1:nMdls
    close_system(iMdls{i}, 0);
  end

%endfunction