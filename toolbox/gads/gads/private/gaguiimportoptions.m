function [selection, model] = gaguiimportoptions()
%GAGUIIMPORT GUI helper                  

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/03/09 16:15:47 $


selection = '';
model = '';
whoslist =evalin('base','whos');
names = {'default options'};

for i = 1:length(whoslist)
    if strcmp(whoslist(i).class, 'struct') && strcmp(num2str(whoslist(i).size), '1  1')
        s = evalin('base', whoslist(i).name);
        if validOptions(s) 
            names{end + 1 } = whoslist(i).name;
        end
    end
end
   
[value, OK] = listdlg('ListString', names, 'SelectionMode', 'Single', ...
        'ListSize', [250 200], 'Name', 'Import GA Options', ...
        'PromptString', 'Select an options structure to import:', ...
        'OKString', 'Import');
if OK == 1
    if value == 1  %default
        selection = 'default';
        options = gaoptimset('Display', 'off');;
    else
        selection = names{value};
        options = evalin('base', selection);
    end
    %stuff all the fields into the hashtable.
    s = struct(options);
    f = fieldnames(s);
    model = java.util.Hashtable;
    gafieldnames = fieldnames(gaoptimset);
    for i = 1:length(f);
        n = f{i};
        if ismember(n, gafieldnames)
            rhs = value2RHS(s.(n));
            % remove string quotes
            q = find(rhs == '''');
            rhs(q) = [];
            model.put(n,rhs);
        end
    end
    setappdata(0,'gads_gatool_options_data',options);
 end

 %--------------------------------------------------------------------------
 function valid = validOptions(options)
    valid = false;
    gafieldnames = fieldnames(gaoptimset);
    ofieldnames = fieldnames(options);
    if all(ismember(gafieldnames, ofieldnames))
        valid = true;
        return;
    end
 
    
    
