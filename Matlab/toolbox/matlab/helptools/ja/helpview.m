% HELPVIEW   HTMLファイルの表示、またはプラットフォーム依存のヘルプ
% ビューワの表示
% 
% 表示:
%
%  helpview (coll_path)
%  helpview (coll_path、win_type)
%  helpview (topic_path)
%  helpview (topic_path、win_type)
%  helpview (topic_path, win_type, parent)
%  helpview (map_path、topic_id)
%  helpview (map_path、topic_id、win_type)
%  helpview (map_path, topic_id, win_type, parent)
%
% 引数:
%
% coll_path
% HTMLファイルの集合のパス。パスの最後の名前は、ファイルの集合の名前です。
%
% topic_path
% HTMLファイルのパス。パスは、.htm(l)やhtm(l)とHTMLのアンカーの参照で
% 終了しなければなりません。たとえば、
%
%     /v5/help/helpview.html#topicpath
%     d:/v5/help/helpview.html#topicpath 
%
% となります。
%
% map_path
% トピックのidsをトピックファイルのパスに射影するマップファイル(下記参照)
% のパス。パスは、拡張子.mapで終了しなければなりません。たとえば、つぎの
% ようになります。
%
%    d:/v5/help/ml_graph.map
%
% topic_id
% トピックを識別する任意の文字列。HELPVIEWは、topic_idをトピックの記述し
% たHTMLファイルのパスに射影するために、パスによって指定されるマップファ
% イルを使用します。
%
% win_type
% ヘルプ内容を表示するウィンドウのタイプ。"CSHelpWindow"を設定すると、
% コンテキストセンシティブなヘルプビューワを使用することになります。他の
% 場合は、メインの"ヘルプ"ウィンドウを使います。
%
% parent
% figure ウィンドウに対するハンドル。ヘルプダイアログの parent を決定
% するために、"CSHelpWindow" win_type により使用されます。この引数は、
% win_type が CSHelpWindow でない場合、無視されます。
%
% TOPIC MAP FILE
%
% マップファイルは、基本的には2列で表示する ascii テキストファイルです。
% 各々の行は、つぎの形式です。
%
% TOPIC_ID  PATHNAME
%
% TOPIC_IDは、HTMLファイルに含まれるオンラインヘルプの"chunk"を識別する
% 任意の文字列です。概して、テクニカルライタや開発者は、これらの識別子が
% 示すものに同意しています。開発者は、helpview の呼び出しに、これらを使
% います。  
%
% PATHNAMEは、マップファイルを含むディレクトリに対するcoll_pathまたは
% topic_pathです。
%  
% たとえば、つぎのマップファイル
%
% ml_graph.map
%  COLORPICKDLG  ml_graph/ch02aa31.html
%  PRINTDLG      ml_graph/ch02aa35.html
%  LINESTYLEDLG  ml_graph/ch02aa31.html#ModLines
%
% がディレクトリDOCROOT\techdocにあると仮定します。ここで、DOCROOTは
% MATLABヘルプシステムのルートディレクトリです。このとき、つぎの呼び出し
%
%  helpview([DOCROOT '/techdoc/ml_graph.map']、'PRINTDLG');
% 
%  は、つぎのものと等価です。
%
%  helpview([DOCROOT '/techdoc/ml_graph/ch02aa35.html']);
% 

