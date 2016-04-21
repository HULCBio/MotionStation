% STRINGS   MATLAB�̃L�����N�^������
% 
% S = 'Any Characters' �́A�L�����N�^�ɑ΂��鐔�l�R�[�h��v�f�Ƃ���x�N
% �g���ł�(�ŏ���127�̃R�[�h��ASCII�ł�)�B�\���������ۂ̃L�����N�^�́A
% �^����ꂽ�t�H���g�ɑ΂���L�����N�^�Z�b�g�̕������ɂ��قȂ�܂��B
% S �̒����́A�L�����N�^���ł��B��������̃R�[�e�[�V�����́A2�̃R�[�e�[
% �V�������g���ĕ\�킳��܂��B
%   
% S = [S1 S2 ...] �́A�z�� S1, S2,...��V�����L�����N�^�z�� S �ɘA�����܂��B
%
% S = strcat(S1, S2, ...) �́A�L�����N�^�z��A�܂��͕����̃Z���z�� S, S2,... 
% ��A�����܂��B���͂����ׂăL�����N�^�z��̏ꍇ�́A�o�͂��L�����N�^�z��
% �ɂȂ�܂��B���͂̂����ꂩ�������̃Z���z��̏ꍇ�́ASTRCAT �́A������
% �Z���z��ɂȂ�܂��B
%
% STRCAT �L�����N�^�z����͂̒��ŁA��ɑ����Ă���X�y�[�X�͖�������A
% �o�͂ɂ͕\��܂��񂪁A�����̃Z���z��ł��� STRCAT ���͂ɑ΂��Ă�
% ����������܂���B��q���� S = [S1 S2 ...]  �A���V���^�b�N�X���g���āA
% ��ɑ����X�y�[�X��ۑ����܂��B
%
% S = CHAR(X) �́A�L�����N�^�R�[�h��\�킷���̐������܂ޔz����AMATLAB
% �L�����N�^�z��ɕϊ����邽�߂Ɏg�p���܂��B 
%
% X = DOUBLE(S) �́A������𓙉��Ȕ{���x�̐��l�R�[�h�ɕϊ����܂��B
%
% ������̏W���́A2��ނ̕��@�ō쐬����܂��B1) STRVCAT �ɂ��L�����N�^
% �z��̍s�Ƃ��āB 2) �����ʂɂ�蕶����̃Z���z��Ƃ��āB����2�̕��@
% �͈قȂ��Ă��܂����ACHAR �� CELLSTR ���g���ĕϊ������ɖ߂����Ƃ��ł�
% �܂��B�قƂ�ǂ̕�����֐��́A�����̃^�C�v���T�|�[�g���Ă��܂��B
%
% S ���L�����N�^�z��(������)�̏ꍇ�� ISCHAR(S) ���AS �������񂩂�Ȃ�
% �Z���z��̏ꍇ�� ISCELLSTR(S) ���g�����Ƃ��ł��܂��B
%
% ���
% 
%       msg = 'You''re right!'
%       name = ['Thomas' ' R. ' 'Lee']
%       name = strcat('Thomas',' R.',' Lee')
%       C = strvcat('Hello','Yes','No','Goodbye')
%       S = {'Hello' 'Yes' 'No' 'Goodbye'}
%
% �Q�l�FTEXT, CHAR, CELLSTR, DOUBLE, ISCHAR, ISCELLSTR, STRVCAT,
%       STRFUN, SPRINTF, SSCANF, INPUT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:07:11 $
