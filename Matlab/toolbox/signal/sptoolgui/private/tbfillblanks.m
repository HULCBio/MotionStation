function tbfillblanks(ut,sep,toolbar)
% fill toolbar across width of figure by
% right justifying all toolbar buttons to the right of "sep"
%  Done by filling with "blank" uipushtools that are disabled
% Inputs:
%   ut - handle of uitoolbar
%   sep - handle to uitoggle/pushtool in ut that is the rightmost
%         item in the left group of toolbar tools
%   toolbar - 1x1 structure containing handles of visible toolbar tools,
%     in order from left to right, in its fields
%  NOTE:  This feature has been disabled until further notice.
%   In case the functionality is ever desired in the future,
%   this function and calls to it from the SPTool clients
%   are being left in place.  Simply set the BLANKS_FLAG
%   parameter in this function to 1.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.5 $

%   TPK, 12/20/99

BLANKS_FLAG = 0;
if BLANKS_FLAG == 0  % <-- simply set 'separator' property to separate left and
                     %     right toolbar groups
   fn = fieldnames(toolbar);
   ut_ch = [];
   for i=1:length(fn)
      ut_ch = [ut_ch; getfield(toolbar,fn{i})];
   end
   sep_ind = find(sep==ut_ch);
   set(ut_ch(sep_ind+1),'separator','on')

else  % BLANKS_FLAG == 1  <-- insert blank toolbar buttons

   fn = fieldnames(toolbar);
   ut_ch = [];
   for i=1:length(fn)
      ut_ch = [ut_ch; getfield(toolbar,fn{i})];
   end
   %ut_ch = get(ut,'children');
   fig = get(ut,'parent');
   fp = get(fig,'position');
   
   uiwidth = 0;  % How wide is a uipush/toggletool?
   for i = 1:length(ut_ch)
      cdata = get(ut_ch(i),'cdata');
      uiwidth = max([uiwidth size(cdata,2)]);
   end
   uiwidth = uiwidth+8;  % all sizes assumed in pixels

   separatorWidth = length(findobj(ut_ch,'separator','on'))*11;   
   
   old_blanks = findobj(get(ut,'children'),'tag','blank');
   num_blanks = floor((fp(3)-separatorWidth)/uiwidth)-length(ut_ch);
   if num_blanks < 1
      num_blanks = 1;
   end

   if num_blanks < length(old_blanks)  % delete some
      delete(old_blanks((num_blanks+1):length(old_blanks)))
   elseif num_blanks > length(old_blanks)  % add some
      for i = length(old_blanks)+1:num_blanks                  
         uipushtool('cdata',[],...
                    'parent',ut,...
                    'enable','off',...
                    'tag','blank');
      end

      %ut_ch = setdiff(get(ut,'children'),old_blanks);
      ind = find(ut_ch==sep);
      all_blanks = findobj(get(ut,'children'),'tag','blank');
      ut_ch = [ut_ch(end:-1:ind+1); all_blanks; ut_ch(ind:-1:1)];
      set(ut,'children',ut_ch)
      set(all_blanks,'enable','off')
   end

end  % if BLANKS_FLAG 
