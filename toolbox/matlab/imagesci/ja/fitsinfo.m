% FITSINFO     FITSファイルの情報を取得
%
% INFO = FITSINFO(FILENAME) は、FITS (Flexible Image Transport System) 
% ファイルの内容に関する情報を含む構造体のフィールドを出力します。
% FILENAME は、FITS ファイルの名前を指定する文字列です。
%
% 構造体 INFO は、つぎのフィールドを含みます。
%
% Filename     ファイル名を表す文字列 
%      
% FileSize     ファイルのサイズをバイト単位で示す整数
%      
% FileModDate  ファイルの修正日を含む文字列
%
% Contents     記述されている順番にファイル内の拡張子リストを含むセル配列
%      
% PrimaryData  FITSファイル内の基本データに関する情報を含む構造体
%
% 構造体 PrimaryData は、つぎのフィールドを含んでいます。
%
%      DataType      データの精度 
%      
%      Size          各次元のサイズを含む配列
%
%      DataSize      基本データのバイト数で表したサイズ 
%
%      MissingDataValue  未定義データであることを示す値
%
%      Intercept     つぎの式を使って配列ピクセル値から真のピクセル値を
%                    計算するために、Slope に関して使用する値 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         つぎの式を使って配列ピクセル値から真のピクセル値を
%                    計算するために、Intercept に関して使用する値  
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        ファイルの先頭から最初のデータ値の位置までのバイト数
%
%      Keywords      各列のヘッダにすべての Keywords, Values, Comments 
%                    を含む(キーワード数)行3 列のセル配列。
%
% FITSファイルは、拡張が可能です。つぎのフィールドの1つ、または複数のもの
% をINFO構造体の中に含ませることができます。
%   
%      AsciiTable  このファイル内のASCII Table拡張に関する情報を含む
% 　　　　　　　　 構造体配列
%         
%      BinaryTable このファイル内のBinary Table拡張に関する情報を含む
%                  構造体配列
%         
%      Image       このファイル内のImage拡張に関する情報を含む構造体配列
%       
%      Unknown     このファイル内の標準的でない拡張に関する情報を含む
%                  構造体配列
%
% 構造体 AsciiTable は、つぎのフィールドをもちます。
%
%      Rows         テーブル内の行数
%        
%      RowSize      各行のキャラクタ数
%      
%      NFields      各行のフィールド数
%      
%      FieldFormat  各フィールドが符号化されるときに使用するフォーマット
%                   を含む 1 行 NFields 列の配列。フォーマットは、
%                   FORTRAN-77 formatコードです。
%
%      FieldPrecision 各フィールドにデータの精度を含む1行NFields列の配列
%
%      FieldWidth   各フィールドにキャラクタ数を含む1行NFields列の配列
%
%      FieldPos     各フィールドに対する開始列を表す数値からなる1行
%                   NFields列の配列
%
%      DataSize     ASCII Table内のデータサイズを表すバイト数
%
%      MissingDataValue  各フィールド内の未定義データを表すために使用
%                        する数値からなる1行NFIELDS列の配列
%
%      Intercept    つぎの方程式を使って、配列データ値から実際のデータ値
%                   を計算するために、Slope で利用する数値からなる1行
%                   NFIELDS 列の配列:
%                   actual_value = Slope*array_value+Intercept
%		    
%      Slope        つぎの方程式を使って、配列データ値から実際のデータ値
%                   を計算するために、Intercept で利用する数値からなる1行
%                   NFIELDS 列の配列
%                   actual_value = Slope*array_value+Intercept
%
%      Offset       ファイルの先頭からテーブル内の最初のデータ値の位置まで
%                   のバイト数
%		    
%      Keywords     ASCIIテーブルヘッダ内のすべての Keywords, Values, 
%                   Comments を含む(キーワード数 ) 行 3 列のセル配列
%          
% BinaryTable 構造体は、以下のフィールドを含みます。
%
%      Rows        テーブルの行数
%                  
%      RowSize     各行のバイト数
%                  
%      NFields     各行のフィールド数
%
%      FieldFormat  各フィールド内のデータのデータタイプを含む1行 
%                   NFields列のセル。データタイプは、FITSバイナリ
%                   テーブルフォーマットコードで表わされます。
%
%      FieldPrecision  各フィールド内のデータの精度を含む1行NFields列
%                      のセル
%
%      FieldSize    N番目のフィールドの値の数を含む1行 NFields 列の配列
%                            
%      DataSize     Binary Table内のデータのバイト数。値には、メイン
%                   テーブルのすべてのデータが含まれます。
%
%      MissingDataValue  各フィールド内の未定義のデータを表わすために
%                        用いる1行NFields 列の配列
%
%      Intercept    つぎの式を使って配列データ値から真のデータ値を計算する
%                   ためにSlopeと共に用いられる数値からなる1行NFields列配列:
%                   actual_value = Slope*array_value+ Intercept
%		    
%      Slope        つぎの式を使って配列データ値から真のデータ値を計算する
%                   ためにInterceptと共に用いられる数値からなる1行NFields列配列:
%                   actual_value = Slope*array_value+ Intercept
%		    
%      Offset       ファイルの先頭から最初のデータ値の位置までのバイト数
%
%      ExtensionSize    メインテーブルを通過するすべてのデータのバイト単位
%                       のサイズ
%
%      ExtensionOffset  ファイルの先頭からメインテーブルを通過するデータの
%                       位置までのバイト数
%      
%      Keywords     バイナリテーブルヘッダ内のすべてのKeywords, Values, 
%                   Commentsを含む(キーワード数) 行 3 列のセル配列
%                    
% Image 構造体は、以下のフィールドを含みます。
%   
%      DataType      データの精度
%      
%      Size          各次元のサイズを含む配列
%
%      DataSize      Image拡張子内のバイト単位のデータサイズ
%
%      MissingDataValue  未定義データを表わすために用いる値
%
%      Intercept     つぎの式を使って配列ピクセル値から真のピクセル値を
%                    計算するために、Slope に関して使用する値 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         つぎの式を使って配列ピクセル値から真のピクセル値を
%                    計算するために、Intercept に関して使用する値: 
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        ファイルの先頭から最初のデータ値の位置までのバイト数
%
%      Keywords      Imageのヘッダ内のすべての Keywords, Values, Comments
%                    を含む(キーワード数) 行 3 列のセル配列
%
% Unknown 構造体は、以下のフィールドを含みます。
%
%      DataType      データの精度
%
%      Size          各次元のサイズを含む配列
%
%      DataSize      拡張子内のバイト単位のデータサイズ
%      
%      Intercept     つぎの式を使って配列ピクセル値から真のピクセル値を
%                    計算するために、Slope に関して使用する値 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         つぎの式を使って配列ピクセル値から真のピクセル値を
%                    計算するために、Intercept に関して使用する値 
%                    actual_value = Slope*array_value + Intercept
%
%      MissingDataValue  未定義データを表わすために用いる値
%
%      Offset        ファイルの先頭から最初のデータ値の位置までのバイト数
%
%      Keywords      拡張子ヘッダ内のすべてのKeywords, Values, 
%                    Commentsを含む(キーワード数) 行 3 列のセル配列
%
% 参考 ： FITSREAD.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:41 $

