!====================================================================   
!     >> mex load_spe_df.f    
!     This is a MEX-file for MATLAB   
!     to load an ASCII spe file produced by homer/2d on ISIS alpha VMS cluster
!     07-Oct-2000 compiled for PC/WINNT using Matlab 5.3 and
!     Digital Visual Fortran Professional Edition 6
!    
!    $Revisison: $  ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
!  
!====================================================================	
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  implicit NONE
! declares the pointer and integer sizes for current os and platform
#include "fintrf.h"
  character*(40) :: PROG_NAME= 'Fortran SPE in mslice (load_spe_df.F90) '
  character*(70) :: PROG_REV = '$Rev:: 345  $ ($Date:: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)'
  character*(110):: REVISION

  
  mwpointer :: plhs(*), prhs(*)
  integer*4 :: nrhs, nlhs
  
  ! declare pointers to output variables  
  mwpointer:: data_S_pr, data_ERR_pr, data_en_pr,mfp
  mwpointer:: mxGetPr,mxCreateCharMatrixFromStrings
  ! declare external calling functions
  mwsize :: mxCreateDoubleMatrix, mxGetM, mxGetN,mxIsChar,mxGetString
  integer mxCreateFull

  ! declare local operating variables of the interface funnction
  mwsize  :: ndet, ne
  integer*4 complexFlag

  ndet=10
  ne= 20
  complexFlag=0;
  !     Create matrices for the return arguments, double precision real*8
   plhs(1)=mxCreateDoubleMatrix(ndet,ne,complexFlag)

!  call mexErrMsgTxt('Almost there.')

  return
end subroutine mexFunction

