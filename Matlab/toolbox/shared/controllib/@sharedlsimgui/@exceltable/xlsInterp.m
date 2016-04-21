function outData = xlsInterp(h,headEnd,interpMethod,selectedCols)

% Copyright 2004 The MathWorks, Inc.

numdata = h.numdata;

% find the start row for the numeric data
numericStart = min(find(all(isnan(numdata)')'==false));
if isempty(numericStart) %no numeric data
    outData = [];
    return
end

% the specified header is smaller than the default used by xlsread
if headEnd < numericStart 
    if numericStart>1
        warndlg(['Using the minimum valid header size of ', ...
            num2str(numericStart-1) ' row(s)'], ...
            'Excel File Import','modal')
    end
    thisData = numdata(numericStart:end,selectedCols);
else
    thisData = numdata(headEnd:end,selectedCols); 
end
outData = zeros(size(thisData));
switch lower(interpMethod)
case 'skip rows'
    if min(size(thisData))>=2
        goodRows = find(max(isnan(thisData)')'==0);
    else
        goodRows = find(isnan(thisData)==0);
    end
    outData = thisData(goodRows,:);
case 'skip cells'
    numericcells = ~isnan(thisData);
    allowedLength = min(sum(numericcells));
    if allowedLength>1
         outData = zeros(allowedLength,size(thisData,2));
         if allowedLength<max(sum(numericcells)) 
            msg = sprintf('%s%d',...
              'Imported columns have differing lengths, truncating to the shortest column length of ',...
              allowedLength);
            junk = warndlg(msg,'Excel File Import','modal')
         end
    else
         errordlg('One or more imported columns has less than 2 valid rows, aborting import', ...
            'Excel File Import','modal')
         return
    end
    % dimensions are shortest skipped column x all selected rows
    for col=1:length(selectedCols)
        I = find(numericcells(:,col));
        outData(1:allowedLength,col) = thisData(I(1:allowedLength),col);
    end 
case 'linearly interpolate'
    for col=1:length(selectedCols)
        I = isnan(thisData(:,col));
        if I(1) == 1 | I(end) == 1
            errordlg('Cannot extrpolate over non-numeric data', ...
                'Excel File Import','modal');
            outData = [];
            return
        else
            ind = find(I==0);
            y = thisData(ind,col);
            xraw = 1:size(thisData,1);
            if length(xraw)>=2 && length(ind)>=2
                outData(:,col) = interp1(ind,y,xraw,'linear')';
            else
                errordlg('Cannot interpolate less than 2 points', ...
                    'Excel File Import','modal')
                outData = [];
            end
        end
    end
case 'zero order hold'
    for col=1:length(selectedCols)
        I = isnan(thisData(:,col));
        if I(1) == 1 
            errordlg('Cannot start with non-numeric data. Use header specification to exclude these cells',...
                'Excel File Import','modal');
            return
        else
            temp = thisData(find(~I),col);
            outData(:,col) = temp(cumsum(~I));
        end
    end    
end

if isempty(outData) || min(size(outData))<1
    errordlg('One or more columns has no numeric data, aborting copy', ...
        'Excel File Import','modal')
    outData = [];
    return
end