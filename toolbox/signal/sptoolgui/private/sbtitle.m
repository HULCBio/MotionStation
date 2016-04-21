function title_str = sbtitle(fig,selected_data,mode,manualstring)
%SBTITLE Title string of main axes for Signal Browser.
%   title_str = sbtitle(fig,selected_data,mode,manualstring)
%   Inputs:
%      fig - handle of Signal Browser's figure
%      selected_data - structure array with .label and .data fields
%         containing one entry per matrix selected 
%      mode - 'auto' or 'manual'
%      manualstring - title in case mode is manual
%   Outputs:
%      title_str - string vector containing the mainaxes title
%
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.9 $

    if strcmp(mode,'auto')
        if isempty(selected_data)
            title_str = '<no Signals selected>';
        elseif length(selected_data)==1
            if isreal(selected_data.data)
                complex_str = 'real';
            else
                complex_str = 'complex';
            end
            d=size(selected_data.data);
            if any(d==[1 1])
                mat_str = 'vector';
            else
                mat_str = 'matrix';
            end
            FsStr = sprintf('Fs=%.9g',selected_data.Fs);
            title_str = [selected_data.label,...
                    ' (',num2str(d(1)),'x',...
                    num2str(d(2)),' ', complex_str, ', ', FsStr, ')'];
        else
            names = {selected_data.label};
            names(2,:) = {', '};
            names = names(1:end-1);
            title_str = [names{:}];
        end
    else
        title_str = manualstring;
    end

