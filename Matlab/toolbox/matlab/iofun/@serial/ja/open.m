% OPEN	 拡張子によってファイルをオープン
%
% OPEN NAME は、つぎの文字列で命名されたオブジェクトのタイプに従って、
% 種々の処理を行います。ここで、NAME は、文字列を含まなければなりません。:
%  
%     タイプ         挙動
%     ------         ----
%     variable      Array Editor の中で、名前の付けられた配列をオープン
%     .mat  file    Load Wizard の中で、MAT ファイルをオープン
%     .fig  file    Handle Graphics の中の figure のオープン
%     .m    file    M-ファイル Editor の中で、M-ファイルをオープン
%     .mdl  file    Simulink の中で、モデルをオープン
%     .p    file    存在すれば、一致した M ファイルをオープン
%     .html file    Help Browser の中で、HTML ドキュメントをオープン
%  
% OPEN は、LOAD と同じ手法で、ファイルのサーチを行います。
%  
% NAME が、MATLAB パス上に存在すれば、WHICH で出力されるファイルを
% オープンします。
%  
% NAME が、ファイルシステム内に存在すれば、NAME と名付けられたファイルを
% オープンします。
%  
% 例題:
%  
%    open('handel')           % handel.mdl, handel.m, やハンドルが、
%                             % パス上に存在しなければ、エラーになります。
%  
%    open('handel.mat')       % handle.mat がパス上に存在しなければ、
%                             % エラーになります。
%  
%    open('d:\temp\data.mat') % data.mat が、d:\temp に存在しなければ、
%                             % エラーになります。
%    
% OPEN は、ユーザにより拡張可能です。拡張子".XXX"をもつファイルをオープン
% するため、OPEN は、補助関数 OPENXXX をコールします。この関数は、ファイル
% 拡張子を付加した、"OPEN"と名付けた関数です。
%  
% たとえば、つぎのように使用します。
%        open('foo.m')       は、openm('foo.m') を呼びます。
%        open foo.m          は、openm('foo.m') を呼びます。
%        open myfigure.fig   は、openfig('myfigure.fig') を呼びます。
%  
% 標準のファイルタイプを取り扱う方法を変更したり、または、新しいファイル
% タイプに対するハンドラを設定したりして、ユーザ自身の OPENXXX 関数を
% 作成できます。OPEN は、OPENXXX 関数が、パス上で検出された場合は、常に
% コールします。
%  
% 特別な場合:
% ワークスペース関数に対して、OPENVAR をコールし、イメージファイルに
% 対して、OPENIM をコールします。
%  
% 補助関数と一致するものを検出できない場合、OPEN は、OPENOTHER をコール
% します。
%  
% 参考 : SAVEAS, WHICH, LOAD, UIOPEN, UILOAD, PATH.


%    MP 1-31-00
%    Copyright 1999-2002 The MathWorks, Inc. 
