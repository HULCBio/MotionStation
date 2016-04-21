function reset_C6416DSK()
% reset the C6416 DSK board

% $RCSfile: reset_C6416DSK.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:28:35 $
% Copyright 2001-2003 The MathWorks, Inc.

try
    blk = gcbh;
    boardProc = get_param(blk,'UserData');
    
    if isempty(boardProc),
        % RTW was never run on the model
        % and the user pressed the button
        msg = {'',
            'Reset could not be executed.'
            'You must do an RTW build prior to using this block.'
        };
        errordlg(msg,'C6416DSK Reset Status', 'modal');
    else
        warnState = warning;
        warning off;
        cc=ccsdsp('boardnum', boardProc(1), 'procnum', boardProc(2));
        cc.reset;
        warning(warnState);
    end
catch
    msg = {'',
        'Reset could not be executed.'
    };
    errordlg(msg,'C6416DSK Reset Status', 'modal');
end
clear cc;

%[EOF] reset_C6416DSK.m
