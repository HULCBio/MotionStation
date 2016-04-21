function display(this);
%Display method for the analysis input/output object.

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2004 The MathWorks, Inc.
%% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:34:52 $

%% Display the title string
disp(sprintf('\n    Linearization IOs: \n--------------------------'));  

for ct = 1:length(this)
    
    %% Display the block
    Block = regexprep(this(ct).Block,'\n',' ');
    str1 = sprintf('hilite_system(''%s'',''find'');',Block);
    str2 = 'pause(1);';
    str3 = sprintf('hilite_system(''%s'',''none'');',Block);
    if usejava('Swing') && desktop('-inuse')
        str1 = sprintf('<a href="matlab:%s%s%s">%s</a>',str1,str2,str3,Block);
    else
        str1 = sprintf('%s',Block);
    end
    
    %% Display the current IO blockname
    str = sprintf('Block %s, Port %d is marked with the following properties:',...
        str1,this(ct).PortNumber);
    
    %% Display the properties for various IO combinations
    if strcmpi(this(ct).Type,'in')
        %% For this case the loop opening will always proceed the input
        %% perturbation.
        if strcmpi(this(ct).OpenLoop,'on')
            str = sprintf('%s\n - A Loop Opening',str);
        else
            str = sprintf('%s\n - No Loop Opening',str);
        end
        str = sprintf('%s\n - An Input Perturbation',str);
    elseif strcmpi(this(ct).Type,'out')
        %% For this case the loop opening will always follow the output
        %% measurment.
        str = sprintf('%s\n - An Output Measurement',str); 
        if strcmpi(this(ct).OpenLoop,'on')
            str = sprintf('%s\n - A Loop Opening',str);
        else
            str = sprintf('%s\n - No Loop Opening',str);
        end
    elseif strcmpi(this(ct).Type,'inout')
        %% For this case the loop opening is first, the input perturbation is
        %% second, and then the output measurement is third.
        if strcmpi(this(ct).OpenLoop,'on')
            str = sprintf('%s\n - A Loop Opening',str);
        else
            str = sprintf('%s\n - No Loop Opening',str);
        end
        str = sprintf('%s\n - An Input Perturbation',str);
        str = sprintf('%s\n - An Output Measurement',str); 
    elseif strcmpi(this(ct).Type,'outin')
        %% For this case the output measurement is first, the loop opening
        %% is second, and the input perturbation is third.
        str = sprintf('%s\n - An Output Measurement',str);
        if strcmpi(this(ct).OpenLoop,'on')
            str = sprintf('%s\n - A Loop Opening',str);
        else
            str = sprintf('%s\n - No Loop Opening',str);
        end
        str = sprintf('%s\n - An Input Perturbation',str);
    else
        %% For this case the output measurement is first, the loop opening
        %% is second, and the input perturbation is third.
        if strcmpi(this(ct).OpenLoop,'on')
            str = sprintf('%s\n - A Loop Opening',str);
        else
            str = sprintf('%s\n - No Loop Opening',str);    
        end
    end
    disp(sprintf('%s\n ',str))
end