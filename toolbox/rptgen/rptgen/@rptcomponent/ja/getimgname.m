% GETIMGNAME   Report Generatorのイメージとして利用するファイル名を出力
% イメージに対する適切なファイル名を出力します。ファイル名は、ReportDi-
% rectory/rName_rExt_files/image-###-DESC.extの形式です。ここで、###はユ
% ニークな数字です。
%
%   NAME=GETIMGNAME(C,IMGINFO,DESC)
% 
%   * Cは、任意のreport generatorコンポーネントです。
%   * IMGINFOは、GETIMGFORMATが出力するタイプの構造体です。
%   * DESC (オプション)は、識別の目的のためにファイル名に付加される文字
%     列です。DESCが指定されない場合は、'etc'が用いられます。
%   * NAMEは、イメージファイルを保存するファイル名です。  
%
%   [NAME,ISNEW]=GETIMGNAME(C,IMGINFO,DESC,SOURCEID)
%
%   * SOURCEIDは、イメージに対するセッションに依存しない識別子です。
%     (例　SimulinkまたはStateflowでの絶対パス名)
%   * ISNEWは、このsourceIDに対応するイメージファイルが既に存在する場合
%     はlogical(0)を出力し、呼び出しているコンポーネントがイメージファイ
%     ルを再生成する必要がなく、与えられたファイル名を利用することができ
%     ることを意味します。指定したSOURCEIDに対してイメージが存在しない場
%     合は、ISNEWはlogical(1)を出力します。
%
% [IMDB,ISOK]=GETIMGNAME(C,'$SaveVariables')は、イメージのデータベースを
% ReportDirectory/rName_rExt_files/image-list.matに保存します。
% 
%   * IMDB = イメージデータベース構造体
%   * ISOK = 構造体が保存されたかどうかを出力
%
% [FNAMES,ISOK]=GETIMGNAME(C,'$ListFiles')は、イメージのデータベースをオ
% ープンしデータベースファイル名を含む全てのファイル名を出力します。
% 
%   * FNAMES = ファイルリスト
%   * ISOK = 構造体がロードされたかどうかを出力
%
% 参考   GETIMGFORMAT





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:52 $
%   Copyright 1997-2002 The MathWorks, Inc.
