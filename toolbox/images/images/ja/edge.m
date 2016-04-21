% EDGE   ���x�C���[�W���̃G�b�W�̌��o
%
% EDGE �́A���x�܂��̓o�C�i���C���[�W I ���͂Ƃ��Ď�����āAI �Ɠ���
% �傫���̃o�C�i���C���[�W BW ���o�͂��܂��B�����ŁA�֐��́AI �̒���
% �G�b�W�����o����1���o�͂��A����ȊO��0�Ƃ��܂��B
% 
% EDGE �́A����6�̃G�b�W���o�@���T�|�[�g���܂��B
% 
% Sobel �@�́A���W���� Sobel �ߎ����g���ăG�b�W�̌��o���s���܂��BI �̌�
% �z���ő�ɂȂ�_���G�b�W�Ƃ��ďo�͂��܂��B
% 
% Prewitt �@�́A���W���� Prewitt �ߎ����g���ăG�b�W�̌��o���s���܂��BI 
% �̌��z���ő�ɂȂ�_���G�b�W�Ƃ��܂��B
% 
% Roberts �@�́A���W���� Roberts �ߎ����g���ăG�b�W���o���s���܂��BI ��
% ���z���ő�ɂȂ�_���G�b�W�Ƃ��܂��B
% 
% Gaussian �� Laplacian �@�́AGaussian �t�B���^�� Laplacian �ŁAI ���t�B
% ���^�����O������A�[���N���b�V���O�@���g���ăG�b�W���o���s���܂��B
% 
% zero-cross �@�́A���[�U���ݒ肵���t�B���^�ŁAI ���t�B���^�����O������
% �[���N���b�V���O�@���g���ăG�b�W���o���s���܂��B
% 
% Canny �@�́AI �̌��z�̋ɑ�����߂邱�Ƃɂ��G�b�W���o���s���܂��B����
% ���z�v�Z�ɂ́AGaussian �t�B���^�̔��W�����g���܂��B���̕��@�ł́A2��
% �X���b�V���z�[���h���g���āA�����G�b�W�Ǝア�G�b�W�����o���܂��B������
% �ア�G�b�W�������G�b�W�ɐڑ�����Ă���ꍇ�Ɍ���A�ア�G�b�W���o�͂Ɋ�
% �߂܂��B���̂��߁A���̕��@�́A���̕��@�ɔ�ׂăm�C�Y�̉e�����󂯂ɂ���
% ��萳�m�Ɏア�G�b�W�����o���܂��B
% 
% �ǂ̎�@���w�肷�邩�ɂ��A�K�p�ł���p�����[�^���قȂ�܂��B��@���w
% �肵�Ȃ��ꍇ�́AEDGE �́ASobel �@���g�p���܂��B
% 
% Sobel �@
% ------------
% BW = EDGE(I,'sobel') �́ASobel �@��ݒ肵�܂��B
% 
% BW = EDGE(I,'sobel',THRESH) �́ASobel �@�ɑ΂��銴�x�X���b�V���z�[���h
% ��ݒ肵�܂��BEDGE �́ATHRESH ���ア�G�b�W�����ׂĖ������܂��BTHRESH
%  ��ݒ肵�Ȃ����ATHRESH ����([])�ł���ꍇ�AEDGE �́A�����I�ɒl��I��
% ���܂��B
% 
% BW = EDGE(I,'sobel',THRESH,DIRECTION) �́ASobel �@�ɕ������������܂��B
% DIRECTION �́A'horizontal' �G�b�W�A'vertical' �G�b�W�A'both' (�f�t�H��
% �g)�̓��A�ǂ̕����̌��������s���邩��ݒ肷�镶����ł��B
% 
% [BW,thresh] = EDGE(I,'sobel',...) �́A�X���b�V���z�[���h�l���o�͂��܂��B
% 
% Prewitt �@
% -------------
% BW = EDGE(I,'prewitt') �́APrewitt �@��ݒ肵�܂��B
% 
% BW = EDGE(I,'prewitt',THRESH) �́APrewitt �@�ɑ΂��銴�x�X���b�V���z�[
% ���h��ݒ肵�܂��BEDGE �́ATHRESH ���ア�G�b�W�����ׂĖ������܂��B
% THRESH ��ݒ肵�Ȃ����ATHRESH ����([])�ł���ꍇ�AEDGE �͎����I�ɒl��
% �I�����܂��B
% 
% BW = EDGE(I,'prewitt',THRESH,DIRECTION) �́APrewitt �@�ɕ�������������
% ���BDIRECTION �́A'horizontal' �G�b�W�A'vertical' �G�b�W�A'both' (�f�t
% �H���g)�̓��A�ǂ̕����̌��������s���邩��ݒ肷�镶����ł��B
% 
% [BW,thresh] = EDGE(I,'prewitt',...) �́A�X���b�V���z�[���h�l���o�͂���
% ���B
% 
% Roberts �@
% -------------
% BW = EDGE(I,'roberts') �́ARoberts �@��ݒ肵�܂��B
% 
% BW = EDGE(I,'roberts',THRESH) �́ARoberts �@�ɑ΂��銴�x�X���b�V���z�[
% ���h��ݒ肵�܂��BEDGE �́ATHRESH ���ア�G�b�W�����ׂĖ������܂��B
% THRESH ��ݒ肵�Ȃ����ATHRESH ����([])�ł���ꍇ�AEDGE �͎����I�ɒl��
% �I�����܂��B
% 
% [BW,thresh] = EDGE(I,'roberts',...) �́A�X���b�V���z�[���h�l���o�͂���
% ���B
% 
% Gaussian �� Laplacian �@
% -------------
% BW = EDGE(I,'log') �́AGaussian �� Laplacian �@��ݒ肵�܂��B
% 
% BW = EDGE(I,'log',THRESH) �́AGaussian �� Laplacian �@�ɑ΂��銴�x�X��
% �b�V���z�[���h��ݒ肵�܂��BEDGE �́ATHRESH ���ア�G�b�W�����ׂĖ���
% ���܂��BTHRESH ��ݒ肵�Ȃ����ATHRESH ����([])�ł���ꍇ�AEDGE �͎���
% �I�ɒl��I�����܂��B
% 
% BW = EDGE(I,'log',THRESH,SIGMA) �́ASIGMA �� LoG �t�B���^�̕W���΍���
% ���Ďg�p���āAGaussian �� Laplacian �@��ݒ肵�܂��B�f�t�H���g�� SIGMA
% ��2�ł��B�����āA�t�B���^�̃T�C�Y�� N �s N ��ł��B�����ŁAN = CEIL(
% SIGMA*3)*2+1�ł��B
% 
% [BW,thresh] = EDGE(I,'log',...) �́A�X���b�V���z�[���h���o�͂��܂��B
% 
% Zero-cross �@
% -------------
% BW = EDGE(I,'zerocross',THRESH,H) �́A�ݒ肵���t�B���^ H ���g���āA
% zero-cross �@��ݒ肵�܂��BTHRESH ����([])�ł���ꍇ�AEDGE �͎����I��
% ���x�X���b�V���z�[���h��I�����܂��B
% 
% [BW,THRESH] = EDGE(I,'zerocross',...) �́A�X���b�V���z�[���h�l���o�͂�
% �܂��B
% 
% Canny �@
% -------------
% BW = EDGE(I,'canny') �́ACanny �@��ݒ肵�܂��B
% 
% BW = EDGE(I,'canny',THRESH) �́ACanny �@�ɑ΂��銴�x�X���b�V���z�[���h
% ��ݒ肵�܂��BTHRESH �́A��1�v�f���Ⴂ�X���b�V���z�[���h�A��2�v�f����
% ���X���b�V���z�[���h�ł���2�v�f�x�N�g���ł��BTHRESH �ɃX�J����ݒ肷��
% �ꍇ�A���̒l�������X���b�V���z�[���h�A0.4*THRESH ��Ⴂ�X���b�V���z�[
% ���h�ɐݒ肵�܂��BTHRESH ��ݒ肵�Ȃ����ATHRESH ����([])�ł���ꍇ�A
% EDGE �́A�����I�ɒႢ�l�ƍ����l��I�����܂��B
% 
% BW = EDGE(I,'canny',THRESH,SIGMA) �́ASIGMA �� Gaussian �t�B���^�̕W��
% �΍��Ƃ��Ďg�p���āACanny �@��ݒ肵�܂��B�f�t�H���g�� SIGMA ��1�ł��B
% �����āASIGMA �Ɋ�Â��āA���̃t�B���^�̃T�C�Y�������I�ɑI�����܂��B
% 
% [BW,thresh] = EDGE(I,'canny',...) �́A�X���b�V���z�[���h�l��2�v�f�x�N
% �g���Ƃ��ďo�͂��܂��B
% 
% �N���X�T�|�[�g
% -------------
% I �́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X���T�|�[�g���Ă���
% ���BBW �́A�N���X uint8 �ł��B
% 
% ����
% -------
% 'log' �� 'zerocross' �@�ɑ΂��āA0�̃X���b�V���z�[���h��ݒ肷��ꍇ�A
% �o�̓C���[�W�͕����R���^�[�Q�ɂȂ�܂��B����́A���̓C���[�W�̒��Ń[
% ���N���X���镔�������ׂĊ܂ނ��߂ł��B
% 
% ���
% -------
% Prewitt �@�� Canny �@���g���āArice.tif �C���[�W�̃G�b�W���o���s���܂��B
% 
%       I = imread('rice.tif');
%       BW1 = edge(I,'prewitt');
%       BW2 = edge(I,'canny');
%       imshow(BW1)
%       figure, imshow(BW2)
%
% �Q�l�FFSPECIAL.



%   Copyright 1993-2002 The MathWorks, Inc.  
