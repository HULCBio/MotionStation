function varargout = subsref(h, S)
%SUBSREF  Subscripted reference for time series objects.
%
%   The following reference operations can be applied to any 
%   time series object TS: 
%      TS(IND)              select subset of samples defined by the 
%                           numeric or logical array I as a time series
%                           object
%      TS.Fieldname         equivalent to GET(SYS,'Fieldname')
%
%   See also GET, SUBSASGN.
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:36:00 $

if strcmp(S(1).type,'()')
 
    if length(S(1).subs)==1 % 1 dimensional subreferencing only
        if ischar(S(1).subs{1}) %if we have object(:)
              I = 1:getGridSize(h,1);
        elseif ~isempty(S(1).subs{1})
              I = S(1).subs{:};
              if isnumeric(I) && (any(I<1) || any(I>getGridSize(h,1)) || ~isequal(round(I),I))
                  error('Invalid indicies')
              elseif islogical(I)
                  I = find(I);
              end
        else
              tsout = [];
              return
        end       
        
		% @BasicArray getslice without 'cell' returns array size [prod(SizeA)/prod(SampleSize) 1
		% Samplesize] (line 20 @ValueArray/getSlice)
		data = getSlice(h.Data_(1),{I});
        
		% Create output @timeseries
		tsout = tsdata.timeseries;
        time = getSlice(h.Data_(2),{I});
		initialize(tsout,hdsReshapeArray(data,[length(I),h.Data_(1).SampleSize]), time);
        
		% Copy metadata
		set(get(tsout,'timeInfo'),'Units', h.timeInfo.Units, 'Format', h.timeInfo.Format, ...
            'Startdate', h.timeInfo.Startdate);
		tsout.dataInfo = h.dataInfo.copy;
        tsout.qualityInfo = h.qualityInfo.copy;
        
        % Copy quality
        tsout.Quality = getSlice(h.Data_(3),{I});
        
        % Slice events
        etimes = cell2mat(get(h.Events,{'Time'}));
        I = (etimes>=time(1) & etimes<=time(end));
        if any(I)
            addevent(tsout,h.Events(I));
        end
        
        % If there are more subref arguments call the subsref
        % method on the time series with the remaining arguments
        if length(S)>1
            varargout{1} = subsref(tsout,S(2:end));
        else
            varargout{1} = tsout;
        end
    else
        error('timeseries:subsref:scalarind', ...
            'Time series can only be indexed with a single dimension')
    end
else   
    if nargout>0
        varargout = cell(1,nargout);
        varargout{:} = builtin('subsref',h,S);
    else
       builtin('subsref',h,S);
    end 
end




        