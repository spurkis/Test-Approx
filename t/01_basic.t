use strict;
use warnings;

use lib 'lib';

use Test::More tests => 7;
use Test::Builder::Tester;


use_ok( 'Test::Approx' );

is_approx( 'abcd', 'abcd', 'equal strings' );
is_approx( 1234, 1234, 'equal numbers' );

test_out('not ok 1 - diff strings');
test_fail(+1);
is_approx( 'abcdefg', 'gfedcba', 'diff strings' );
test_diag( "  test: 'abcde...' approximately equal to 'gfedc...'" );
test_diag( "  error: edit distance (6) was greater than threshold (1)");
test_test('completely different strings');

{
    my ($str1, $str2) = ('abcdefghijklmnopqrstuvwxyz', 'abcdef ijklmmopqrstuvwxyz');
    is_approx( $str1, $str2, 'similar strings, 20% threshold', '20%' );

    test_out('not ok 1 - similar strings, 10% threshold');
    test_fail(+1);
    is_approx( $str1, $str2, 'similar strings, 10% threshold', '10%' );
    test_diag( "  test: 'abcde...' approximately equal to 'abcde...'" );
    test_diag( "  error: edit distance (3) was greater than threshold (2)");
    test_test('similar strings, 10% threshold');
}

{
    # try a big string... that's what this module is for
    my $str1 = '_gkxEv}|vNyB{CwA}@kKg@sAsBcB_@w@q@}AsCMwCr@yEl@gdA_MaBqJ[yBk@aPm[oBqAgAKu@aAOuANa@lA]Fi@q@mAFsC{@kEgBnFUdEiGbL]H\\mGtCaI?uAlAsHlAsDjH_D|EmA~@VvJwCTeAdD_CuArHBpBmAl@IfAVn@lCh@p@KdHqJnChJ?hB\\ZdC?lCp@hBFjFkDe@KMk@L}BlGFK}AsB~B_AJwCzCk@BsAnB_AJ_F`DmDaFM_JsBeAfAgAGoCxJjIv@HjHoBn@e@p@wCxA^dAUfCeDjG}DYaAkIcFcC{@QuCdCcEJyI[iKwAUyEoOoSC{Cd@cApHkCyDuSkAaPbAeLnFkGrB{DdDsBL_A{@kC]}EsBp@yB@gIqA}FAw@c@E{CvAiEcEgLs@i@kDtAg@c@q@eQuCyJ{@k@mCCm@w@wCuNm@_@eIWoBiA}A{D]wC_BwE_AgS]{@kFuCcABkBnB}AhIoDjDcCxAoAJ{JyCoDNoAa@cD{HiG_FaCBuElAq@kHZqPUwC_A_CiMlD{BFeC}@{@{@wA{DuFRyB]iCkDsBsAyBh@mEtC}BTcC_@uJiOe@aKk@cAsBgA{DWqB{@_DoDyFuLcHaDaBwBsEoPCwAlAaCr@e@lGwBn@cCQwC_EcNUqCTmC~CwKnAwBnBuAjSaFbFmHzFwD~CyEnH]tDqAnEkHhHwGD}Cm@cDyAcC}FaCcCuIoBmAyFv@mK~G_Cx@yJ`AsBe@yHyJwKcDmCcC]cAr@aEFyCbBaJq@mCaB_B{DF}Hw@aBxAi@lCiAtB_AL}HuCgG{@sBqA{CqF_@{Cf@cDvEqI|@oHgAaCwHmCe@_AVaISyCqDiI_GwEYyCvBgHCeFXaAvBqAdIg@hBaAlAwBn@oIq@sF{DyEkCu@qE[a@o@UyCn@sHQaAy@m@eAMuJhCwBA_CeEaEaA}OsJ_CwC_AeCGgAr@cFUyCyFsF_EeAsKhA{DEiTmEcBeBuE{M_H_L?cDlAkHY}CuAmEGyCfHqQl@yYv@mCr@q@hCg@hPdC`C?jNmE~Ld@xFs@zGsCtJkGnAkBOkC}AyAeDmAeLiBgKuJyBzB}@HiR_@sQsFgByAoAcHmAoBuWBkBy@b@ZoAoA}@eCe@gC]gK}BwF_L}HuGuH}LoJ}CeGkEgO_CsDkDoBiIaAgBmAsDwEiF{BgEuD{JcE]cA?kFg@_DaAgCoCyD}FuDqIoCuDsBwJ}AuFwDaBe@{DMsFhAw@Y{@kAg@oKsFeNgAeJkBsCuPeEaG_CkH_F{IiIeCe@wFCqA}AsAsGaByAcEQgYzG{@KqA}Bw@oI{BmMd@{@xA}AbFuClIiIfFmLrK{DzFwEbF{BfByAdHyJbBmGvAeBrBO~Db@xBc@`A}BtAeHhCgGz@mLlCoHhDaErIqDxCeE`@_DUgCuFoIm@yCDuAvDsI`BaHbDqFdBqGv@_@|Fp@xAoB?uAkD_Nw@uF|DiV`BgB~BgAxHeBn@eAh@}CKkDuDcFWoAm@_KHkHhAsC`ByBrIeGvDiG~faC~LsHJoAwIt@cHKu@d@kA`CcBdBgRnIyGbGwBt@{KEm@e@U{CdByNw@uEaBsAoFVkF{@{@T}DnDiKrDuJ`@{@e@a@{@]{Cc@w@eHyAoFgF{@WyMJkJ{@wD_AuH|@oHEsFgO_B{AcF}BgC\\oFfC{@Bs@a@sHwM_F}CaKY{KhEaGrDC_ApBsAtB_ETkCc@{@cE_sDkHsDmEwE{BoDY{DoHTevBHxAxAm@f@y@E';
    my $str2 = '_gkxEv{|vNyB{CwA}@Khg@sAsBcB_@w@q@}sCMwCr@yEl@gdA_MaBqJ[yBk@aPm[oBqAgAKu@aAOuANa@lA]Fi@q@mAFsC{@kEgBnFUdEiGbL]H\\mGtCaI?uAlAsHlAsDjH_D|EmA~@VvJwCTeAdD_CuArHBpBmAl@IfAVn@lChp@KdHqJnChJ?hB\\ZdC?lCp@hBFjFkDe@KMk@L}BlGuFK}AsB~B_AJwCzCk@BsAnB_AJ_F`DmDaFM_JsBeAfAgAGoCxJjv@HjHoBn@e@p@wCxA^dAUfCeDjG}DYaAkIcJaFcC{@QuCdCcEJyI[iKwAUyEoOoSC{Cd@cApHkCyDuSkAaPbAeLnFkGrDdDsBL_A{@kC]}EsBp@yB@gIqA}FAw@c@E{CvAiEcEgLs@i@kDtAg@c@q@eQuCyJ{@k@mCCm@w@wCuNm@_@eIWoBiA}A{D]wC_BwE_AgS]{@kFuCcABkBnB}AhIoDjDcCxAoAJ{JyCoDNfoAa@cD{HiG_FaCBatsuElkHZqPUwC_A_CiMlD{BFeC}@{@{@wA{DuFRyB]iCkDsBsAyBh@mEtC}BTcC_@uJiOe@aKk@cAsBgA{DWqB{@_DoDyFuLcHaDaBwBsEoPCwAlAaCr@e@lGwBn@cCQwC_EcNUqCTmC~CwKnAwBnBuAjSaFbFmHzFwD~CyEnH]tDqAnEkHhHwGD}Cm@cDyAcC}FaCcCuIoBmAyFv@mK~G_Cx@yJ`AsBe@yHyJwKcDmCcC]cAr@aEFyCbBaJq@mCaB_B{DF}Hw@aBxAi@L}HugG{@sBqA{CqF_@{Cf@cDvEqI|@oHgAaCwHmCe@_AVaISyCqDiI_GwEYyCvBgHCeFXaAvBqAdIg@hBaAlAwBn@oIq@sF{DyEkCu@qE[a@o@UyCn@sHQaAy@m@eAMuJhCwBA_CeEaEaA}OsJ_CwC_AeCGgAr@cFUyCyFsF_EeAsKhA{DEiTmEcBeBuE{M_H_L?cDlAkHY}CuAmEGyCfHqQl@yYv@mCr@q@hCg@hPdC`C?jNmE~Ld@xFs@zGsCtJkGnAkBOkC}AyAeDmAeLiBgKuJyBzB}@HiR_@sQsFgByAoAcHmAoBuWBkBy@b@ZoAoA}@eCe@gC]gK}BwF_L}HuGuH}LoJ}CeGkEgO_CsDkDoBiIaAgBmAsDwEiF{BgEuD{JcE]cA?kFg@_DaAgCoCyD}FuDqIoCuDsBwJ}AuFwDaBe@{DMssFhAw@Y{@kAg@oKsFeNgeJkBsCuPeEaG_CkH_F{IiIeCe@wFCqA}AsAsGaByAcEQgYzG{@KqAw@oI{BmMd@{@xA}AlFuClIiIflFmLrK{DzFwEbF{BfByAdHyJbmGvAeBrBO~Db@xBc@`A}BtAeHhCgGz@mLlCoHhDaErIqDxCeE`@_DUgCuFoIm@yCDuAvDsI`BaHbDqFdjqGv@_@|Fp@xAoB?uAkD_Nw@uFjDiV`BgB~BgAxHeBn@eAd@}CKkDuDcFWoAm@_KHkHhAsC`ByBrIeGvDiG~jaC~LsHJoAwIt@cHKu@d@kA`CcBdBgRnIyGbGwBt@sdfhgEm@e@U{CdByNw@uEaBsAoFVkFsd{@{@T}DnDiKrDuJ`@{@e@a@{@]{Cc@w@eHyAoF{@WyMJkasdf{@wD_AuH|@oHEsFgO_B{AcF}BgC\\oFfC{@Bs@a@sHwM_F}CaKY{KhEaGrDC_ApBsAasdf_ETkCc@{@cE_DsDkHsDmEwE{BoDY{DoHTeAvBHxAxAm@f@y@E';
    is_approx( $str1, $str2, 'big strings, default threshold' );
}
