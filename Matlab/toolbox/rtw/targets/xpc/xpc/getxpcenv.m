function [result, new] = getxpcenv(varargin)
%GETXPCENV Get xPC Target Environment Properties
%
%   GETXPCENV displays the property names, the current property values and
%   the new property value settings of the xPC Target environment in the
%   MATLAB command window.
%
%   ENV=GETXPCENV returns the xPC Target environment in struct ENV. The output
%   in the MATLAB command window is suppressed.
%
%
%   ENV=GETXPCENV('PROPNAME') retuns the value of the associated property
%
%   ENV contains the three fieldnames:
%
%         propname:     property names
%         actpropval:   current property values
%         newpropval:   new property values
%
%   See also SETXPCENV, UPDATEXPCENV, XPCBOOTDISK, XPCSETUP

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $ $Date: 2004/04/08 21:04:15 $

% check if environment mat file exists

try
  load(xpcenvdata);
catch
 % if it does not exist, create and reload it   
 % should be one time only
  xpcinit;
  load(xpcenvdata);
end

%Loop the argument list to retun cell array
if nargin > 0
    for i=1:length(varargin)
        try
            index = strmatch(lower(varargin{i}),lower(propname));
            if isempty(index)
                error(sprintf('%s: Unrecognized property name', varargin{i}));
            end
            if length(index) > 1
                error(sprintf('%s: Ambiguous property name', varargin{i}));
            end
            result{i} = actpropval{index};
            new{i}    = newpropval{index};
        catch
            disp(lasterr);
            result{i} = [];
            new{i}    = [];
            
        end
    end
    return
end

uptodate=cell(1,length(actpropval));
for i=1:length(actpropval)
    if isempty(newpropval{i})
        uptodate{i}='up to date';
    else
        uptodate{i}=newpropval{i};
    end;
end;

if nargout~=0
    result.propname=propname;
    result.actpropval=actpropval;
    result.newpropval=newpropval;
    new=[];
    return;
end;

i=1;
fprintf(2,'\n\n');
fprintf(2,'  xPC Target\n');
fprintf(2,'\n');
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+2;
fprintf(2,'\n');
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+3;
fprintf(2,'\n');
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'\n');
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+2;
fprintf(2,'\n');
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'\n');
fprintf(2,'  xPC Target Embedded Option\n');
fprintf(2,'\n');
fprintf(2,'    %-25s: %-30s  %s\n',propname{22},actpropval{22},uptodate{22});
fprintf(2,'    %-25s: %-30s  %s\n',propname{i},actpropval{i},uptodate{i});i=i+1;
fprintf(2,'\n\n');
