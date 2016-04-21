function [mvindex,mdindex,unindex,myindex,uyindex]=mpc_chkindex(model);

%MPC_CHKINDEX Extract indices of MVs,MDs,UDs,MYs,UYs from Model

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2004/04/16 22:09:38 $

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

ingroup=model.InputGroup;
outgroup=model.OutputGroup;

% Model already include the additional measured disturbance which models offsets
[ny,nutot]=size(model);

mvindex=[];
mdindex=[];
myindex=[];
unindex=[];
uyindex=[];

% Convert possible old 6.xx cell format to structure, using mpc_getgroup
ingroup=mpc_getgroup(ingroup);
outgroup=mpc_getgroup(outgroup);

s=fieldnames(ingroup);
for i=1:length(s),
    aux=s{i};
    %eval(sprintf('ind=ingroup.%s;',aux));
    ind=ingroup.(aux);
    switch lower(aux)
        case {'manipulatedvariable','manipulatedvariables','mv','manipulated','input'},
            mvindex=[mvindex;ind(:)];
        case {'measureddisturbance','measureddisturbances','md','measured'},
            mdindex=[mdindex;ind(:)];
        case {'unmeasureddisturbance','unmeasureddisturbances','ud','unmeasured'},
            unindex=[unindex;ind(:)];
        otherwise
            error('mpc:mpc_chkindex:uu',sprintf('Unknown input signal %s',aux))
    end
end

s=fieldnames(outgroup);
for i=1:length(s),
    aux=s{i};
    %eval(sprintf('ind=outgroup.%s;',aux));
    ind=outgroup.(aux);
    switch lower(aux)
        case {'measuredoutputs','measuredoutput','mo','measured'},
            myindex=[myindex;ind(:)];
        case {'unmeasuredoutput','unmeasuredoutputs','uo','unmeasured'},
            uyindex=[uyindex;ind(:)];
        otherwise
            error('mpc:mpc_chkindex:yu',sprintf('Unknown output signal %s',aux))
    end
end

% If some input is not specified, than it is assumed to be a manipulated variable
aux=[mvindex;mdindex;unindex];
aux2=setdiff(1:nutot,aux);
if ~isempty(aux2),
    auxmsg='Assuming unspecified input signals are manipulated variables';
    if nutot>1,
        if verbose & ~isempty(aux),
            fprintf('-->%s\n',auxmsg);
        %else
        %    if ~isempty(mdindex) | ~isempty(unindex),
        %        warning('mpc:mpc_chkindex:mv',auxmsg);
        %    end
        end
    end
    mvindex=[mvindex;aux2(:)];
end

% If some output is not specified, than it is assumed to be a measured output
aux=[myindex;uyindex];
aux2=setdiff(1:ny,aux);
if ~isempty(aux2),
    auxmsg='Assuming unspecified output signals are measured outputs';
    %if ~isempty(aux),
    %    warning('mpc:mpc_chkindex:mo',auxmsg);
    if verbose & ~isempty(aux),
        fprintf('-->%s\n',auxmsg);
    end
    myindex=[myindex;aux2(:)];
end

if ~isempty(intersect(mvindex,mdindex)),
    error('mpc:mpc_chkindex:mvmdind','Manipulated variables and measured disturbances have common indices.')
end
if ~isempty(intersect(mvindex,unindex)),
    error('mpc:mpc_chkindex:mvudind','Manipulated variables and unmeasured disturbances have common indices.')
end
if ~isempty(intersect(mdindex,unindex)),
    error('mpc:mpc_chkindex:mdudind','Measured disturbances and unmeasured disturbances have common indices.')
end
if ~isempty(intersect(myindex,uyindex)),
    error('mpc:mpc_chkindex:myuyind','Measured outputs and unmeasured outputs have common indices.')
end
if isempty(myindex),
    error('mpc:mpc_chkindex:nomy','No measured output was specified.')
end

mvindex=sort(mvindex);
mdindex=sort(mdindex);
unindex=sort(unindex);
myindex=sort(myindex);

% end of mpc_chkindex
