% Mu-Analysis and Synthesis Toolbox
% Version 3.0.8 (R14) 05-May-2004
%
% ?V�@�\
% Readme  - Mu-analysis and Synthesis Toolbox�Ɋւ���?d�v�ȃ���?[�X?��
%           (Readme���_�u���N���b�N���邩?A"whatsnew directoryname"�ƃ^
%           �C�v���Ă�������?B���Ƃ���?A"whatsnew mutools/commands"�ƃ^
%           �C�v�����?A���̃t�@�C����\�����܂�?B)
%
% �W?����Z/��{��?�
%
% abv       - constant/varying/system?s���?ォ��?��Ɍ�?�
% cjt       - varying/system?s��̋���]�u
% daug      - constant/varying/system?s���Ίp�Ɋg��
% madd      - constant/varying/system?s��̉��Z
% minv      - constant/varying/system?s��̋t?s��
% mmult     - constant/varying/system?s���?�Z
% mscl      - SYSTEM�܂���VARYING?s����X�J���{
% msub      - constant/varying/system?s��̌��Z
% sbs       - ?s�����ׂ�
% sclin     - �V�X�e���̓��͂��X�P?[�����O
% sclout    - �V�X�e����?o�͂��X�P?[�����O
% sel       - ?s/��܂���?o��/���͂�I��
% starp     - Redheffer�X�^?[?�
% transp    - varying/system?s��̓]�u
%
% ?s���?��̕\��?A�v�?�b�g
%
% drawmag   - �Θb�^�̃}�E�X���g�����`��Ƌߎ��̃c?[��
% minfo     - ?s���?���?o��
% mprintf   - ?s���?����t���\��
% rifd      - ��?���?A��?���?A���g?�?A��?����̕\��
% see       - varying/system?s��̕\��
% seeiv     - varying?s��̓Ɨ���?��̕\��
% seesys    - varying/system?s���?����t���̕\��
% vplot     - varying?s��̃v�?�b�g
% vzoom     - �v�?�b�g�E�B���h�E�Ń}�E�X���g���Ď���I��
% wsgui     - �O���t�B�J���ȃ??[�N�X�y?[�X��?�c?[��
%
% ���f�����O�@�\
%
% fitsys    - ���g?������f?[�^��`�B��?��ŋߎ�
% nd2sys    - SISO�`�B��?���SYSTEM?s��ɕϊ�
% pck       - ?�ԋ�ԃf?[�^(A, B, C, D)����system?s���?�?�
% pss2sys   - [A B;C D]?s���mu-tools��system?s��ɕϊ�
% sys2pss   - SYSTEM?s�񂩂�?�ԋ��?s��[A B; C D]��?o
% sysic     - SYSTEM?s��̑��݌�?�?�?��v�?�O����
% unpck     - SYSTEM?s�񂩂�?�ԋ�ԃf?[�^(A,B,C,D)��?o
% zp2sys    - �`�B��?��̋ɂƗ�_��SYSTEM?s��ɕϊ�
%
% System?s���?�
%
% reordsys  - SYSTEM?s���?�Ԃ̕��בւ�
% samhld    - �A�����ԃV�X�e���̃T���v���z?[���h�ߎ�
% spoles    - SYSTEM?s��̋�
% statecc   - SYSTEM?s���?��W�ϊ���K�p
% strans    - SYSTEM?s��̑o�Ίp?��W�ϊ�
% sysrand   - �����_����SYSTEM?s���?�?�
% szeros    - SYSTEM?s��̓`�B��_
% tustin    - Prewarped Tustin�ϊ����g���ĘA��SYSTEM?s��𗣎USYSTEM?s��
%             �ɕϊ�
%
% ���f���̒᎟����
%
% hankmr    - SYSTEM?s���?œKHankel�m�����ߎ�
% sdecomp   - SYSTEM?s���2��SYSTEM?s��ɕ���
% sfrwtbal  - SYSTEM?s��̎��g?�?d�ݕt����?t������
% sfrwtbld  - SYSTEM?s��̈���Ȏ��g?�?d�ݕt������
% sncfbal   - SYSTEM?s��̊��񕪉��̕�?t������
% srelbal   - SYSTEM?s��̊m���I��?t������
% sresid    - SYSTEM?s���?�ԗʂ����?���
% strunc    - SYSTEM?s���?�Ԃ�?�?�
% sysbal    - SYSTEM?s��̕�?t������
%
% �V�X�e������
%
% cos_tr    - �]��?M?���VARYING?s��Ƃ���?�?�
% dtrsp     - ?��`�V�X�e���̗��U���ԉ���
% frsp      - SYSTEM?s��̎��g?�����
% sin_tr    - ?���?M?���VARYING?s��Ƃ���?�?�
% sdtrsp    - ?��`�V�X�e���̃T���v���l���ԉ���
% siggen    - ?M?���VARYING?s��Ƃ���?�?�
% simgui    - �O���t�B�J����?��`�V�X�e���V�~����?[�V�����c?[��
% step_tr   - �X�e�b�v?M?���VARYING?s��Ƃ���?�?�
% trsp      - ?��`�V�X�e���̎��ԉ���
%
% H_2?AH_?���?�?A�V���Z�V�X
%
% dhfsyn    - ���U����H?�?���?݌v
% dhfnorm   - �����SYSTEM?s��̗��U����?��m�����̌v�Z
% emargin   - �M���b�v�v�ʃ?�o�X�g����?�
% gap       - 2��SYSTEM?s��Ԃ̃M���b�v�v�ʂ̌v�Z
% h2norm    - �����?A�����Ƀv�?�p��SYSTEM?s���2�m�������v�Z
% h2syn     - H_2?���?݌v
% hinffi    - H?��S?��?��䑥
% hinfnorm  - ����Ńv�?�p��SYSTEM?s���H?��m�������v�Z
% hinfsyn   - H?�?���?݌v
% hinfsyne  - H?�?�?��G���g�?�s?[?���?݌v
% linfnorm  - �v�?�p��SYSTEM?s���L?��m�������v�Z
% ncfsyn    - H?���?[�v?��`?���?݌v
% nugap     - SYSTEM?s��Ԃ�nu�M���b�v�v�ʂ̌v�Z
% pkvnorm   - VARYING?s��̃s?[�N(�Ɨ���?��Ɋւ���)�m����
% sdhfsyn   - �T���v���lH?�(�U��L_2�m����)?���?݌v
% sdhfnorm  - �����SYSTEM?s��̃T���v���lH?��m����(�U��L_2�m����)
%
% ?\�������ْl(mu)��?͂ƃV���Z�V�X
%
% blknorm   - constant/varying?s��̃u�?�b�N���̃m����
% cmmusyn   - Constant?s���mu�V���Z�V�X
% dkit      - ���������ꂽD-K�C�^��?[�V����
% dkitgui   - �O���t�B�J����DK�C�^��?[�V�����c?[��
% dypert    - ���g?���mu�f?[�^����L�??ۓ���?�?�
% fitmag    - �Q�C���f?[�^�����L�?�`�B��?��ߎ�
% fitmaglp  - �Q�C���f?[�^�����L�?�`�B��?��ߎ�
% genmu     - ��ʉ�mu��?�E�̌v�Z
% genphase  - �Q�C���f?[�^��?�?��ʑ����g?�������?�?�
% magfit    - �Q�C���f?[�^�����L�?�`�B��?��ߎ�
% msf       - DK�C�^��?[�V�����p��D�X�P?[���ߎ�
% msfbatch  - msf�̃o�b�`�o?[�W����
% mu        - constant/varying?s���mu��?�
% muftbtch  - �o�b�`�`����D�X�P?[���ߎ���?[�`��(?����̓T�|?[�g��?s��Ȃ�
%             �̂�?Amsfbatch���g���Ă�������)
% musynfit  - �Θb�I��D�X�P?[���L�?�ߎ�(?����̓T�|?[�g��?s��Ȃ��̂�?A
%             msf���g���Ă�������)
% musynflp  - �Θb�I��D�X�P?[���L�?�ߎ�(?����̓T�|?[�g��?s��Ȃ��̂�?A
%             msf���g���Ă�������)
% muunwrap  - mu�v�Z����f?[�^��?o
% randel    - �����_����?ۓ���?�?�
% sisorat   - 1���S�ʉߓ��}
% unwrapd   - mu����D�X�P?[�����O?s���?�?�
% unwrapp   - mu����Delta?ۓ���?�?�
% wcperf    - ?ň��P?[�X��?��\��?���?ۓ�
%
% VARYING?s��̎�舵��
%
% getiv     - VARYING?s��̓Ɨ���?���?o��
% indvcmp   - 2��?s��̓Ɨ���?��f?[�^�̔�r
% massign   - ?s��̗v�f�̊��蓖��
% scliv     - �Ɨ���?��̃X�P?[�����O
% sortiv    - �Ɨ���?��̕��בւ�
% tackon    - VARYING?s��̌�?�
% var2con   - VARYING?s���CONSTANT?s��ɕϊ�
% varyrand  - �����_����VARYING?s���?�?�
% vpck      - VARYING?s��̈�?k
% vunpck    - VARYING?s��̕���
% xtract    - VARYING?s��̕����I��?o
% xtracti   - VARYING?s��̕����I��?o
%
% Varying?s��Ɋւ���W?�MATLAB�R�}���h
%
% vabs      - constant/varying?s���?�Βl
% vceil     - constant/varying?s��̗v�f��?������ւ̊ۂ�
% vdet      - constant/varying?s���?s��
% vdiag     - constant/varying?s��̑Ίp�v�f
% veig      - constant/varying?s��̌ŗL�l����
% vexpm     - constant/varying?s��̎w?�
% vfft      - VARYING?s���FFT
% vfloor    - constant/varying?s��̗v�f��-?������ւ̊ۂ�
% vifft     - VARYING?s��̋tFFT
% vinv      - constant/varying?s��̋t?s��
% vimag     - constant/varying?s��̋�?���
% vnorm     - varying/constant?s��̃m����
% vpoly     - constant/varying?s��̓�?���?���
% vpinv     - constant/varying?s��̋[���t?s��
% vrank     - constant/varying?s��̃����N
% vrcond    - constant/varying?s���?��??�
% vreal     - constant/varying?s��̎�?���
% vroots    - constant/varying?s��̑�?�����?�
% vschur    - constant/varying?s���Schur����
% vspect    - VARYING?s��ɑ΂���Signal Processing�̃X�y�N�g����?�
%             �R�}���h
% vsqrtm    - constant/varying?s��̕���?�
% vsvd      - constant/varying?s��̓��ْl����
%
% Varying?s��Ɋւ���t���I�ȋ@�\
%
% vcjt      - constant/varying?s��̋���]�u
% vcond     - constant/varying?s���?��??�
% vconj     - constant/varying?s��̕��f����
% vdcmate   - VARYING?s��̊Ԉ���
% vebe      - VARYING?s��̗v�f�P�ʂ̉��Z
% veberec   - �v�f�P�ʂ̋t?�
% veval     - VARYING?s��̈�ʊ�?��̕]��
% vveval    - VARYING?s��̈�ʊ�?��̕]��
% mveval    - VARYING?s��̈�ʊ�?��̕]��
% vfind     - �Ɨ���?����?�߂�
% vinterp   - VARYING?s��̓��}
% vldiv     - constant/varying?s���?�?��Z
% vrdiv     - constant/varying?s��̉E?��Z
% vrho      - constant/varying?s��̃X�y�N�g�����a
% vtp       - constant/varying?s��̓]�u
% vtrace    - constant/varying?s��̑Ίp�̘a
%
% ��?[�e�B���e�B�Ƃ��̑��̊�?�
%
% add_disk  - �i�C�L�X�g�v�?�b�g�ɒP�ʉ~��ǉ�
% cf2sys    - ?��K�����ꂽ���񕪉�����?s���?�?�
% clyap     - �A���nLyapunov������
% crand     - ��l���z���郉���_���ȕ��f?s���?�?�
% crandn    - ?��K���z���郉���_���ȕ��f?s���?�?�
% csord     - ?�?��t����ꂽ���fSchur?s��
% mfilter   - Butterworth, Bessel, RC�t�B���^��?�?�
% negangle  - ?s��v�f�̊p�x��0����-2 pi�̊ԂŌv�Z
% ric_eig   - �ŗL�l�������g����?ARiccati������������
% ric_schr  - Schur�������g����?ARiccati������������
% unum      - ���͂̎���
% xnum      - ?�Ԃ̎���
% ynum      - ?o�͂̎���
%

%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2004/03/10 21:22:23 $
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc. 
