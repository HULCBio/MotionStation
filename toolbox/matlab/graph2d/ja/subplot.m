% SUBPLOT   ������axes���쐬
% 
% H = SUBPLOT(m,n,p) �܂��� SUBPLOT(mnp) �́AFigure�E�B���h�E��m�sn��
% �̏�����axes�����E�B���h�E�ɕ������A�J�����g�v���b�g�� p �Ԗڂ�axes
% ��I�����Aaxes�̃n���h���ԍ����o�͂��܂��Baxes�́AFigure�E�B���h�E��
% ��ԏ�̍s�A����2�Ԗڂ̍s�A�̂悤�ɃJ�E���g����܂��B���Ƃ��΁A
% 
%     SUBPLOT(2,1,1), PLOT(income)
%     SUBPLOT(2,1,2), PLOT(outgo)
% 
% �́A�E�B���h�E�̏㔼���� income ���v���b�g���A�������� outgo ���v���b�g
% ���܂��B
% 
% SUBPLOT(m,n,p) �́Aaxes�����ɑ��݂���΁A����axes���J�����g�ɂ��܂��B
% SUBPLOT(m,n,p,'replace') �́Aaxes�����ɑ��݂��Ă���ꍇ�͂�����폜���A
% �V����axes���쐬���܂��B
% SUBPLOT(m,n,p,'align') �́A�v���b�g�{�b�N�X���A���x���ɖW������
% ���񂷂�悤�Ɏ����ʒu���A�d�Ȃ�Ȃ��悤�ɂ��܂��B
% overlapping. 
% SUBPLOT(m,n,P) �́AP ���x�N�g���̂Ƃ��AP �̒��Ƀ��X�g����Ă���T�u
% �v���b�g�̈ʒu���ׂĂ��J�o�[���� axes �̈ʒu��ݒ肵�܂��B
% 
% SUBPLOT(H) �́AH ��axes�̃n���h���ԍ��̂Ƃ��A��ɑ����v���b�g�R�}���h
% �ɑ΂��āAaxes���J�����g�Ƃ��邽�߂̂���1�̕��@�ł��B
%
% SUBPLOT('position',[left bottom width height]) �́A(0.0����1.0�͈̔͂�)
% ���K�����ꂽ���W�Ŏw�肵���ʒu��axes���쐬���܂��B
%
% SUBPLOT(m,n,p, PROP1, VALUE1, PROP2, VALUE2, ...)  �́Asubplot axis ��
% �w�肵���v���p�e�B�l�̑g��ݒ肵�܂��B �w�肵�� figure �� subplot 
% ��ǉ����邽�߂ɂ́A'Parent' �v���p�e�B�ɑ΂���l�Ƃ��āAfigure 
% �n���h����n���Ă��������B
%
% SUBPLOT �̎d�l���A�V����axes���g���ČÂ�axes������������悤�ȏꍇ�A
% ���ɑ��݂��Ă���Â�axes�͍폜����܂��B����́A�V����axes�̈ʒu�ƌÂ�
% axes�̈ʒu�������ʒu�̏ꍇ�͗�O�ł��B���Ƃ��΁A�X�e�[�g�����g 
% SUBPLOT(1,2,1)�́A���ׂĂ̑��݂��Ă���axes���폜���AFigure�E�B���h�E
% �̍��������������A���̕����ɐV����axes���쐬���܂��B�����ł��A�V����axes
% �̈ʒu�������ȈӖ��ň�v���Ȃ�(���� 'replace' ���w�肳��Ă��Ȃ�)����A
% ��q�����悤�ɂȂ�܂��B���̂悤�ȏꍇ�A�d�Ȃ��Ă��邷�ׂĂ�axes�͍폜
% ����A��v���Ă���axes���J�����g��axes�ɂȂ�܂��B
%  
% SUBPLOT(111) �́A��q�������[���̗�O�ł��B����́ASUBPLOT(1,1,1) ��
% ���������������܂���B���ʌ݊����̂��߂ɁAaxes�������ɍ쐬���Ȃ����ʂ�
% ���̂ŁA���̃O���t�B�b�N�X�R�}���h��figure�� CLF RESET �����s����悤��
% figure��ݒ肵(figure�̂��ׂĂ̎q�I�u�W�F�N�g���폜���܂�)�A�f�t�H���g�̈�
% �u�ɐV����axes�𐶐����܂��B���̃V���^�b�N�X�̓n���h�����o�͂��܂���B
% ���̂��߁A�o�͈������w�肷��ƃG���[�ɂȂ�܂��B��Ŏ��s����� CLF RESET 
% �́Afigure�� NextPlot �� 'replace' �ɐݒ肷�邱�ƂŊ������܂��B
%
% SUBPLOT(m,n,p,H) �́AH �� axes �̏ꍇ�A�w�肵���ʒu�ɁAH ���ړ����܂��B
% SUBPLOT(m,n,p,H,PROP1,VALUE1,...) �́AH ���ړ����A�w�肵���v���p�e�B
% �l�̑g��K�p���܂��B

%   Copyright 1984-2002 The MathWorks, Inc. 
