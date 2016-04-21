% SUBPLOT   複数のaxesを作成
% 
% H = SUBPLOT(m,n,p) または SUBPLOT(mnp) は、Figureウィンドウをm行n列
% の小さいaxesをもつウィンドウに分割し、カレントプロットの p 番目のaxes
% を選択し、axesのハンドル番号を出力します。axesは、Figureウィンドウの
% 一番上の行、つぎに2番目の行、のようにカウントされます。たとえば、
% 
%     SUBPLOT(2,1,1), PLOT(income)
%     SUBPLOT(2,1,2), PLOT(outgo)
% 
% は、ウィンドウの上半分に income をプロットし、下半分に outgo をプロット
% します。
% 
% SUBPLOT(m,n,p) は、axesが既に存在すれば、そのaxesをカレントにします。
% SUBPLOT(m,n,p,'replace') は、axesが既に存在している場合はそれを削除し、
% 新しいaxesを作成します。
% SUBPLOT(m,n,p,'align') は、プロットボックスが、ラベルに妨げずに
% 整列するように軸を位置し、重ならないようにします。
% overlapping. 
% SUBPLOT(m,n,P) は、P がベクトルのとき、P の中にリストされているサブ
% プロットの位置すべてをカバーする axes の位置を設定します。
% 
% SUBPLOT(H) は、H がaxesのハンドル番号のとき、後に続くプロットコマンド
% に対して、axesをカレントとするためのもう1つの方法です。
%
% SUBPLOT('position',[left bottom width height]) は、(0.0から1.0の範囲で)
% 正規化された座標で指定した位置にaxesを作成します。
%
% SUBPLOT(m,n,p, PROP1, VALUE1, PROP2, VALUE2, ...)  は、subplot axis に
% 指定したプロパティ値の組を設定します。 指定した figure に subplot 
% を追加するためには、'Parent' プロパティに対する値として、figure 
% ハンドルを渡してください。
%
% SUBPLOT の仕様が、新しいaxesを使って古いaxesを書き換えるような場合、
% 既に存在している古いaxesは削除されます。これは、新しいaxesの位置と古い
% axesの位置が同じ位置の場合は例外です。たとえば、ステートメント 
% SUBPLOT(1,2,1)は、すべての存在しているaxesを削除し、Figureウィンドウ
% の左側を書き換え、その部分に新しいaxesを作成します。ここでも、新しいaxes
% の位置が厳密な意味で一致しない(かつ 'replace' が指定されていない)限り、
% 上述したようになります。このような場合、重なっているすべてのaxesは削除
% され、一致しているaxesがカレントのaxesになります。
%  
% SUBPLOT(111) は、上述したルールの例外です。これは、SUBPLOT(1,1,1) と
% 同じ挙動を示しません。下位互換性のために、axesをすぐに作成しない特別な
% もので、つぎのグラフィックスコマンドがfigureで CLF RESET を実行するように
% figureを設定し(figureのすべての子オブジェクトを削除します)、デフォルトの位
% 置に新しいaxesを生成します。このシンタックスはハンドルを出力しません。
% そのため、出力引数を指定するとエラーになります。後で実行される CLF RESET 
% は、figureの NextPlot を 'replace' に設定することで完了します。
%
% SUBPLOT(m,n,p,H) は、H が axes の場合、指定した位置に、H を移動します。
% SUBPLOT(m,n,p,H,PROP1,VALUE1,...) は、H を移動し、指定したプロパティ
% 値の組を適用します。

%   Copyright 1984-2002 The MathWorks, Inc. 
