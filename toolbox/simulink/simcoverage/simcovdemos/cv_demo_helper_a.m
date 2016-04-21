function cv_demo_helper_a(step)
%CV_DEMO_HELPER_A - Utilitiy to execute steps in a demonstration
%                   not normally visible to a user.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:07:02 $

    persistent panelH dlgH;
    
    switch(step)
    case 1,
        open_system('sf_car');
        
    case 2,
        panelH = scvdialog('create','sf_car');
        panelH.setCovEnabled(1);
        panelH.updateDlgEnable;
        
    case 3,
        panelH.set_tagged_metric_states({'decision','condition','mcdc','tableExec','sigrange'},[1 1 0 0 0]);
        
    case 4,
        panelH.setDialogFrameIdx(1);
        
    case 5,
        panelH.setDialogFrameIdx(2);
        panelH.setCumulativeReport(1);
        
    case 6,
        scvdialog('applyprops','sf_car',panelH); 
        scvdialog('close',panelH);
        
    case 7,
        sim('sf_car');
        
    case 8,
        open_system('sf_car/User Inputs');
        dlgH = get_param('sf_car/User Inputs','UserData');
        sigbuilder('FigMenu',dlgH,[],'showTab',2);
        
    case 9,
        sim('sf_car');
        
    case 10,
        cvsave('demo_cov_data','sf_car');
        
    case 11,
        close_system('sf_car',0);
        
    case 12,
        open_system('sf_car')
        [testObjs,dataObjs] = cvload('demo_cov_data',1);
        
    case 13,
        panelH = scvdialog('create','sf_car');
        panelH.setCovEnabled(1);
        panelH.updateDlgEnable;
        panelH.set_tagged_metric_states({'decision','condition','mcdc','tableExec','sigrange'},[1 1 0 0 0]);
        panelH.setDialogFrameIdx(2);
        panelH.setCumulativeReport(1);
        scvdialog('applyprops','sf_car',panelH); 
        scvdialog('close',panelH);
        open_system('sf_car/User Inputs');
        dlgH = get_param('sf_car/User Inputs','UserData');
        sigbuilder('FigMenu',dlgH,[],'showTab',3);
        sim('sf_car');
    end
        
