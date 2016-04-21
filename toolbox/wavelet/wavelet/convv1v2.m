function [t,d] = convv1v2(t,d)
%CONVV1V2 Convert Wavelet Toolbox Data Structures.
%
%   T = CONVV1V2(T,D) converts V1 Data Structures
%   to V2 Data Structures. The output T is a wptree object.
%
%   [T,D] = CONVV1V2(T) converts V2 Data Structures
%   to V1 Data Structures. The input T is a wptree object.
%

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Jul-99.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:39:58 $

% Check arguments.
%-----------------
nbIn  = nargin;
nbOut = nargout;
nbarg = nargin + nargout;
switch nbIn
    case 0 , 
    case {1,2}
        if nbarg~=3
            error('Invalid number of inputs or outputs!');
        end
    otherwise , error('Too many input arguments.');
end

% Read tree parameters.
%----------------------
order  = treeord(t);
depth  = treedpth(t);
an_old = allnodes(t);
tn_old = leaves(t);

switch nbIn
  case 1
    % Read new data structures.
    %--------------------------
    x = wpcoef(t,0);
    [wavName,entName,entPar] = get(t,'wavName','entName','entPar');
    ento = read(t,'ento',an_old);

    % Create old data structures.
    %----------------------------
    switch order
      case 2 , funcName = 'wpdec';
      case 4 , funcName = 'wpdec2';
    end
    [t,d] = feval(funcName,x,depth,wavName,entName,entPar);
    tn_new = leaves(t);
    n2m = setdiff(tn_old,tn_new);
    for j = 1:length(n2m)
        [t,d] = wpjoin(t,d,n2m(j));
    end
    d = wdatamgr('write_ento',d,ento,an_old);

  case 2
    % Read old data structures.
    %--------------------------
    x = wpcoef(t,d,0);
    wavName = wdatamgr('read_wave',d);
    [entName,entPar] = wdatamgr('read_tp_ent',d);
    ento = wdatamgr('read_ento',d,an_old);

    % Create new data structures.
    %----------------------------
    t = wptree(order,depth,x,wavName,entName,entPar);
    tn_new = leaves(t);
    n2m = setdiff(tn_old,tn_new);
    for j = 1:length(n2m)
        t = wpjoin(t,n2m(j));
    end
    write(t,'ento',ento,an_old);
end
