%   Script-file for Auto-Iteration.  Simply executes the
%   callbacks that the user would otherwise have done.
%
%   See: dkitgui

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

dkit_tool = gcbf;

set(gguivar('AISTOPBUT'),'visible','on')
[dkit_MAINPB,dkit_CITER,dkit_STEPS] = gguivar('MAINPB','CITER','STEPS');
dkit_MAINPBs = size(dkit_MAINPB,1);
if isinf(dkit_STEPS)
set(gguivar('MESSAGE'),'string',['Starting ' int2str(gguivar('NAUTOIT')) ' Auto-Iterations'])
drawnow
for dkit_i=1:gguivar('NAUTOIT')
    dkit_j = 1;
    while dkit_j<=dkit_MAINPBs & gguivar('INTERUPT')==0
        dkit_tmp = rem(dkit_CITER+dkit_j+dkit_MAINPBs,dkit_MAINPBs);
        if dkit_tmp == 0
            dkit_tmp = dkit_MAINPBs;
        end
	dk_callb = get(dkit_MAINPB(dkit_tmp),'callback');
	% strip out [] for toolhan, add gcf
	dk_callb = stripemp(dk_callb,dkit_tool);
        eval(dk_callb);
        drawnow
        dkit_j = dkit_j + 1;
    end
end
else
set(gguivar('MESSAGE'),'string',['Starting ' int2str(dkit_STEPS) ' Steps'])
drawnow
    dkit_j = 1;
    while dkit_j<= dkit_STEPS & gguivar('INTERUPT')==0
        dkit_tmp = rem(dkit_CITER+dkit_j+dkit_MAINPBs,dkit_MAINPBs);
        if dkit_tmp == 0
            dkit_tmp = dkit_MAINPBs;
        end
	dk_callb = get(dkit_MAINPB(dkit_tmp),'callback');
	% strip out [] for toolhan, add gcf
	dk_callb = stripemp(dk_callb,dkit_tool);
        eval(dk_callb);
        drawnow
        dkit_j = dkit_j + 1;
    end
end
if gguivar('INTERUPT') == 0
    if isinf(dkit_STEPS)
            set(gguivar('MESSAGE'),'string',['Auto-Iteration Complete'])
    else
            set(gguivar('MESSAGE'),'string',[int2str(dkit_STEPS) ' Steps Completed'])
    end
else
    if isinf(dkit_STEPS)
            set(gguivar('MESSAGE'),'string',['Auto-Iteration Stopped'])
    else
            set(gguivar('MESSAGE'),'string',['Auto-Steps Stopped'])
    end
end
clear dkit_i dkit_j dkit_MAINPB dkit_MAINPBs dkit_CITER  dkit_tmp dkit_STEPS
clear dkit_tool
sguivar('STEPS',0,'INTERUPT',0);
set(gguivar('AISTOPBUT'),'visible','off')