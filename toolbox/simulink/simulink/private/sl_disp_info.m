function sl_disp_info(iOkayToPushNags, iMsg, iMdl, iVerbose)

% Copyright 2004 The MathWorks, Inc.

  if iVerbose
    if iOkayToPushNags,
      loc_push_nag('Info', iMsg, iMdl);
    end    
    disp(['### ', iMsg]);
  end
  
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loc_push_nag(iType, iMsg, iMdl)

  nag = create_nag('Simulink', iType, ...
                   'Model Reference Target Update', ...
                   iMsg, iMdl);
  slsfnagctlr('Naglog', 'push', nag);

%endfunction

