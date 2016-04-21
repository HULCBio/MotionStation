function [m,error_str] = matqparse(str,flag)
%MATQPARSE Dialog entry parser for MATQDLG.
%   [M,ERROR_STR] = MATQPARSE(STR,FLAG) is a miniparser
%   for MATQDLG.
%   eg: 'abc de  f ghij' becomes [abc ]
%                                [de  ]
%                                [f   ]
%                                [ghij]
%   Uses either spaces, commas, semi-colons, or brackets
%   as separators.  Thus 'a 10*[b c] d' will crash. User
%   must instead say 'a [10*[b c]] d'.
%
% See also MATQDLG, MATQUEUE.

%  Copyright 1994-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2003/11/18 03:12:28 $

% Error checks
error_str = '';
if nargin==0,
   error_str = 'matqparse: requires a string input';
   return
elseif size(str,1)>1 | ~isstr(str),
   error_str = 'matqparse: expecting single row string';
   return
end

if nargin<2,
   flag = 1;
end

l = length(str);
m = '';
i = 1;
j = 1;
k = 1;
while k<=l,
   % Check for missing [
   if str(k)==']',
      error_str = 'matqparse: unmatched right bracket';
      return
   elseif str(k)=='[',
      % Check for missing ]
      index = find(str(k+1:l)==']');
      if isempty(index),
         error_str = 'matqparse: unmatched left bracket';
         return
      else
         % Check for mismatched brackets between k+1 and last element
         index1 = find(str(k+1:l)=='[');
         l_index = length(index);
         l_index1 = length(index1);
         if l_index~=l_index1+1,
            error_str = 'matqparse: mismatched brackets';
            return
         else
            % Everything OK so far
            di = find([index1 index(l_index)+1]>index);
            end_ind = index(di(1));
            m_middle = ['[' matqparse(str(k+1:k+end_ind-1),2) ']'];
            if flag==1,
               % m and m_end may be multiline matrices
               m_end = matqparse(str(k+end_ind+1:l),1); 
               m = str2mat(m,m_middle,m_end);
            else
               % m and m_end will be single line
               m_end = matqparse(str(k+end_ind+1:l),2);
               m = [m m_middle m_end];
            end
            k = l+1;
         end
      end
   elseif any(str(k)==' ;,') & (flag==1),
      if j>1,
         % Only reset to beginning of next row if 
         % NOT already at beginning of a row
         j=1;
         i = i+1;
      end
      k = k+1; % Increment index into str
   else
      m(i,j) = str(k);
      j = j+1; % Increment column of resultant matrix, m
      k = k+1; % Increment index into str
   end
end

% Since char of zero is end-of-string flag, change to blanks
if ~isempty(m),
   EndOfString = find(abs(m)==0);
   m(EndOfString) = char(' '*ones(size(EndOfString)));

   % Eliminate any empty rows
   if size(m,2)>1,
      m  = m(find(any(m'~=' ')),:);
   end

end

% end matqparse
