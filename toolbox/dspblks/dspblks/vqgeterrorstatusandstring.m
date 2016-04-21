 function [errorStatus, errorString] = vqgeterrorstatusandstring(handles)
  % User Data are not updated here (no SET)
  %   Copyright 1988-2003 The MathWorks, Inc.
  %   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:58 $

  AutoGenerateInitCB  = (get(handles.popupInitCBSource,'Value')==1);
  NoWeighting         = get(handles.popupDistMeasure,'Value')==1;
  StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
  StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);
  
  hfig=handles.vqdtool;
  ud=get(hfig,'UserData');

  errorStr_N ='';
  errorStr_initCB='';
  errorStr_WgtFactor='';
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
      if (ud.errFlag_editNumLevel)
          errorStr_N = ' NUMBER OF LEVELS,';
      end
  else % user-defined initCB  
      if (ud.errFlag_editInitCB)
             errorStr_initCB = ' INITIAL CODEBOOK,';
      end      
  end    
  if (~NoWeighting)  
     if (ud.errFlag_editWgtFactor)
        errorStr_WgtFactor = ' WEIGHTING FACTOR.';
     end
  end
  errorStr_TS ='';
  if (ud.errFlag_editTS)
          errorStr_TS = ' TRAINING SET,';
  end
  errorString=strcat('Invalid', errorStr_TS, errorStr_N, errorStr_initCB, errorStr_WgtFactor, errorStr_SopCri);
  if (errorString(end)==',')
      errorString(end)='.';
  end   
  % when no error, it returns errorString='Invalid'; This is not good; 
  % when no error it should return errorString=''; but it's ok. We will catch it in vqdtool.m
 
errorStatus = (ud.errFlag_editTS                             || ...
              (AutoGenerateInitCB)* ud.errFlag_editNumLevel  || ...
              (~AutoGenerateInitCB)* ud.errFlag_editInitCB   || ...
              (~NoWeighting)* ud.errFlag_editWgtFactor       || ... 
              errorStatus_StopCri);
                  
% [EOF]
