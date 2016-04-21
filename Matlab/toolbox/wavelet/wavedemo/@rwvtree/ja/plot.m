%PLOT   RWVTREE オブジェクトのプロット
%   PLOT(T) は、RWVTREE オブジェクト T をプロットします。
%   FIG = PLOT(T) は、ツリー T を含むフィギュアのハンドルを出力します。
%   PLOT(T,FIG) は、既にツリー構造が含まれるフィギュア FIG にツリー構造 %   T をプロットします。
%
%   PLOT は、グラフィカルなツリー管理ユーティリティ関数です。フィギュア
%   は、ツリー構造を含む GUI ツールです。Node Level では、Depth_Position%   か Index を、Node Action では、Split-Merge か Visualize を変更するこ%   とができます。デフォルト値は、Depth_Position と Visualize です。
%
%   現在の Node Action を実行するために、ノードをクリックすることができ
%   ます。
%
%   何回かノードの分離または組み替え操作を行った後に、ノードの含まれる
%   フィギュアのハンドルを用いて、新しいツリーを取得することができます。%   以下の特定のシンタックスを使わなければなりません。
%       NEWT = PLOT(T,'read',FIG).
%   ここでは、最初の引数はダミーです。この用途に関する最も一般的なシン
%   タックスは、以下の通りです。
%       NEWT = PLOT(DUMMY,'READ',FIG);
%   ここで、DUMMY は、NTREE オブジェクトによって親となる任意のオブジェク%   トです。
%
%   DUMMY は、NTREE によって親となるオブジェクトで、構成される任意のオブ%   ジェクト名を指定できます。例えば、
%      NEWT = PLOT(ntree,'read',FIG);
%      NEWT = PLOT(dtree,'read',FIG);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.


%   Copyright 1995-2002 The MathWorks, Inc.
