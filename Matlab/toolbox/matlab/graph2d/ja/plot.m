%PLOT   Linear plot. 
% PLOT(X,Y) �́A�x�N�g�� X �ɑ΂��ăx�N�g�� Y ���v���b�g���܂��BX �܂���
% Y ���s��̏ꍇ�A�s��̍s�܂��͗�̂ǂ��炩�ɑ΂��āA�x�N�g�����v���b�g
% ����܂��BX ���X�J���� Y ���x�N�g���̏ꍇ�́Alength(Y) �̃f�[�^��ڑ�
% ����Ȃ��_�Ƃ��ăv���b�g���܂��B
%
% PLOT(Y) �́AY �̃C���f�b�N�X�ɑ΂��� Y �̗���v���b�g���܂��BY �����f��
% �̏ꍇ�APLOT(Y) �� PLOT(real(Y),imag(Y)) �Ɠ����ł��B����ȊO�� PLOT 
% �̎g�p�ł́A�����͖�������܂��B
%
% PLOT(X,Y,S) ���g���āA���C���^�C�v�A�v���b�g�V���{���A�J���[���w��
% �ł��܂��BS �́A����3��̂����ꂩ�܂��͂��ׂĂ̂�����1�v�f�ɂ��
% �L�����N�^������ł��B
%
%        b     ��            .     �_               -     ����
%        g     ��            o     �~               :     �_��
%        r     ��            x     x��              -.    ���� 
%        c     �V�A��        +     �v���X�L��       --    �j��   
%        m     �}�[���^      *     ����           (none)  ���Ȃ�
%        y     ��            s     �����`
%        w     ��            d     �_�C�A�����h
%        k     ��            v     �O�p�`(�����)
%                            ^     �O�p�`(������)
%                            <     �O�p�`(������)
%                            >     �O�p�`(�E����)
%                            p     �܊p�`
%                            h     �Z�p�`
%
% ���Ƃ��΁APLOT(X,Y,'c+:') �́A�e�f�[�^�_���v���X�L���Ńv���b�g���A
% ���̊Ԃ��V�A���F�̓_���Ō��т܂��BPLOT(X,Y,'bd') �́A�e�f�[�^�_��F
% �̃_�C�A�����h�Ńv���b�g���A���͕`�悵�܂���B
%
% PLOT(X1,Y1,S1,X2,Y2,S2,X3,Y3,S3,...) �́A(X,Y,S) ��3�v�f�Œ�`���ꂽ
% �v���b�g��g�ݍ��킹�܂��B�����ŁAX �� Y �̓x�N�g���܂��͍s��ŁAS ��
% ������ł��B
%
% ���Ƃ��΁APLOT(X,Y,'y-',X,Y,'go') �́A�f�[�^��2��v���b�g���A�ΐF�̉~��
% �f�[�^�_��\�킵�A���̊Ԃ����F�̎����Ō��т܂��B
%
% PLOT�́A�J���[���w�肳��Ȃ���΁Aaxes�� ColorOrder �v���p�e�B�Ŏw��
% ���ꂽ�J���[���g���Ď����I�ɃJ���[��I�����܂��B�f�t�H���g�� ColorOrder
% �́A1�̃��C���ɑ΂��Ă̓f�t�H���g���F�ŁA�������C���ɑ΂��Ă̓e�[�u��
% �̍ŏ���6��ނ̃J���[���z����A�J���[�V�X�e���̃e�[�u���Ƀ��X�g����
% �Ă��܂��B���m�N���̃V�X�e���ɑ΂��ẮAPLOT ��axes�� LineStyleOrder 
% �v���p�e�B���z�����܂��B 
%
% �}�[�J�̃^�C�v���w�肵�Ȃ��ꍇ�APLOT �́A�}�[�J���g�p���܂���B 
% ���C���X�^�C�����w�肵�Ȃ��ꍇ�APLOT �́A�������g�p���܂��B
%
% PLOT(AX,...) �́A�n���h��AX �������Ƀv���b�g���܂��B
%
% PLOT �́Alineseries �I�u�W�F�N�g�̃n���h���̗�x�N�g�����o�͂��܂��B
% �v���b�g���C���ɖ��ɁA1�̃n���h�����o�͂��܂��B 
%
% X �� Y �̑g�A�܂��� X�AY�AS ��3�v�f�̂��ɂ́A���C���̒ǉ��̃v���p�e�B
% ���w�肷�邽�߂̃p�����[�^�ƒl�̑g���w�肵�܂��B
% ���Ƃ��΁APLOT(X,Y,'LineWidth',2,'Color',[.6 0 0]) �́A
% ���C������2 �|�C���g�̃_�[�N���b�h�̃v���b�g���쐬���܂��B
%
% ���ʌ݊���
%   PLOT('v6',...) �́AMATLAB 6.5, ����сA����ȑO�̃o�[�W�����Ƃ�
%�@ �݊����̂��߂ɁAlineseries �I�u�W�F�N�g�ł͂Ȃ��Aline �I�u�W�F�N�g
%   ���쐬���܂��B
%  
%   �Q�l PLOTTOOLS, SEMILOGX, SEMILOGY, LOGLOG, PLOTYY, PLOT3, GRID,
%   TITLE, XLABEL, YLABEL, AXIS, AXES, HOLD, LEGEND, SUBPLOT, SCATTER.

%   NextPlot axes �v���p�e�B�� "replace" (HOLD �� off)�̏ꍇ�APLOT ��
%   Position �������A���ׂĂ� axes �v���p�e�B���f�t�H���g�l�Ƀ��Z�b�g
%�@ ���A���ׂĂ� axes children (line, patch, text, surface, 
%   image �I�u�W�F�N�g) ���폜���AView �v���p�e�B�� [0 90] �ɐݒ肵�܂��B

%   Copyright 1984-2004 The MathWorks, Inc. 
