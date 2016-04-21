% CONNDEF 　デフォルトの連結性配列
% CONN = CONNDEF(NUM_DIMS,TYPE) は、NUM_DIMS 次元に対して、TYPE で定義
% された連結性配列を出力します。TYPE は、つぎの値のいずれかを選択するこ
% とができます。
%
%       'minimal'    N 次元の場合、(N-1)次元サーフェスの中心要素に接し
%                    ている近傍要素を定義
%
%       'maximal'    任意の方法で、中心要素に接するすべての近傍を含むも
%                    のを定義： ONES(REPMAT(3,1,NUM_DIMS)) 
%
% いくつかの Image Processing Toolbox の関数は、CONNDEF を使って、デフォ
% ルトの連結度の入力引数を作成します。
%
%   例題
%   -------
%       conn2 = conndef(2,'min')
%       conn3 = conndef(3,'max')



%   Copyright 1993-2002 The MathWorks, Inc.
