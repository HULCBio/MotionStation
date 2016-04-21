function [y,y2] = mulresp(fun,a,b,c,d,t,nargo,bodeflag);
%MULRESP Multivariable response.
%       [Y,Y2] = MULRESP('fun',A,B,C,D,T,NARGO,BODEFLAG)

%       Andrew Grace  7-9-90
%       Revised ACWG 6-21-92
%       Revised CMT 12-13-93
%       Revised AFP 9-13-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:53 $

[nrows,ncols] = size(d);

PERC_OFFSET_L = 2*0.09;
PERC_OFFSET_R = 2*0.045;
PERC_OFFSET_B = PERC_OFFSET_L;
PERC_OFFSET_T = PERC_OFFSET_R;
if nrows > 2
  PERC_OFFSET_T = 0.9*PERC_OFFSET_T;
  PERC_OFFSET_B = 0.9*PERC_OFFSET_B;
end
if ncols > 2
  PERC_OFFSET_L = 0.9*PERC_OFFSET_L;
  PERC_OFFSET_R = 0.9*PERC_OFFSET_R;
end
% For this to work the default axes position must be in normalized coordinates
fig = gcf;
def_pos = get(fig,'DefaultAxesPosition');
if nargo==0
  delete(findobj(fig,'Type','axes'))
  kids = [];
  xlab = '';
  ylab = '';
  for i=1:ncols % Loop over inputs
    for j=1:nrows % Loop over outputs
      % Compute position of axis.
      row = nrows-j; col = i-1;
      col_offset = def_pos(3)*(PERC_OFFSET_L+PERC_OFFSET_R)/ ...
                        (ncols-PERC_OFFSET_L-PERC_OFFSET_R);
      row_offset = def_pos(4)*(PERC_OFFSET_B+PERC_OFFSET_T)/ ...
                        (nrows-PERC_OFFSET_B-PERC_OFFSET_T);
      totalwidth = def_pos(3) + col_offset;
      totalheight = def_pos(4) + row_offset;
      width = totalwidth/ncols*(max(col)-min(col)+1)-col_offset;
      height = totalheight/nrows*(max(row)-min(row)+1)-row_offset;
      position = [def_pos(1)+min(col)*totalwidth/ncols ...
                  def_pos(2)+min(row)*totalheight/nrows ...
                  width height];
      if width <= 0.5*totalwidth/ncols
        position(1) = def_pos(1)+min(col)*(def_pos(3)/ncols);
        position(3) = 0.7*(def_pos(3)/ncols)*(max(col)-min(col)+1);
      end
      if height <= 0.5*totalheight/nrows
        position(2) = def_pos(2)+min(row)*(def_pos(4)/nrows);
        position(4) = 0.7*(def_pos(4)/nrows)*(max(row)-min(row)+1);
      end

      set(fig,'DefaultAxesPosition',position)
      if strcmp(get(fig,'nextplot'),'replace'), set(fig,'nextplot','add'), end
      axes % Create an axes at that position

      if ~isempty(c), cj = c(j,:); end
      if ~isempty(d), dj = d(j,:); end
      feval(fun,a,b,cj,dj,i,t); % Rely on autoplotting
      if i==1,
         xlab = get(get(gca,'XLabel'),'String');
         ylab = get(get(gca,'YLabel'),'String');
      end

      if ~bodeflag & 0,
        % Remove labels from new axes if not in the first column or last row.
        ch = get(fig,'Children');
        if i>1,
          h = ch(1:length(ch)-length(kids));
          for k=1:length(h), set(get(h(k),'ylabel'),'String',''), end
        end
        if j<nrows,
          h = ch(1:length(ch)-length(kids));
          for k=1:length(h), set(get(h(k),'xlabel'),'String',''), end
        end
        kids = ch;
      end
    end
  end
  set(fig,'DefaultAxesPosition',def_pos) % Restore it
  axes('visible','off')
  delete(findobj(fig,'Type','text'))
  title([upper(fun) ' response for each input (column) / output (row)'])
  xlabel(xlab)
  ylabel(ylab)

%  subplot(111)
else
  y=[]; y2=[];
  for i=1:ncols,
    if bodeflag==0
      y = [y,feval(fun,a,b,c,d,i,t)];
    else
      [mag,phase] = feval(fun,a,b,c,d,i,t);
      y=[y,mag]; 
      y2=[y2,phase];
    end
  end
end

% end mulresp
