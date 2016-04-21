% MOVIEIN   ムービーフレームのメモリの初期化
% 
% MOVIEIN はMATLABリリース 11(5.3)では必要なくなりました。以前のバージョン
% ではパフォーマンスの向上のためムービーの事前割り当てを行なっていましたが、
% 現在はムービーの事前割り当ては必要ありません。ムービーを作成するには
% 以下のような書式を用います。
%
%     for j = 1:n
%        plot_command
%        M(j) = getframe;
%     end
%     movie(M)
%
% リリース 11(5.3)以前の、すべてのバージョンのMATLABと互換性の保たれた
% コードにするには、以下のコマンドを利用してください。
%
%       M = moviein(n);
%	for j=1:n
%          plot_command
%	   M(:,j) = getframe;
%	end
%	movie(M)
%
% 参考：MOVIE, GETFRAME.


%   Copyright 1984-2002 The MathWorks, Inc. 
