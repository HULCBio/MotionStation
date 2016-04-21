function reset_C6701EVM()
%function to reset the C6701 EVM board

% $RCSfile: reset_C6701EVM.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:00:26 $
% Copyright 2001-2003 The MathWorks, Inc.

try
    blk = gcbh;
    boardProc = get_param(blk,'UserData');
    
    if isempty(boardProc),
        % RTW was never run on the model
        % and the user pressed the button
        msg = {'',
            'Reset could not be executed.'
            'Try running RTW prior to using this block.'
        };
        errordlg(msg,'C6701EVM Reset Status', 'modal');
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
    errordlg(msg,'C6701EVM Reset Status', 'modal');
end
clear cc;

%[EOF] reset_C6701EVM.m
