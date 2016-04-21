% IPTSETPREF   Image Processing Toolbox の優先順位を設定
%   IPTSETPREF(PREFNAME,VALUE) は、文字列 PREFNAME を VALUE に設定する
%   ことにより、Image Processing Toolbox の優先度を設定します。設定
%   は、カレントの MATLAB セッションが終了するまで、または、設定が変更
%   されるまで有効です(実行の度に設定を有効にするには、ユーザの start-
%   up.m ファイルに、このコマンドを設定してください)。
%
%   つぎの表は、使用できる優先度項目を記述しています。その名前は、大文
%   字小文字に無関係で、省略形も使用できます。
%
%   以下の優先順位が設定できます。
%
%   'ImshowBorder'        'loose' (デフォルト) または、'tight'
%
%        'ImshowBorder' が 'loose' の場合、IMSHOW は、イメージと Figu-
%        reウィンドウのエッジの間に、ある境界をもってイメージを表示し
%        ます。それで、軸のラベルやタイトル等を表示することができま
%        す。'ImshowBorder' を 'tight' にすると、IMSHOW は、イメージ全
%        体が Figure の大きさになるようにフィギュアの大きさを調整しま
%        す。従って、タイトル等の表示はありません(イメージが非常に小
%        さい場合や、Figure のイメージ内に別のオブジェクトと軸が存在す
%        る場合、境界が残ることがあります)。
%
%   'ImshowAxesVisible'   'on'、または、'off'(デフォルト)
%
%        'ImshowAxesVisible' が 'on' の場合、IMSHOW は軸のボックスと刻
%        みラベル付きでイメージを表示します。'ImShowAxesVisible' が 
%        'off' の場合、IMSHOW は軸のボックスや刻みラベルなしのイメージ
%        を表示します。
%
%   'ImshowTruesize'      'auto'(デフォルト)、または、'manual'
%
%        'ImshowTruesize' が 'manual' である場合、IMSHOW は、TRUESIZE
%        を呼び出しません。'ImshowTruesize' が 'auto' である場合、IMS-
%        HOW は、TRUESIZE を呼び出すかどうかを自動的に決定します(結果
%        の Figure 内に、イメージとその軸以外に他のオブジェクトが存在
%        しない場合、IMSHOW は TRUESIZE を呼び出します)。DISPLAY_OPTI-
%        ON 引数を IMSHOW に設定すると、個別の表示用に、この設定を切り
%        離すことができます。または、イメージの表示後、マニュアルで 
%        TRUESIZE を呼び出すことができます。
%
%   'TruesizeWarning'     'on'(デフォルト)、または、'off'
%
%        'TruesizeWarning' が 'on' の場合、TRUESIZE は、イメージがスク
%        リーンに適合するには大き過ぎるときに、ワーニングを表示しま
%        す。'TruesizeWarning' が 'off' の場合、TRUESIZE はワーニング
%        を表示しません。IMSHOW を使う場合のように、間接的に TRUESIZE
%        を呼び出すときでさえ、この優先順位を適用するので注意してくだ
%        さい。
%
%   IPTSETPREF(PREFNAME) は、PREFNAME の有効な値を表示します。
%
%   例題
%   ----
%       iptsetpref('ImshowBorder', 'tight')
%
%   参考：IMSHOW, IPTGETPREF, TRUESIZE



%   Copyright 1993-2002 The MathWorks, Inc.  
