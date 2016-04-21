 function [errorStatus, errorString] = sqgeterrorstatusandstring(handles)
  % User Data are not updated here (no SET)
  %   Copyright 1988-2002 The MathWorks, Inc.
  %   $Revision: 1.1 $  $Date: 2002/10/25 22:04:15 $

  AutoGenerateInitCB  = (get(handles.popupSQSource,'Value')==1);
  AutoGenerateInitPT = (~AutoGenerateInitCB)&&(get(handles.popupInitPTSource,'Value')==1);
  StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
  StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);
  
  hfig=handles.sqdtool;
  ud=get(hfig,'UserData');

  errorStr_N ='';
  errorStr_initPT='';
  errorStr_initCB='';
  errorStr_SopCri ='';
  if (StopCriteriaRelTh)
      errorStatus_StopCri = ud.errFlag_editRelTh;
      if (ud.errFlag_editRelTh)
          errorStr_SopCri = ' RELATIVE THRESHOLD,';
      end
  elseif (StopCriteriaMaxIter)
      errorStatus_StopCri = ud.errFlag_editMaxIter;      
      if(ud.errFlag_editMaxIter)
          errorStr_SopCri = ' MAXIMUM ITERATION,';
      end
  else %stopping criterion: RelTh||MaxIter      
      errorStatus_StopCri = ud.errFlag_editRelTh||ud.errFlag_editMaxIter;
      if (ud.errFlag_editRelTh)
          errorStr_SopCri = ' RELATIVE THRESHOLD,';
      end
      if(ud.errFlag_editMaxIter)
          errorStr_SopCri = strcat(errorStr_SopCri,' MAXIMUM ITERATION,');
      end
  end      
  if (AutoGenerateInitCB)
      errorStatus = (ud.errFlag_editTS || ud.errFlag_editNumLevel || errorStatus_StopCri);      
      if (ud.errFlag_editNumLevel)
          errorStr_N = ' NUMBER OF LEVELS,';
      end
      
  else  
      if (ud.errFlag_editInitCB)
             errorStr_initCB = ' INITIAL CODEBOOK,';
      end
      
      if (AutoGenerateInitPT)
          errorStatus_InitPT = 0; %no error
      else
          errorStatus_InitPT = ud.errFlag_editInitPT;
          if (ud.errFlag_editInitPT)
             errorStr_initPT = ' INITIAL PARTITIONS.';
          end
      end          
      errorStatus = (ud.errFlag_editTS || ud.errFlag_editInitCB || ...
                     errorStatus_InitPT || errorStatus_StopCri);
  end
  errorStr_TS ='';
  if (ud.errFlag_editTS)
          errorStr_TS = ' TRAINING SET,';
  end
  errorString=strcat('Invalid', errorStr_TS, errorStr_N, errorStr_initCB, errorStr_initPT, errorStr_SopCri);
  if (errorString(end)==',')
      errorString(end)='.';
  end    
 
% [EOF]
