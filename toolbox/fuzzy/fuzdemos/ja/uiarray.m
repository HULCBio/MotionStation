% UIARRAY UI �{�^���̔z��(�܂��͍s��)���쐬
% UIARRAY(POS�AM�AN�ABORDER�ASPACING�ASTYLE�ACALLBACK�ASTRING) �́APOS 
% ���� M �sN ��̔z��Ƃ��Ĕz�u����� UI �R���g���[�����쐬���܂��BBOR-
% DER �́AUI �R���g���[���Ǝ��͂̑傫�ȃt���[���ƊԂ̃X�y�[�X���w�肵��
% ���BSPACING �́AUI �R���g���[���Ԃ̃X�y�[�X���w�肵�܂��BSTYLE�ACALL-
% BACK�ASTRING �́AUI �R���g���[���̃X�^�C���A�R�[���o�b�N�A�����������
% ����w�肷�镶���s��( M*N �s)�ł��B�����̈����̍s�̐��� M*N �ȉ��̏�
% ���A�Ō�̍s���K�v�Ȃ����J��Ԃ��g���܂��B
%
% ���̊֐��́A��� Toolbox �f���� UI �R���g���[�����쐬���邽�߂ɗp����
% ��܂��B
%
% ���:
%
%   figure('name','uiarray','numbertitle','off');
%   figPos = get(gcf�A'pos');
%   bigFramePos = [0 0 figPos(3) figPos(4)];
%   m = 4; n = 3;
%   border = 20; spacing = 10;
%   style = str2mat('push','slider','radio','popup','check');
%   callback = 'disp([''This is a '' get(gco�A''style'')])';
%   string = str2mat('one','two','three','four-1|four-2|four-3','five');
%   uiarray(bigFramePos,m,n,border,spacing,style,callback,string);



%   Copyright 1994-2002 The MathWorks, Inc. 
