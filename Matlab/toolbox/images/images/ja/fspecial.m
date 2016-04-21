% FSPECIAL 2�����̎w�肵���^�C�v�̃t�B���^�̍쐬
% H = FSPECIAL(TYPE) �w�肵���^�C�v��2�����t�B���^ H ���쐬���܂��BTYPE
% �ɑ΂��āA�\�Ȓl�́A���̂��̂ł��B
%
%     'average'   ���ω��t�B���^
%     'disk'      ���񕽋ω��t�B���^
%     'gaussian'  Gaussian ���[�p�X�t�B���^
%     'laplacian' 2���� Laplacian ���Z�q���ߎ�����t�B���^
%     'log'       Gaussian �t�B���^�� Laplacian
%     'motion'    ���[�V�����t�B���^
%     'prewitt'   Prewitt ���������G�b�W�����t�B���^
%     'sobel'     Sobel ���������G�b�W�����t�B���^
%     'unsharp'   �N���łȂ��R���g���X�g����������t�B���^
%
% TYPE �Ɉˑ����āAFSPECIAL �́A�ݒ�ł���t���I�ȃp�����[�^���g�p����
% ���Ƃ��ł��܂��B�����̃p�����[�^�ɂ́A���ׂăf�t�H���g�l���p�ӂ���
% �Ă��܂��B
%
% H = FSPECIAL('average',HSIZE) �́A�T�C�Y HSIZE �̕��ω��t�B���^ H ��
% �߂��܂��BHSIZE �́AH �̍s���Ɨ񐔂��w�肷��x�N�g���ł��邩�A�܂��́A
% H �������s��̏ꍇ�A���̑傫����ݒ肷��X�J���l�ł��B
% �f�t�H���g�� HSIZE �́A[3 3] �ł��B
%
% H = FSPECIAL('disk',RADIUS) �́A2*RADIUS+1 �̑傫���̐����s��ɂȂ�
% ���񕽋ω��t�B���^��߂��܂��B�f�t�H���g�� RADIUS �́A5�ł��B
%
% H = FSPECIAL('gaussian',HSIZE,SIGMA) �́A�W���΍� SIGMA(��)�����T�C
% �Y HSIZE �̓_�Ώ� Gaussian ���[�p�X�t�B���^��߂��܂��BHSIZE �́AH ��
% �s���Ɨ񐔂��w�肷��x�N�g���ł��邩�A�܂��́AH �������s��̏ꍇ�A��
% �̑傫����ݒ肷��X�J���l�ł��BHSIZE �̃f�t�H���g�l�́A[3 3]�ŁASI-
% GMA �̃f�t�H���g��0.5�ł��B
%
% H = FSPECIAL('laplacian',ALPHA) �́A2������ Laplacian ���Z�q�̌^�ɋߎ�
% ����3�s3��̃t�B���^�ł��B�p�����[�^ ALPHA �́ALaplacian �̌^���R���g
% ���[��������̂ŁA0.0��1.0 �̊Ԃ̒l�ł��BALPHA �̃f�t�H���g�l�́A0.2 
% �ł��B
%
% H = FSPECIAL('log',HSIZE,SIGMA) �́A�W���΍� SIGMA(��)�����T�C�Y HSI-
% ZE �� Gaussian �t�B���^�̓_�Ώ� Laplacian ���o�͂��܂��BHSIZE �́AH ��
% �s���Ɨ񐔂��w�肷��x�N�g���ł��邩�A�܂��́AH �������s��̏ꍇ�A����
% �傫����ݒ肷��X�J���l�ł��BHSIZE �̃f�t�H���g�l�́A[5 5]�ŁASIGMA ��
% �f�t�H���g��0.5�ł��B
%
% H = FSPECIAL('motion',LEN,THETA) �́A�C���[�W�ƃR���{�����[�V�������A
% LEN �s�N�Z�����A�J�����̐��`�ړ����s���A�����v����� THETA �x�̉�]��
% �����ʂ��o�͂��܂��B�t�B���^�́A���������Ɛ��������ւ̓�������������
% �̂ł��B�f�t�H���g�� LEN ��9�ŁA�f�t�H���g�� THETA ��0�ŁA����́A����
% ������9�s�N�Z���ړ��������̂ɑΉ����܂��B
%
% H = FSPECIAL('prewitt') �́A���������̌��z���ߎ����邱�Ƃɂ��A������
% ���̃G�b�W����������3�s3��̃t�B���^���o�͂��܂��B�����G�b�W����������
% �K�v������ꍇ�A�t�B���^H ��]�u H' ���Ă��������B
%
%       [1 1 1;0 0 0;-1 -1 -1].
%
% H = FSPECIAL('sobel') �́A���������̌��z���ߎ����邱�Ƃɂ��A��������
% �e���𗘗p���āA���������̃G�b�W����������3�s3��̃t�B���^��߂��܂��B
% ���������̃G�b�W�������������ꍇ�A�t�B���^H ��]�u H' ���s���Ă��������B
%
%       [1 2 1;0 0 0;-1 -2 -1].
%
% H = FSPECIAL('unsharp',ALPHA) �́A3�s3��ŁA�R���g���X�g����������t�B
% ���^��߂��܂��BFSPECIAL �́A�p�����[�^ ALPHA ���g���āALaplacian �t�B
% ���^�̕��̕����𗘗p���āA�R���g���X�g���͂����肵�Ȃ��t�B���^���쐬��
% �܂��BALPHA �́ALaplacian �̌^���R���g���[��������̂ŁA0.0 ���� 1.0 
% �̊Ԃ̒l�ł��A�f�t�H���g�́A ALPHA = 0.2 �ł��B
%
% �N���X�T�|�[�g
% -------------
% H �́A�N���X double �ł��B
%
% ���
% -------
%      I = imread('saturn.tif');
%      subplot(2,2,1);imshow(I);title('Original Image'); 
%      H = fspecial('motion',50,45);
%      MotionBlur = imfilter(I,H);
%      subplot(2,2,2);imshow(MotionBlur);title('Motion Blurred Image');
%      H = fspecial('disk',10);
%      blurred = imfilter(I,H);
%      subplot(2,2,3);imshow(blurred);title('Blurred Image');
%      H = fspecial('unsharp');
%      sharpened = imfilter(I,H);
%      subplot(2,2,4);imshow(sharpened);title('Sharpened Image');
%       
% �Q�l�FCONV2, EDGE, FILTER2, FSAMP2, FWIND1, FWIND2, IMFILTER.



%   Copyright 1993-2002 The MathWorks, Inc.  
