function cv_demo_helper_b(step)
%CV_DEMO_HELPER_B - Utilitiy to execute steps in a demonstration
%                   not normally visible to a user.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:07:03 $

    persistent stateId stateCvId;
    
    switch(step)
    case 1,
        open_system('cv_intersect_rectangles')
        stateId = sf('find','all','state.name','rct_intersect');
        sf('Open',stateId);
        
    case 2,
        set_param('cv_intersect_rectangles/Level','Value','0');
        sim('cv_intersect_rectangles');
    
    case 3,
        stateCvId = cv('find','all','slsfobj.handle',stateId,'slsfobj.name','rct_intersect');
        cv('SlsfCallback','reportLink',stateCvId);
    
    case 4,
        set_param('cv_intersect_rectangles/Level','Value','1');
        sim('cv_intersect_rectangles');
        cv('SlsfCallback','reportLink',stateCvId);
    
    case 5,
        set_param('cv_intersect_rectangles/Level','Value','2');
        sim('cv_intersect_rectangles');
        cv('SlsfCallback','reportLink',stateCvId);
    
    case 6,
        close_system('cv_intersect_rectangles',0)

    end
        
