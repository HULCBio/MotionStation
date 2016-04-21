function sqplot_stairs(hplotstairs, finalCB, finalPT) 
% hplotstairs=handles.plotStepFcn;
% plots stairs using finalCB and finalPT; sets grid, markers, labels
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:18 $


     size_finalCB = size(finalCB);
     if size_finalCB(1)>1, finalCB=finalCB.'; end
     finalCB_new = [finalCB(1) finalCB finalCB(end) finalCB(end) finalCB(end)];
     if (length(finalPT)>1)
         finalPT_1st = finalPT(1) - (finalPT(2) - finalPT(1));
         finalPT_2nd = finalPT_1st  - (finalPT(1) - finalPT_1st );  
         finalPT_end_1 = finalPT(end) + (finalPT(end) - finalPT(end-1));
         finalPT_end_2 = finalPT_end_1 + (finalPT_end_1 - finalPT(end)); 
     else
         step_size = finalCB(2)-finalCB(1);
         finalPT_1st = finalPT(1) - (step_size);
         finalPT_2nd = finalPT_1st  - (finalPT(1) - finalPT_1st );  
         finalPT_end_1 = finalPT(end) + (step_size);
         finalPT_end_2 = finalPT_end_1 + (finalPT_end_1 - finalPT(end)); 
     end         
     size_finalPT = size(finalPT);
     if size_finalPT(1)>1, finalPT=finalPT.'; end
     finalPT_new = [finalPT_2nd finalPT_1st  finalPT  finalPT(end) finalPT_end_1 finalPT_end_2];
     
     Xgrid_plotStepFcn = get(hplotstairs,'Xgrid');
     Ygrid_plotStepFcn = get(hplotstairs,'Ygrid');
     
     axes(hplotstairs);         
     h_line=stairs(finalPT_new, finalCB_new);
     xlabel('Final Boundary Points (theoretical bounds are -inf & +inf)');
     ylabel('Final Codewords');
     % always call after setting axes, xlabel and ylabel, and plot command
     set(h_line,'ButtonDownFcn',@setdatamarkers);     
     set(hplotstairs,'Xgrid',Xgrid_plotStepFcn);
     set(hplotstairs,'Ygrid',Ygrid_plotStepFcn);
     
     finalCB_LowLimit = finalCB(1) - (finalCB(2)-finalCB(1));
     finalCB_UpLimit  = finalCB(end) + (finalCB(end)-finalCB(end-1));        
     set(hplotstairs,'YLim',[finalCB_LowLimit finalCB_UpLimit]);
     set(hplotstairs,'XLim',[finalPT_new(1)   finalPT_new(end)]);

% [EOF]
