% file: ex_f14s2.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

    delta = [1 0;0 1];
    sclp4_nom = starp(zeros(2,2),starp(F14SIM,K4));
    sclp4_pert = starp(delta,starp(F14SIM,K4));
    ustk = step_tr([0 1 4],[0 1 0],.02,10);
    upedal = step_tr([0 1 4 7 ],[0 1 -1 0],.02,10);
    input = abv(ustk,upedal);

    y4nom = trsp(sclp4_nom,input,14,0.02);
    y4pert = trsp(sclp4_pert,input,14,0.02);

    subplot(211), vplot(sel(y4nom,3,1),'-',sel(y4nom,4,1),...
                    '-.',sel(y4pert,4,1),'--')
    xlabel('Time (seconds)')
    ylabel('Side-slip angle (degrees)')
    title('beta: ideal (solid), actual (dashed-dot),perturbed (dashed)')

    subplot(212), vplot(sel(y4nom,1,1),'-',sel(y4nom,2,1),...
                     '-.',sel(y4pert,2,1),'--')
    xlabel('Time (seconds)')
    ylabel('Roll rate (degrees/sec)')
    title('roll-rate: ideal (solid), actual (dashed-dot),perturbed (dashed)')