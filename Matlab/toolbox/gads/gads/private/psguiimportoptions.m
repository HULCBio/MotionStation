function [selection, model] = psguiimportoptions()
%PSGUIIMPORTOPTIONS GUI helper                  

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2004/01/16 16:50:40 $


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
        'ListSize', [250 200], 'Name', 'Import Pattern Search Options', ...
        'PromptString', 'Select an options structure to import:', ...
        'OKString', 'Import');
if OK == 1
    if value == 1  %default
        selection = 'default';
        options = psoptimset('Display', 'off');
    else
        selection = names{value};
        options = evalin('base', selection);
    end
    %stuff all the fields into the hashtable.
    s = struct(options);
    f = fieldnames(s);
    model = java.util.Hashtable;
    psfieldnames = fieldnames(psoptimset);
    for i = 1:length(f);
        n = f{i};
        if ismember(n, psfieldnames)
            rhs = value2RHS(s.(n));
            % remove string quotes
            q = find(rhs == '''');
            rhs(q) = [];
            model.put(n,rhs);
        end
    end
    setappdata(0,'gads_psearchtool_options_data',options);
end

 %--------------------------------------------------------------------------
 function valid = validOptions(options)
    valid = false;
    psfieldnames = fieldnames(psoptimset);
    ofieldnames = fieldnames(options);

    if all(ismember(psfieldnames, ofieldnames))
        valid = true;
        return;
    end
  

 
    
    
