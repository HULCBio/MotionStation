function uddObj = get_informer

% Copyright 2003 The MathWorks, Inc.

    persistent infrmObj;
    
    if isempty(infrmObj)
        infrmObj = DAStudio.Informer;
        infrmObj.mode = 'ClickMode';
    end

    pause(1);
    infrmObj.position = [10 600 125 400];
    if (infrmObj.visible == 0)
        infrmObj.visible = 1;
    end
 
    uddObj = infrmObj;
    
