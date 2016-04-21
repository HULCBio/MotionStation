% IMFILTER 　多次元イメージのフィルタ操作
% B = IMFILTER(A,H) は、多次元フィルタ H を使って、多次元配列 A をフィル
% タリングします。A は、 logical か、または任意のクラスと次元の非スパース
% の数値配列です。結果の B は、A と同じサイズとクラスをもっています。
%
% 出力 B の個々の要素は、倍精度の浮動少数点を使って計算します。A が
% 整数配列か論理配列の場合、与えられたタイプの範囲を超えた出力要素は、
% 打ち切られ、小数点以下は丸められます。
%
% B = IMFILTER(A,H,OPTION1,OPTION2,...) は、指定した OPTION に従って、多
% 次元のフィルタリングを行います。OPTION 引数は、つぎのいずれかを設定しま
% す。
%
%   - 境界に関するオプション
%
%       X            配列の境界の外に位置する入力配列値は、陰的に、値 X 
%                    と仮定します。境界に関するオプションが存在しない場
%                    合、IMFILTER は、X = 0 を使います。
%
%       'symmetric'  配列の境界の外に位置する入力配列値は、配列の境界を
%                    跨いで、配列の鏡像を使って計算します。
%
%       'replicate'  配列の境界の外に位置する入力配列値は、最近傍の配列
%                    境界値と等しいと仮定しています。
%
%       'circular'   配列の境界の外に位置する入力配列値は、入力配列が、
%                    周期的であると、陰的に仮定しています。
%
%   - 出力サイズオプション
%     (IMFILTER に関する出力サイズオプションは、関数 CONV2 や FILTER2 の
%     SHAPE オプションに似ています)
%
%       'same'       出力配列は、入力配列と同じサイズです。出力に関する
%                    サイズオプションが設定されていない場合、デフォルト
%                    の挙動をします。
%
%       'full'       出力配列は、フルのフィルタを適用した結果で、そのた
%                    めに、入力配列より大きくなります。
%
%   - 相関とコンボリューション
%
%       'corr'       IMFILTER は、相関を使って、多次元フィルタ操作を行い
%                    ます。
% ここでは、FILTER2 が行うフィルタ操作と同じ方法です、相関、または、コン
% ボリューション、共に、オプションが存在していない場合、IMFILTER は、相関
% を使います。
%
%       'conv'       IMFILTER は、コンボリューションを使って、多次元の
%                    フィルタ操作を行います。
% 
% 例題
% -------------
%       rgb = imread('flowers.tif'); 
%       h = fspecial('motion',50,45); 
%       rgb2 = imfilter(rgb,h); 
%       imshow(rgb), title('Original') 
%       figure, imshow(rgb2), title('Filtered') 
%       rgb3 = imfilter(rgb,h,'replicate'); 
%       figure, imshow(rgb3), title('Filtered with boundary replication')
%
% 参考： CONV2, CONVN, FILTER2. 



%   Copyright 1993-2002 The MathWorks, Inc. 
