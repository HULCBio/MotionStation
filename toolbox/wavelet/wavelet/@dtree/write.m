function t = write(t,varargin)
%WRITE Write values in DTREE object fields.
%   T = write(T,'data',DATA) writes data for all
%   terminal nodes. In this case DATA contains the
%   data associates to all leaves of T. It can be 
%   an array or a cell array.
%
%   T = write(T,'data',NODE,DATA) writes data for the
%   terminal node NODE.
%
%   Caution: Don't use the DTREE WRITE function!
%
%   See also DISP, GET, READ, SET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:37:38 $

nbin = length(varargin);
k = 1;
while k<=nbin
  argNAME = lower(varargin{k});
  switch argNAME
    case 'data'
        % nextarg  = new data
        % or
        % nextarg = terminal node (index num or depth/pos num)
        % next nextarg = new data
        % out1 = new tree
        %--------------------------------------------------------
        if (k<nbin-1) && ~ischar(varargin{k+2})
            n_rank = istnode(t,varargin{k+1});
            if n_rank ~= 0
                order = treeord(t);
                n_rank = depo2ind(order,n_rank);
                [beg,len,siz]  = fmdtree('tn_beglensiz',t,n_rank);
                sizcfs  = size(varargin{k+2});
                if ~isequal(siz,sizcfs)
                    error('Invalid size for coefs.');
                else
                    t = fmdtree('tn_write',t,n_rank,sizcfs,varargin{k+2});
                    k = k+1;
                end
            else
                error('Invalid node value.');
            end
        else
            if ~iscell(varargin{k+1})
                sizes = fmdtree('tn_read',t,'sizes');
                t = fmdtree('tn_write',t,sizes,varargin{k+1});
            else
                tn = leaves(t);
                n_rank = istnode(t,tn);
                [beg,len,siz]  = fmdtree('tn_beglensiz',t,n_rank);
                for j = 1:length(tn)
                    t = fmdtree('tn_write',t,n_rank(j),siz(j,:),varargin{k+1}{j});
                end
            end
        end

    otherwise
        error('Unknown object field.');
  end
  k = k+2;
end
