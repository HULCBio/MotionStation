% INSTRCALLBACK   �C�x���g�Ɋւ������\��
%
% INSTRCALLBACK(OBJ, EVENT) �́A�C�x���g�̃^�C�v�A���ԁA�C�x���g�𐶂�
% �����錴���ƂȂ�I�u�W�F�N�g�����܂ރ��b�Z�[�W��\�����܂��B
%
% �G���[�C�x���g���������ꍇ�A�G���[���b�Z�[�W���\������܂��B
% �s���C�x���g�����������ꍇ�A�s����ύX�����l�ƃs���̒l���\������܂��B
%
% INSTRCALLBACK �́A�R�[���o�b�N�֐��̗�ł��B���[�U���g�̃R�[���o�b�N
% �֐����L�q���邽�߂Ƀe���v���[�g�Ƃ��Ă��̃R�[���o�b�N�֐����g�p����
% ���������B
%
% ���:
%       s = serial('COM1');
%       set(s, 'OutputEmptyFcn', {'instrcallback'});
%       fopen(s);
%       fprintf(s, '*IDN?', 'async');
%       idn = fscanf(s);
%       fclose(s);
%       delete(s);
%


%    MP 2-24-00
%    Copyright 1999-2002 The MathWorks, Inc. 
