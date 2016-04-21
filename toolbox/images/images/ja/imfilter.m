% IMFILTER �@�������C���[�W�̃t�B���^����
% B = IMFILTER(A,H) �́A�������t�B���^ H ���g���āA�������z�� A ���t�B��
% �^�����O���܂��BA �́A logical ���A�܂��͔C�ӂ̃N���X�Ǝ����̔�X�p�[�X
% �̐��l�z��ł��B���ʂ� B �́AA �Ɠ����T�C�Y�ƃN���X�������Ă��܂��B
%
% �o�� B �̌X�̗v�f�́A�{���x�̕��������_���g���Čv�Z���܂��BA ��
% �����z�񂩘_���z��̏ꍇ�A�^����ꂽ�^�C�v�͈̔͂𒴂����o�͗v�f�́A
% �ł��؂��A�����_�ȉ��͊ۂ߂��܂��B
%
% B = IMFILTER(A,H,OPTION1,OPTION2,...) �́A�w�肵�� OPTION �ɏ]���āA��
% �����̃t�B���^�����O���s���܂��BOPTION �����́A���̂����ꂩ��ݒ肵��
% ���B
%
%   - ���E�Ɋւ���I�v�V����
%
%       X            �z��̋��E�̊O�Ɉʒu������͔z��l�́A�A�I�ɁA�l X 
%                    �Ɖ��肵�܂��B���E�Ɋւ���I�v�V���������݂��Ȃ���
%                    ���AIMFILTER �́AX = 0 ���g���܂��B
%
%       'symmetric'  �z��̋��E�̊O�Ɉʒu������͔z��l�́A�z��̋��E��
%                    �ׂ��ŁA�z��̋������g���Čv�Z���܂��B
%
%       'replicate'  �z��̋��E�̊O�Ɉʒu������͔z��l�́A�ŋߖT�̔z��
%                    ���E�l�Ɠ������Ɖ��肵�Ă��܂��B
%
%       'circular'   �z��̋��E�̊O�Ɉʒu������͔z��l�́A���͔z�񂪁A
%                    �����I�ł���ƁA�A�I�ɉ��肵�Ă��܂��B
%
%   - �o�̓T�C�Y�I�v�V����
%     (IMFILTER �Ɋւ���o�̓T�C�Y�I�v�V�����́A�֐� CONV2 �� FILTER2 ��
%     SHAPE �I�v�V�����Ɏ��Ă��܂�)
%
%       'same'       �o�͔z��́A���͔z��Ɠ����T�C�Y�ł��B�o�͂Ɋւ���
%                    �T�C�Y�I�v�V�������ݒ肳��Ă��Ȃ��ꍇ�A�f�t�H���g
%                    �̋��������܂��B
%
%       'full'       �o�͔z��́A�t���̃t�B���^��K�p�������ʂŁA���̂�
%                    �߂ɁA���͔z����傫���Ȃ�܂��B
%
%   - ���ւƃR���{�����[�V����
%
%       'corr'       IMFILTER �́A���ւ��g���āA�������t�B���^������s��
%                    �܂��B
% �����ł́AFILTER2 ���s���t�B���^����Ɠ������@�ł��A���ցA�܂��́A�R��
% �{�����[�V�����A���ɁA�I�v�V���������݂��Ă��Ȃ��ꍇ�AIMFILTER �́A����
% ���g���܂��B
%
%       'conv'       IMFILTER �́A�R���{�����[�V�������g���āA��������
%                    �t�B���^������s���܂��B
% 
% ���
% -------------
%       rgb = imread('flowers.tif'); 
%       h = fspecial('motion',50,45); 
%       rgb2 = imfilter(rgb,h); 
%       imshow(rgb), title('Original') 
%       figure, imshow(rgb2), title('Filtered') 
%       rgb3 = imfilter(rgb,h,'replicate'); 
%       figure, imshow(rgb3), title('Filtered with boundary replication')
%
% �Q�l�F CONV2, CONVN, FILTER2. 



%   Copyright 1993-2002 The MathWorks, Inc. 
