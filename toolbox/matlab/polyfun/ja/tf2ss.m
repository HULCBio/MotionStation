% TF2SS   ��ԋ�ԕ\���̓`�B�֐�
% 
% [A,B,C,D] = TF2SS(NUM,DEN) �́A�P���͂���A�V�X�e��
% 
%             NUM(s) 
%     H(s) = --------
%             DEN(s)
%
% �̏�ԋ�ԕ\�����v�Z���܂��B
%
%     x = Ax + Bu
%     y = Cx + Du
% 
% �x�N�g�� DEN �́As �̍~�x�L���ɕ��ׂ�ꂽ����̌W�����܂܂Ȃ����
% �Ȃ�܂���B�s�� NUM �́A�o�� y �Ɠ����̍s���������A���q�̌W�����܂�
% �Ȃ���΂Ȃ�܂���B�s�� A�AB�AC�AD �́A�R���g���[���̕W���`�ŏo��
% ����܂��B���̌v�Z�́A���U�V�X�e���ɑ΂��Ă��g�p���܂��B
%
% ���U���ԓ`�B�֐��ɑ΂��Đ��������ʂ��m�ۂ��邽�߂ɁA���q�ƕ���̒���
% �𓙂������邱�Ƃ����������߂��܂��B���̍�Ƃ́ASignal Processing 
% Toolbox �̊֐� EQTFLENGTH ���g���čs�����Ƃ��ł��܂��B�������A����
% �֐��́A�P���͒P�o�̓V�X�e�������������Ƃ��ł��܂���B
%
% �Q�l�FTF2ZP, SS2TF, ZP2SS, ZP2TF.


%   J.N. Little 3-24-85
%   Copyright 1984-2003 The MathWorks, Inc.