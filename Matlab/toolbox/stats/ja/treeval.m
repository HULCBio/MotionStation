% TREEVAL   �f�[�^�ɓK�p��������؂ɑ΂���ߎ��l�̌v�Z
%
% YFIT = TREEVAL(TREE,X) �́ATREEFIT �֐��Ő����������ށA�܂��͉�A��
% TREE �Ɨ\���q�̍s�� X ����荞�݁A�\�����ꂽ�����l�̃x�N�g�� YFIT ��
% �������܂��B��A�؂ɂ��ẮAYFIT(j) �́A�\���q X(j,:) �����_��
% �΂���ߎ����ꂽ�����l�ł��B���ޖ؂ɂ��ẮAYFIT(j) �́A�f�[�^ 
% X(j,:) �ɑΉ�����_�Ƀc���[�����蓖�Ă镪�ޔԍ��ł��B�ԍ�����N���X
% ���ɕϊ����邽�߂ɁA3�Ԗڂ̏o�͈���(�ȉ����Q��)���g���܂��B
%
% YFIT = TREEVAL(TREE,X,SUBTREES) �́A���ɁA0�����S�ȁA������菜��
% �Ȃ��c���[�������悤�ȁA�폜(pruning)���x���̃x�N�g�� SUBTREES ��
% ��荞�݂܂��BTREE �́ATREEFIT �܂��� TREEPRUNE �֐��ō쐬���ꂽ�폜
% (pruning)����܂�ł��Ȃ���΂Ȃ�܂���BSUBTREES �� K �̗v�f�ŁA
% X �� N �s�̏ꍇ�A�o�� YFIT �́AJ�Ԗڂ̗� SUBTREES(J) �̃T�u�c���[
% �ɂ���Đ������ꂽ�ߎ��l���܂� N�~K �s��ł��BSUBTREES �́A������
% ���тłȂ���΂Ȃ�܂���B(�œK�ȍ폜(pruning)��̈ꕔ�ł͂Ȃ��c���[
% �ɑ΂���ߎ��l���v�Z����ɂ́A�c���[�̎}����菜�����߂ɁA�ŏ��� 
% TREEPRUNE ���g�p���Ă�������)
%
% [YFIT,NODE] = TREEVAL(...) �́AX �̊e�s�Ɋ��蓖�Ă�ꂽ�m�[�h�ԍ���
% �܂� YFIT �Ɠ����傫���̔z�� NODE ���o�͂��܂��BTREEDISP �֐��́A
% �I�������C�ӂ̃m�[�h�ɑ΂��ăm�[�h�ԍ���\�����邱�Ƃ��ł��܂��B
%
% [YFIT,NODE,CNAME] = TREEVAL(...) �́A���ޖ؂ɑ΂��Ă̂ݗL���ł��B
% �\�����ꂽ���ޖ����܂ރZ���z�� CNAME ���o�͂��܂��B
%
% X �s����� NaN �l�́A�����l�Ƃ��Ĉ����܂��B�}�m�[�h�ŕ����K����
% ���s���悤�Ƃ���Ƃ��ɁATREEVAL �֐��������l�ɑ��������ꍇ�A���E��
% �ǂ��炩�̎q�m�[�h�Ɉڂ�ׂ����ǂ�������ł��܂���B���̑���ɁA
% �}�m�[�h�Ɋ��蓖�Ă�ꂽ�ߎ��l��Ή�����ߎ��l�Ɛݒ肵�܂��B
%
% ���: Fisher �� iris data �ɑ΂��ė\�����ނ��s���܂��B
%    load fisheriris;
%    t = treefit(meas, species);  % ����؂̍쐬
%    sfit = treeval(t,meas);      % ���蓖�Ă�ꂽ���ޔԍ�������
%    sfit = t.classname(sfit);    % ���ޖ�
%    mean(strcmp(sfit,species))   % ���m�ɕ��ނ��ꂽ�䗦���v�Z
%
% �Q�l : TREEFIT, TREEPRUNE, TREEDISP, TREETEST.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/03/21 20:36:31 $

