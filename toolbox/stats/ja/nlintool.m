% NLINTOOL   ����`�t�B�b�e���O�Ɨ\�����s���Θb�`���̃O���t�B�J���c�[��
%
% NLINTOOL(X,Y,FUN,BETA0,ALPHA) �́A(x,y)�f�[�^�ɔ���`�Ȑ����t�B�b�g
% �������\���}���쐬���܂��B2�̐ԐF�̋Ȑ��́A100(1-ALPHA)%��\�킷
% �M����Ԃ������܂��B
% 
% Y �̓x�N�g���ł��BX �̓x�N�g���A�܂��� Y �Ɠ����s���̍s��ł��BFUN �́A
% �W���x�N�g���� X �̒l�̔z���2�̈������󂯓���āA�t�B�b�g���� Y ��
% �l�̃x�N�g�����o�͂���֐��ł��BBETA0 �́A�W���ɑ΂��鏉������l���܂�
% �x�N�g���ł��BALPHA �̃f�t�H���g�l�́A0.05�ŁA95%�̐M����ԂɑΉ����܂��B
% 
% NLINTOOL(X,Y,FUN,BETA0,ALPHA,XNAME,YNAME) �́AX �� Y �̕ϐ��Ƃ��āA
% �I�v�V���������� XNAME �� YNAME ��ݒ肵�܂��B
% 
% % ���F�̓_���̊�����h���b�O���邱�Ƃ��ł��A�h���b�O�Ɠ����ɗ\���l��
% �X�V����܂��B�܂��A�G�f�b�B�g�\�ȃe�L�X�g�t�B�[���h��"X"�l�����
% ���邱�ƂŁA�w�肵���\���l�𓾂邱�Ƃ��ł��܂��BExport �ƃ��x���������
% ����v�b�V���{�^�����g���āA��{�̃��[�N�X�y�[�X�ɐݒ肵���ϐ���n��
% ���Ƃ��ł��܂��B�M����Ԃ̃^�C�v��ύX����ɂ́ABounds ���j���[��
% �g�p���Ă��������B
%
% ���
% ----
%   FUN �́A@ ���g���Ďw�肷�邱�Ƃ��ł��܂��B:
%      nlintool(x, y, @myfun, b0)
%   �����ŁAMYFUN �͈ȉ��̂悤��MATLAB�֐��ł��B:
%      function yhat = myfun(beta, x)
%      b1 = beta(1);
%      b2 = beta(2);
%      yhat = 1 ./ (1 + exp(b1 + b2*x));
%
%   FUN �́A�C�����C���I�u�W�F�N�g�ł��\���܂���B:
%      fun = inline('1 ./ (1 + exp(b(1) + b(2)*x))', 'b', 'x')
%      nlintool(x, y, fun, b0)
%
% �Q�l : NLINFIT, NLPARCI, NLPREDCI.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/02/12 17:14:07 $
