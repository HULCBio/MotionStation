% JPROPEDITUTILS  PropertyEditor.java 用のユーテリティ関数
% 
% JPROPEDITUTILS は、種々のサブ関数を用意しています。
%
%   'jinit' ======================================================= 
%
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH] = JPROPEDITUTILS('jinit',H)
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH] = ....
%                  JPROPEDITUTILS('jinit',H,PROPNAMES)
%
% jget,jset,jpath をコールして、これらの出力引数を取得でき、1つのコール
% で、すべてのものを出力できます。
%
% get() や set() から得られるプロパティリストが異なる場合は、プロパティ名
% を合わせようとするよりも、JPROPEDITUTILS は、2つのプロパティ名の組を
% 単に出力します。
%
%   'jget' ======================================================== 
%
%   [FIELDS,VALUES,ISMULTIPLE] = JPROPEDITUTILS('jget',H)
%   [FIELDS,VALUES,ISMULTIPLE] = JPROPEDITUTILS('jget',H,PROPNAMES)
%
% ここで、H は、HG ハンドル番号を含む 1 行 M 列の配列です。
% ここで、PROPNAMES は、プロパティ名を表す文字列またはプロパティ名の
% 1 行 N 列のセル配列です。PROPNAMES が省略される場合は、JGET はすべ
% てのプロパティ名を取得します。
% 
% ここで、FIELDS は、プロパティ名の 1 行 N 列のセル配列です。
% ここで、VALUES は、プロパティ値からなる 1行 N 列のセル配列です。
% H が1より長い場合は、各要素は値を示す 1行 M 列のセル配列です。
%
%   'jset' ========================================================
%
%   [FIELDS,OPTION,ISMULTIPLE] = JPROPEDITUTILS('jset',H)
%   [FIELDS,OPTION,ISMULTIPLE] = JPROPEDITUTILS('jset',H,PROPNAMES)
%
% ここで、H は、HG ハンドル番号を含む 1 行 M 列の配列です。
% ここで、PROPNAMES は、プロパティ名を表す文字列またはプロパティ名の
% 1 行 N 列のセル配列です。PROPNAMES が省略される場合は、JSET はすべて
% のプロパティ名を設定します。
% 
% ここで、FIELDS は、プロパティ名の 1 行 N 列のセル配列です。
% ここで、OPTION は、適切にエミュレートされたオプション値の 1行 N 列の
% セル配列です。
%
%   'jpath' =====================================================
%
%   PATH = JPROPEDITUTILS('jpath',H)
% 
% H は、HG オブジェクトの単一のハンドル番号か、または、ハンドル番号から
% なるベクトルです。H の中のタイプが種々の場合は出力されるパスは 
% 'MIXED' になります。その他の場合、PATH は、オブジェクトタイプの m ファイル
% への相対パスを含むセル配列になります(パスがファイルのセパレータの代わり
% に . を使用する場合、出力されるパスは、パスの最初と最後で一定の間隔を
% 含んでいることに注意してください)。
%
% オブジェクトへのパスが見つからない場合は、関数はつぎのメッセージを出力
% します。
%
%    .toolbox.matlab.graphics.
%
%  'jhelp' =======================================================
%
%  MSG = JPROPEDITUTILS('jhelp',H)
%  MSG = JPROPEDITUTILS('jhelp',TYPE)
%
% H は、同じオブジェクトタイプの単一オブジェクト、または、ハンドル番号
% からなるベクトルのいずれかです。
% TYPE は、オブジェクトタイプを表す文字列です。
% MSG は、ステータスメッセージです。
% 
%   'jselect'================================ 
% 
%   MSG = JPROPEDITUTILS('jselect',H) 
% 
%   'japplyexpopts'=============================== 
% 
%   JPROPEDITUTILS('japplyexpopts',H) 
% 
% H は、figureのハンドルのベクトルです。
% 
% カレントのプロパティをappdataに保存して、新規プロパティを設定します。
%    
%   'jrestorefig'=============================== 
% 
%   JPROPEDITUTILS('jrestorefig',H) 
% 
% H は、figureのハンドルのベクトルです。
% 
% japplyexopt 関数がコールされる前に設定されたプロパティをリストアします。 
% 
%   'jmeshcolor' ==================================== 
% 
%   C = JPROPEDITUTILS('jmeshcolor',H) 
% 
% H は、サーフェス、または、パッチオブジェクトへのハンドルです。
% C は、隠線メッシュとして表れるオブジェクトを作成するために必要なハン
% ドルに対する FaceColor です。
% 
% H が単一オブジェクトの場合は、C は3つの数字から構成されます。H がベク
% トルの場合、C はカラーのセルは配列になります。
% 
% 親のaxesの可視化プロパティが 'off' で、figureのカラーが 'none' の場合は、
% 出力されるフェースカラーは、白  [1,1,1] になります。
% 
%  'jinstrument' =================================== 
% 
%  H = JPROPEDITUTILS('jinstrument',H) 
% 
% listeners を H の中のハンドルに加え、そのリストを出力します(注意：
% listener は1回だけ加えられます)。


%   Copyright 1984-2002 The MathWorks, Inc.  
