% ���ɋL�q����悤�ɁAFUNCTION �t�H�[�}�b�g�܂��� COMMAND �t�H�[�}�b�g
% �̂����ꂩ���g���āAMATLAB�R�}���h����͂��邱�Ƃ��ł��܂��B
%
%
% FUNCTION �t�H�[�}�b�g
%
% ���̃t�H�[�}�b�g�ł́A�R�}���h�͊֐������ŏ��ɁA���ɃJ���}�ŋ�؂��
% �邩�A���邢�͊��ʂň͂܂ꂽ�������琬�藧���Ă��܂��B
%
%      functionname(arg1, arg2, ..., argn)
%
% �֐��̏o�͂́A1�܂��͕����̏o�͒l��ݒ肷�邱�Ƃ��ł��A�����̏�
% ���́A�����ʂň͂ނ��A���邢�͒l���J���}�ŋ�؂�܂��B
%
%      [out1, out2, ..., outn] = functionname(arg1, arg2, ..., argn)
%
% ���Ƃ��΁A���̂悤�Ɏg���܂��B
%
%      copyfile(srcfile, '..\mytests', 'writable')
%      [x1, x2, x3, x4] = deal(A{:})
%
%
% �����́A�l�Ƃ��Ċ֐��ɓn����܂��B���L�� ARGUMENT PASSING �̗���
% �Q�Ƃ��Ă��������B
%
%
% COMMAND �t�H�[�}�b�g
%
% ���̃t�H�[�}�b�g�ł́A�R�}���h�͊֐������ŏ��ɁA���̌�ɃX�y�[�X�ŋ�؂�
% �ꂽ1���邢�͕����̈�����z�u���܂��B
%
%      functionname arg1 arg2 ... argn
%
% Function �t�H�[�}�b�g�ƈقȂ�A�֐��̏o�͂ɕϐ������蓖�ĂȂ��Ă��\��
% �܂���B���蓖�Ă�ƁA�G���[�𐶂��܂��B
%
% ���Ƃ��΁A
%
%      save mydata.mat x y z
%      import java.awt.Button java.lang.String
%
% �����́A������Ƃ��Ď�舵���܂��B���L�� ARGUMENT PASSING �̗��
% ���Q�Ƃ��Ă��������B
%
%
% ������n��
%
% FUNCTION �t�H�[�}�b�g�ł́A�����͒l�œn����܂��B
% COMMAND �t�H�[�}�b�g�ł́A�����͕�����Ƃ��Ď�舵���܂��B
%
%
% ���̗��̒��ŁA
%
%      disp(A) - �ϐ� A �̒l���֐� disp �ɓn���܂��B
%      disp A  - �ϐ��� 'A' ��n���܂��B
%
%         A = pi;
%
%         disp(A)                    % Function �t�H�[�}�b�g
%             3.1416
%
%         disp A                     % Command �t�H�[�}�b�g
%             A
%
%
% ���̗��ŁA
%
%      strcmp(str1, str2) - ������ 'one' �� 'one' ���r���܂��B
%      strcmp str1 str2   - ������ 'str1' �� 'str2' ���r���܂��B
%
%         str1 = 'one';    str2 = 'one';
%
%         strcmp(str1, str2)         % Function �t�H�[�}�b�g
%         ans =
%              1        (equal)
%
%         strcmp str1 str2           % Command �t�H�[�}�b�g
%         ans =
%              0        (unequal)
%
%
% �������n��
%
% FUCTION �t�H�[�}�b�g���g���ĕ����\�����֐��ɓn���ꍇ�A��������V���O
% ���R�[�g ('string') �ň͂ޕK�v������܂��B
%
% ���Ƃ��΁AMYAPPTESTS �ƌĂ΂��V�����f�B���N�g�����쐬���邽�߂ɁA��
% ���̃X�e�[�g�����g���g���܂��B
%
%      mkdir('myapptests')
%
% ����A��������܂ޕϐ��́A�V���O���R�[�g�ň͂ޕK�v�͂���܂���B
%
%      dirname = 'myapptests';
%      mkdir(dirname)



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $Date:
