% Signal Processing Toolbox 
% Version 6.2 (R14) 05-May-2004 
%
% �t�B���^���
% abs        - ��Βl
% angle      - �ʑ��p
% filternorm - �f�B�W�^���t�B���^��2-�m�����܂���inf-�m�������v�Z
% freqs      - �A�i���O�t�B���^�̎��g������
% freqspace  - ���g�������̂��߂̎��g���f�[�^��̍쐬
% freqz      - �f�B�W�^���t�B���^�̎��g������
% freqzplot  - ���g�������f�[�^�̃v���b�g
% fvtool     - �t�B���^���o���c�[��
% grpdelay   - �Q�x��
% impz       - �f�B�W�^���t�B���^�̃C���p���X����
% phasez     - �f�B�W�^���t�B���^�̈ʑ�����
% phasedelay - �f�B�W�^���t�B���^�̈ʑ��x��
% unwrap     - �ʑ��p�̘A����
% zerophase  - ���ۂ̃t�B���^�̃[���ʑ�����
% zplane     - ��_- �ɂ̃v���b�g
%
%�t�B���^�̎���
% conv       - �R���{�����[�V����
% conv2      - 2�����R���{�����[�V����
% deconv     - �f�R���{�����[�V�����A�������̏��Z
% fftfilt    - �I�[�o���b�v�@���g����FFT�x�[�XFIR�t�B���^�����O
% filter     - ����^�A�񏄉�^�t�B���^�ɂ��f�[�^�̃t�B���^�����O
% filter2     - 2�����f�B�W�^���t�B���^
% filtfilt   - �[���ʑ��f�B�W�^���t�B���^�����O
% filtic     - �֐�filter�ɑ΂��鏉���l�̐ݒ�
% latcfilt   - ���e�B�X�t�B���^�ƃ��e�B�X�|���_�[�t�B���^�̎���
% medfilt1   - 1�������f�B�A���t�B���^
% sgolayfilt - Savitzky-Golay �t�B���^����
% sosfilt    - 2���^�\����IIR�t�B���^����
% upfirdn    - �A�b�v�T���v���AFIR �t�B���^�A�_�E���T���v��
%
% FIR �t�B���^�݌v
% convmtx    - �R���{�����[�V�����s��
% cremez     - ���f��������`�ʑ��̓����b�v��FIR�t�B���^�݌v
% fir1       - �E�B���h�E�x�[�X�̗L���C���p���X�����t�B���^�̐݌v
%              (�W������)
% fir2       - �E�B���h�E�x�[�X�̗L���C���p���X�����t�B���^�̐݌v
%             (�C�Ӊ���)
% fircls     - �����ш�t�B���^�ɑ΂�������t���ŏ���� FIR�t�B���^�̐�
%              �v
% fircls1    - ���[�p�X����уn�C�p�X���`�ʑ� FIR�t�B���^�ɑ΂�������t
%              ���ŏ���� FIR�t�B���^�̐݌v
% firgauss   - FIR Gaussian �f�B�W�^���t�B���^�݌v
% firls      - �ŏ������`�ʑ�FIR�t�B���^�̐݌v
% firrcos    - �R�T�C�����[���I�tFIR�t�B���^�̐݌v
% intfilt    - ���FIR�t�B���^�̐݌v
% kaiserord  - Kaiser �E�B���h�E���g����FIR�t�B���^�̃p�����[�^����
% remez      - Parks-McClellan �œKFIR�t�B���^�݌v
% remezord   - Parks-McClellan �œKFIR�t�B���^��������
% sgolay     - Savitzky-Golay FIR�t�B���^�݌v
%
% IIR �f�B�W�^���t�B���^�݌v
% butter     - Butterworth �t�B���^�̐݌v
% cheby1     - Chebyshev I �^�t�B���^�̐݌v(�ʉߑш惊�b�v��)
% cheby2     - Chebyshev II �^�t�B���^�̐݌v(�Ւf�ш惊�b�v��)
% ellip      - �ȉ~�t�B���^�̐݌v
% maxflat    - �ėp�f�B�W�^�� Butterworth �t�B���^�̐݌v
% yulewalk   - ����^�f�B�W�^���t�B���^�̐݌v
%
% IIR �t�B���^�̎����̐���
% buttord    - Butterworth �t�B���^�̎�������
% cheb1ord   - Chebyshev I�^�t�B���^�̎�������
% cheb2ord   - Chebyshev II�^�t�B���^�̎�������
% ellipord   - �ȉ~�t�B���^�̎�������
%
% �A�i���O���[�p�X�v���g�^�C�v�݌v
% besselap   - Bessel �A�i���O���[�p�X�t�B���^�̃v���g�^�C�v
% buttap     - Butterworth �A�i���O���[�p�X�t�B���^�̃v���g�^�C�v
% cheb1ap    - Chebyshev I�^�A�i���O���[�p�X�t�B���^�̃v���g�^�C�v
%              (�ʉߑш惊�b�v��)
% cheb2ap    - Chebyshev II�^�A�i���O���[�p�X�t�B���^�̃v���g�^�C�v
%              (�Ւf�ш惊�b�v��)
% ellipap    - �ȉ~�A�i���O���[�p�X�t�B���^�̃v���g�^�C�v
%
% �A�i���O�t�B���^�݌v
% besself    - Bessel �A�i���O�t�B���^�̐݌v
% butter     - Butterworth �t�B���^�̐݌v
% cheby1     - Chebyshev I �^�t�B���^�̐݌v
% cheby2     - Chebyshev II �^�t�B���^�̐݌v
% ellip      - �ȉ~�t�B���^�̐݌v
%
% �A�i���O���g���ϊ�
% lp2bp      - ���[�p�X�t�B���^�v���g�^�C�v���o���h�p�X�A�i���O�t�B���^
%              �֕ϊ�
% lp2bs      - ���[�p�X�t�B���^�v���g�^�C�v���o���h�X�g�b�v�A�i���O�t�B
%              ���^�֕ϊ�
% lp2hp      - ���[�p�X�t�B���^�v���g�^�C�v���n�C�p�X�A�i���O�t�B���^��
%              �ϊ�
% lp2lp      - ���[�p�X�t�B���^�v���g�^�C�v�����[�p�X�A�i���O�t�B���^��
%              �ϊ�
%
% �t�B���^�̗��U��
% bilinear   - �o�ꎟ�ϊ����g�����ϐ��̃}�b�s���O(�ݒ���g���ɂ��āA�}
%              �b�s���O�O��ŁA���������킹��I�v�V�����t��)
% impinvar   - �A�i���O����f�B�W�^���t�B���^�ϊ��ւ̃C���p���X�s�ω���
%              �@
%
% ���`�V�X�e���ϊ�
% latc2tf    - ���e�B�X�A�܂��́A���e�B�X-���_�[�t�B���^����`�B�֐��^��
%              �̕ϊ�
% polystab   - �������̈��艻
% polyscale  - �������̍��̃X�P�[�����O 
% residuez   - z�ϊ��ł̕��������ϊ�
% sos2ss     - 2���^�\�������ԋ�Ԍ^�ւ̕ϊ�
% sos2tf     - 2���^�\������`�B�֐��^�ւ̕ϊ�
% sos2zp     - 2���^�\�������_�|�Ɍ^�ւ̕ϊ�
% ss2sos     - ��ԋ�Ԍ^����2���^�\���ւ̕ϊ�
% ss2tf      - ��ԋ�Ԍ^����`�B�֐��^�ւ̕ϊ�
% ss2zp      - ��ԋ�Ԍ^�����_�|�Ɍ^�ւ̕ϊ�
% tf2latc    - �`�B�֐��^���烉�e�B�X-���_�[�t�B���^�ւ̕ϊ�
% tf2sos     - �`�B�֐��^����2���^�\���ւ̕ϊ�
% tf2ss      - �`�B�֐��^�����ԋ�Ԍ^�ւ̕ϊ�
% tf2zpk     - ���U���ԓ`�B�֐��^�����_�|�Ɍ^�ւ̕ϊ�
% zp2sos     - ��_�|�Ɍ^����2���^�\���ւ̕ϊ�
% zp2ss      - ��_�|�Ɍ^�����ԋ�Ԍ^�ւ̕ϊ�
% zp2tf      - ��_�|�Ɍ^����`�B�֐��^�ւ̕ϊ�
%
% �E�B���h�E
% bartlett   - Bartlett �E�B���h�E
% barthannwin    - �C��Bartlett-Hanning�E�B���h�E 
% blackman   - Blackman �E�B���h�E
% blackmanharris - �ŏ�4-��Blackman-Harris�E�B���h�E
% boxcar     - ���^�E�B���h�E
% chebwin    - Chebyshev �E�B���h�E
% gausswin   - Gaussian�E�B���h�E
% hamming    - Hamming �E�B���h�E
% hann       - Hann �E�B���h�E
% kaiser     - Kaiser �E�B���h�E
% nuttallwin - Nuttall�̒�`�̍ŏ�4-��Blackman-Harris�E�B���h�E
% parzenwin  - Parzen (de la Valle-Poussin) �E�B���h�E
% rectwin    - �����`�̃E�B���h�E
% triang     - �O�p�E�B���h�E
% tukeywin   - Tukey�E�B���h�E
% wvtool     - �E�B���h�E���o���c�[��
% window     - Window�֐��Q�[�g�E�F�C
%
% �ϊ�
% bitrevorder - ���͂��r�b�g���]���������ɕ��בւ�
% czt        - Chirp-z �ϊ�
% dct        - ���U�R�T�C���ϊ�(DCT)
% dftmtx     - ���U�t�[���G�ϊ��s��
% fft        - 1���������t�[���G�ϊ�
% fft2       - 2���������t�[���G�ϊ�
% fftshift   - fft��fft2�̏o�͂̕��בւ�
% goertzel   - 2��Goertzel�A���S���Y��
% hilbert    - Hilbert �ϊ�
% idct       - �t���U�R�T�C���ϊ�
% ifft       - 1�����t�����t�[���G�ϊ�
% ifft2      - 2�����t�����t�[���G�ϊ�
%
% �Z�v�X�g�������
% cceps      - ���f�Z�v�X�g�������
% icceps     - �t���f�Z�v�X�g����
% rceps      - �����Z�v�X�g�����ƍŏ��ʑ�����
%
% ���v�I�ȐM������
% cohere     - 2�̐M���Ԃ̓��R�q�[�����X�֐��̐���
% corrcoef   - ���֌W���s��
% corrmtx    - ���ȑ��֍s��
% cov        - �����U�s��
% csd        - 2�̐M���̑��݃X�y�N�g�����x(CSD)�̐���
% pcov       - �����U�@���g�����p���[�X�y�N�g���̐���
% peig       - �ŗL�x�N�g���@���g�����p���[�X�y�N�g���̐���
% pmcov      - �C�������U�@���g�����p���[�X�y�N�g���̐���
% pburg      - Burg �@���g�����p���[�X�y�N�g���̐���
% periodogram - �s���I�h�O�����@���g�����p���[�X�y�N�g���̐���
% pmtm       - Thomson �� Multitaper �@(MTM)���g�����p���[�X�y�N�g���̐�
%              ��
% pmusic     - MUSIC �@���g�����p���[�X�y�N�g���̐��� 
% psdplot    - �p���[�X�y�N�g�����x�f�[�^�̃v���b�g
% pyulear    - Yule-Walker AR �@���g�����p���[�X�y�N�g���̐���
% pwelch     - Welch �@���g�����p���[�X�y�N�g���̐���
% rooteig    - �ŗL�x�N�g���A���S���Y�����g�������a�֐��̎��g���ƃp���[
%              �̌v�Z
% rootmusic  - MUSIC �A���S���Y�������g�������a�֐��̎��g���ƃp���[�̌v
%              �Z
% tfe        - ���͂Əo�͂���`�B�֐��̐���
% xcorr      - ���ݑ��֊֐��̐���
% xcorr2     - 2�����̑��ݑ��֊֐��̐���
% xcov       - ���݋����U�֐�(�f�[�^�񂩂畽�ϒl���폜�������ݑ���)�̐�
%              ��
%
% �p�����g���b�N���f�����O
% arburg     - Burg �@���g����AR���f���p�����[�^�̐���
% arcov      - �����U�@���g����AR���f���p�����[�^�̐���
% armcov     - �C�������U�@���g����AR���f���p�����[�^�̐���
% aryule     - Yule-Walker �@���g����AR���f���p�����[�^�̐���
% ident      - System Identification Toolbox �Q��
% invfreqs   - ���g���f�[�^����A������(�A�i���O)�t�B���^�̓���
% invfreqz   - ���g���f�[�^���痣�U����(�f�B�W�^��)�t�B���^�̓���
% prony      - ���ԗ̈�IIR�t�B���^�݌v�̂��߂� Prony �@
% stmcb      - Steiglitz-McBride �����@���g�������`���f��
%
% ���`�V�X�e���ϊ�
% ac2rc      - ���ȑ��֗�𔽎ˌW���ɕϊ�
% ac2poly    - ���ȑ��֗��\���������ɕϊ�
% is2rc      - �t�T�C���p�����[�^�𔽎ˌW���ɕϊ�
% lar2rc     - �ʐς�ΐ���ŕ\�������̂𔽎ˌW���ɕϊ�
% levinson   - Levinson-Durbin �A�[�@
% lpc        - ���ȑ��֖@���g�������`�\���W���̎Z�o
% lsf2poly   - ���X�y�N�g���̎��g����\���������ɕϊ�
% poly2ac    - �\�������������ȑ��֗�ɕϊ�
% poly2lsf   - �\������������X�y�N�g���̎��g���ɕϊ�
% poly2rc    - �\���������𔽎ˌW���ɕϊ�
% rc2ac      - ���ˌW�������ȑ��֗�ɕϊ�
% rc2is      - ���ˌW�����t�T�C���p�����[�^�ɕϊ�
% rc2lar     - ���ˌW����ʐς�ΐ���ŕ\�������̂ɕϊ�
% rc2poly    - ���ˌW����\���������ɕϊ�
% rlevinson  - �tReverse Levinson-Durbin �A�[�@
% schurrc    - Schur �A���S���Y��
%
% �}���`���[�g�M������
% decimate   - �Ԉ����ɂ��T���v�����O�Ԋu���L����
% downsample - ���͐M���̃_�E���T���v�����O
% interp     - ���T���v�����O(���})
% interp1    - 1�����f�[�^�̕��(MATLAB Toolbox)
% resample   - �C�ӂ̃t�@�N�^�ɂ��T���v�����O���[�g�̕ύX
% spline     - �L���[�r�b�N�X�v���C�����
% upfirdn    - FIR�t�B���^�̓K�p�ƃT���v�����O���[�g�̕ϊ�
% upsample   - ���͐M���̃A�b�v�T���v�����O
%
% �g�`�̐���
% chirp      - ���ԂƋ��ɕω�������g�������R�T�C���g������
% diric      - Dirichlet �֐��܂��͎����I�� sinc �֐�
% gauspuls   - Gaussian �ϒ������g�p���X������
% gmonopuls  - Gaussian ���m�p���X������
% pulstran   - Pulse �񔭐���
% rectpuls   - �T���v�����O���ꂽ�������������Ȃ���`�p���X������
% sawtooth   - �m�R�M���g 
% sinc       - Sinc �g�A�܂��́Asin(��*x)/(��*x) �֐��̔�����
% square     - ��`�g������
% tripuls    - �T���v�����O���ꂽ�������������Ȃ��O�p�g������
% vco        - �d������U��������
%
% ����ȉ��Z
% buffer     - �M���x�N�g�����f�[�^�t���[���s��Ƀo�b�t�@�����O
% cell2sos    - �Z���z���2���^�̍s��ɕϊ�
% cplxpair   - ���f���𕡑f�����̑g�ɕ��ёւ�
% decimate   - ���T���v�����O(�Ԉ���)
% demod      - �ʐM�V�~�����[�V�����̂��߂̕���
% dpss       - ���U�G����]�ȉ~�̌^
% dpssclear  - ���U�G����]�ȉ~�̌^���f�[�^�x�[�X����폜
% dpssdir    - ���U�G����]�ȉ~�̌^�f�[�^�x�[�X�f�B���N�g��
% dpssload   - ���U�G����]�ȉ~�̌^���f�[�^�x�[�X���烍�[�h
% dpsssave   - ���U�G����]�ȉ~�̌^���f�[�^�x�[�X�ւ̕ۑ� 
% eqtflength - ���U���ԓ`�B�֐��̒����𓙂�������
% modulate   - �ʐM�V�~�����[�V�����̂��߂̕ϒ�
% seqperiod  - �x�N�g�����̔�����̍ŏ�������T��
% sos2cell   - 2���^�̍s����Z���z��ɕϊ�
% specgram   - ���ԂɈˑ��������g�����(�X�y�N�g���O����)
% stem       - ���U�f�[�^��̃v���b�g
% strips     - Strip �v���b�g
% udecode    - ���͂̈�l������
% uencode    - ���͂� N �r�b�g�ň�l�ʎq���ƕ�����
%
% �O���t�B�J�����[�U�C���^�t�F�[�X
% fdatool     - �t�B���^�݌v��̓c�[��
% sptool      - �M�������c�[��
% wintool     - �E�B���h�E�̐݌v�Ɖ�̓c�[��
%
% �Q�l�FSIGDEMOS, AUDIO, FILTERDESIGN(Filter Design Toolbox).



% Generated from Contents.m_template revision 1.9
% Copyright 1988-2004 The MathWorks, Inc. 
