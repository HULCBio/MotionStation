% EVALFIS1 �́A�t�@�W�B���_�V�X�e�����v�Z���܂��B
% OUTPUT_STACK = EVALFIS1(INPUT_STACK, FISMATRIX) �́AFISMATRIX �Őݒ肳
% ���t�@�W�B���_�V�X�e���̏o�͂��v�Z���܂��BINPUT_STACK �́A���̓x�N�g
% ���A�܂��́A�s���ݒ肷��x�N�g���ŁA�s��̏ꍇ�A�e�s�͓��̓x�N�g����
% �w�肵�܂��BOUTPUT_STACK �́A�o��(�s)�x�N�g���̃X�^�b�N�ł��B
%
% ���F
%
%       [xx, yy] = meshgrid(-5:5);
%       input = [xx(:) yy(:)];
%       fismat = readfis('mam21');
%       out = evalfis(input, fismat);
%       surf(xx, yy, reshape(out, 11, 11))
%       title('evalfis')

