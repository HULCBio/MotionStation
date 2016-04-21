function [x, nonNumericSamples] = tsarrayFcn(fcn ,time, data, len)
%TSARRAYFCN Utility function for processing arrays containing NaNs
%
% Utililty function used to evaluate functions on a multi-dimensional
% arrays which have NaN values. If NaN values and numeric values in the
% same observations the specified fcn is computed only on the samples with
% numeric values. Otherwise the specified function is computed one column 
% at a time, excluding NaNs in each column which will occur at
% different positions. If the array is multi-dimensional, columns
% generalize to arrays and the functions is called recursively.
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:36:18 $

I = isnan(data);
nonNumericSamples = sum(I(:,:),2);

% Test whether NaN values data extends across entire samples. If so,
% then execute fcn on data
if ~any(nonNumericSamples) || (all(nonNumericSamples==size(I(:,:),2) | nonNumericSamples==0))
    x = feval(fcn{:},time,data);
else
    % One or more samples has NaN valued data combined with numeric
    % data. 
    s = size(data);
    x = zeros([len s(2:end)]);

    for k=1:s(2)
        if ndims(data)>=3
           % Get kth "column" - n1xn3xn4... matrix
           % coldata = data(:,k,:,:,...) with 2nd dimension compressed
           coldata = reshape(data(:,k,:),[s(1) s(3:end)]);
        else
           coldata = data(:,k);
        end
        % Recusively call this fcn to find the fcn of this "column" 
        [thiscolfcn, Jnew] = tsarrayFcn(fcn, time, coldata, len);
        nonNumericSamples = nonNumericSamples|Jnew; % Collect modified samples
        x(:,k,:) = reshape(thiscolfcn(:),size(x(:,k,:)));
    end
end
