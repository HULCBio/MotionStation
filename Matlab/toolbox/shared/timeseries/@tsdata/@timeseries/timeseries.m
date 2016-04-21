function this = timeseries(varargin)
%TIMESERIES  Create a time-series object.
%
% Creation:
% ts = tsdata.timeseries(X) creates a time series object where the
% ordinate data is defined by the argument X where the first dimension
% is synchronized with time. X can be a nunmerical array,
% a @datasrc object or an @arrayAdaptor object. The corresponding time
% vector is assumed to be defined by the row index (or the idnex of the
% first dimension if X has more than two dimensions.
%
% ts = tsdata.timeseries(X,T) creates a time series object where the
% ordinate data is defined by X and the time vecotr is defined by the
% argument T. T can be a row or column vector numerical array, @datasrc
% object or @arrayAdaptor object.
%
% ts = tsdata.timeseries(X,'name') or ts = tsdata.timeseries(X,T,'name')
% assignes the Name property of the new time series object to then
% specified string. This string must be a valid property name (i.e., no
% spaces or punctuation marks) or an error will occur. This restriction
% ensures that the time series can be added to a @timeseries collection
% object where ordinate variable names become properties of the @tscollection. 
% If no name is supplied the constructor will supply a default name. 
%
% ts = tsdata.timeseries('name') creates an empty time series object whose
% name is assigned to the specified string.
%
%  See also TIMEMETADATA, DATASRC, PROCESS
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:36:02 $

this = tsdata.timeseries; 
if ~isempty(varargin)
   initialize(this,varargin{:});
end