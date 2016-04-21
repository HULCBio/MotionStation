function [list,defaultindex]=getmacprinters
%GETMACPRINTERS Lists Mac OS X printers and the default.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2002/10/24 02:14:41 $

if ispuma
    printing_plist = '/private/var/spool/printing/com.apple.printing.plist';
    printing_awk_script = [ matlabroot '/toolbox/matlab/uitools/private/getmacprinters.awk' ];

    [s,w] = unix(sprintf('cat %s | awk -f %s | sed -e ''s|.*<string>||'' -e ''s|</string>||''', printing_plist, printing_awk_script));

    if ~isempty(w)
        printers = strread(w, '%[^\n]\n');
    else
        printers = {};
    end
    
    defaultindex = 0;
    for i=2:length(printers)
        if strcmp(printers{i}, '%%default%%')
            defaultindex = i-1;
        end
    end
    
    if defaultindex > 0
        printers(defaultindex+1) = [];
    end
    
    list = printers;
else
    % We've got CUPS!
    
    [fail,w] = unix('lpstat -a | grep -v "not accepting" | sed -e ''s/ accepting requests.*//''');
    if fail
        list = {};
        defaultindex = 0;
    else
        list = strread(w, '%s');
        [fail, w] = unix('lpstat -d | sed -e ''s/system default destination: //''');
        
        if fail
            defaultindex = 0;
        else
            w(end) = ''; % strip trailing CR
            defaultindex = find(strcmp(list, w));
            if (isempty(defaultindex))
                defaultindex = 0;
            end
        end
    end
end
