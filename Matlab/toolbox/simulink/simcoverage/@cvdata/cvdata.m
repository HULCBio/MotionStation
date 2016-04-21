function varargout = cvdata( varargin )
%CVDATA  Coverage data
%
%   CLASS_ID = cvdata( ID ) Create a test data object for the data contained
%   in the coverage tool internal testdata object ID.
%
%   CLASS_ID = cvdata( LHS, RHS, METRICS ) creates a test data object with the
%   supplied data derived from two other cvdata objects, LHS and RHS.
%
%   See also CVLOAD, CVREPORT, CVTEST, CVSIM, CVSAVE.


%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.9.2.2 $  $Date: 2004/04/15 00:37:05 $

switch nargin
case 0 % display help message
    cvdata.id = 0;
    cvdata.localData = {};
    varargout{1} = class(cvdata,'cvdata');
case 1 % could be create, or id conversion
	switch class(varargin{1})
	case 'double' % create a new test object for the
        if ~cv('ishandle',varargin{1}),
            error('CV object #%d does not exist');
        end
        if cv('get',varargin{1},'.isa')~=cv('get','default','testdata.isa'),
            error('CV object #%d is not a testdata object');
        end
   		cvdata.id = varargin{1};
        cvdata.localData = {};
        cvdata = class(cvdata,'cvdata');
	    varargout{1} = cvdata;
	case 'cvdata'
		varargout{1} = varargin{1};
	otherwise
        error('Bad input argument in cvdata')
	end
case 3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check Arguments
    if ~isa(varargin{1},'cvdata') | ~isa(varargin{2},'cvdata')
        error('First two arguments should be cvdata objects');
    end
    if ~isstruct(varargin{3})
        error('Third argument must be a structure')
    end
    check_metrics_struct(varargin{3})
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create return object
    lhs = varargin{1};
    rhs = varargin{2};
    p.type = '.';
    cvdata.id = 0;
    data.metrics = varargin{3};
    p.subs = 'checksum';
    data.checksum = subsref(lhs,p);
    p.subs = 'startTime';
    data.startTime = earliest_time(subsref(lhs,p),subsref(rhs,p));
    p.subs = 'stopTime';
    data.stopTime = latest_time(subsref(lhs,p),subsref(rhs,p));
    p.subs = 'rootId';
    data.rootId = subsref(lhs,p);
    cvdata.localData = data;
    cvdata = class(cvdata,'cvdata');
	varargout{1} = cvdata;
    
otherwise
    error('Bad calling syntax for cvdata');
end




function check_metrics_struct(metrics)

    metricNames = cv('Private','cv_metric_names','all');

    for i=1:length(metricNames)
        if ~isfield(metrics,metricNames{i})
            error(sprintf('Missing .%s field in supplied data',metricNames{i}));
        end
    end



function str = earliest_time(time1,time2),

    prevErr = lasterr;
    
    try,
        n1 = datenum(time1);
        n2 = datenum(time2);
        if(n1<n2)
            str = time1;
        else
            str = time2;
        end
    catch
        str = '';
        lasterr(prevErr);
    end
    

function str = latest_time(time1,time2),

    prevErr = lasterr;
    
    try,
        n1 = datenum(time1);
        n2 = datenum(time2);
        if(n1>n2)
            str = time1;
        else
            str = time2;
        end
    catch
        str = '';
        lasterr(prevErr);
    end
    

