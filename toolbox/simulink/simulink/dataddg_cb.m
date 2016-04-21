function [varargout] = dataddg_cb(dlgH, cbName, varargin)

% Copyright 2003-2004 The MathWorks, Inc.

  % Note:
  %  Please try not to add any functionality to this file
  %  This file was initially added to cover for a few missing
  %  pieces of functionality in the Dialog infrastructure.
  %  Since then, that functionality has been added.
  %

  switch (cbName)
   
   case 'preapply_cb'
    dlgH.refresh;
    varargout = {true, ''};    
   case 'refresh_me_cb'
    try 
      a  = DAStudio.EventDispatcher;
      a.broadcastEvent('PropertyChangedEvent', varargin{1});
    catch
      
    end
   otherwise
    error('Unknown case encountered in dataddg_mxArray_cb.m');  
  end
  
%--------------------End of Main function --------------------------------

