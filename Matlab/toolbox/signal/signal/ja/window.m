% WINDOW Window �֐� �Q�[�g�E�F�C
%
% WINDOW(@WNAME,N) �́A��x�N�g���ŁA�֐��n���h��@WNAME�ɂ��
% �w�肳���^�C�v��N-�_ �E�B���h�E��Ԃ��܂��B
% @WNAME �́A�C�ӂ̐������E�B���h�E�֐����ƂȂ�܂��B
% ���Ƃ��΁A���̂悤�Ȃ��̂ł��B:
%
%   @bartlett       - Bartlett �E�B���h�E
%   @barthannwin    - Modified Bartlett-Hanning �E�B���h�E 
%   @blackman       - Blackman �E�B���h�E
%   @blackmanharris - �ŏ�4��Blackman-Harris �E�B���h�E
%   @bohmanwin      - Bohman �E�B���h�E
%   @chebwin        - Chebyshev �E�B���h�E
%   @flattopwin     - Flat Top �E�B���h�E
%   @gausswin       - Gaussian �E�B���h�E
%   @hamming        - Hamming �E�B���h�E
%   @hann           - Hann �E�B���h�E
%   @kaiser         - Kaiser �E�B���h�E
%   @nuttallwin     - Nuttall �̒�`�ɂ��ŏ�4��Blackman-Harris �E�B���h�E
%   @parzenwin      - Parzen (de la Valle-Possin)�E�B���h�E
%   @rectwin        - �����`�E�B���h�E
%   @tukeywin       - Tukey �E�B���h�E
%   @triang         - �O�p�E�B���h�E
%
% WINDOW(@WNAME,N,OPT) �́AOPT�Ɏw�肳���I�v�V�����̓��͈���������
% �E�B���h�E��݌v���܂��B�I�v�V�����̓��͈����ɂ��Ēm�邽�߂ɂ́A
% ���Ƃ��΁A KAISER ���邢�� CHEBWIN �̂悤�ȁA�X�̃E�B���h�E��
% �w���v���Q�Ƃ��Ă��������B
%
% WINDOW �́AWindow Design & Analysis �c�[��(WinTool) ���N�����܂��B
%
% ���: 
%       N  = 65;
%       w  = window(@blackmanharris,N);
%       w1 = window(@hamming,N);
%       w2 = window(@gausswin,N,2.5);
%       plot(1:N,[w,w1,w2]); axis([1 N 0 1]);
%       legend('Blackman-Harris','Hamming','Gaussian');
% 
% �Q�l: BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, 
%       BOHMANWIN, CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER,
%       NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, TUKEYWIN.


%    Author(s): P. Costa 
%    Copyright 1988-2002 The MathWorks, Inc.
