!===============================================================================
!     >> mex spe2proj_df.f
!     This is a MEX-file for MATLAB.   
!     returns projections v1(ndet,ne),v2(ndet,ne),v3(ndet,ne) of pixels
!     onto the 4-dimensional (reciprocal space 3-axes, energy) axes U1,U2,U3 
!     24-Oct-2000 version for Digital Visual Fortran 6
!     use passing pointers in Fortran through the %VAL construct
!===============================================================================
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  implicit NONE
! declares the pointer and integer sizes for current os and platform
#include "fintrf.h"
  character*(40) :: PROG_NAME= 'Fortran spe2proj (spe2proh_df.F90)      '
  character*(70) :: PROG_REV = '$Rev::      $ ($Date::                                              $)'
  character*(110):: REVISION
  
  mwpointer :: plhs(*), prhs(*)
  integer*4 :: nrhs, nlhs 
  ! declare local variables to deal with pointers to variables passed by/to MATLAB
  mwpointer:: emode_pr, efixed_pr, en_pr, det_theta_pr, det_psi_pr,psi_samp_pr
  mwpointer:: U1_pr, U2_pr, U3_pr,v1_pr, v2_pr, v3_pr 
  ! declare calling functions
  mwpointer:: mxGetPr,mxCreateCharMatrixFromStrings,mxCreateDoubleMatrix
  mwsize ::  mxGetM, mxGetN, mxIsNumeric  
#ifdef  OBSOLETE
  integer mxCreateFull
#endif  
  ! declare local operating variables of the interface funnction
  mwsize :: ndet, ne,longOne
  real*8 emode
  !      real*8 efixed, psi_samp 
     ! Returns code SVN version
  if(nrhs==0 .AND. nlhs==1)then
       REVISION =  PROG_NAME//PROG_REV
       plhs(1) = mxCreateCharMatrixFromStrings(1,REVISION)
       return
  end if
  
  !     Check for proper number of MATLAB input and output arguments
  if (nrhs .ne. 9) then
     call mexErrMsgTxt ('Nine inputs (emode, efixed, en, det_theta, det_psi, psi_samp,U1, U2, U3) required.')
  elseif (nlhs .ne. 3) then
     call mexErrMsgTxt('Three outputs (v1,v2,v3)required.')
  end if

  !     Check to see if all inputs are numeric
  if         (mxIsNumeric(prhs(1)) .ne. 1) then
     call mexErrMsgTxt('Input #1 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(2)) .ne. 1) then
     call mexErrMsgTxt('Input #2 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(3)) .ne. 1) then
     call mexErrMsgTxt('Input #3 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(4)) .ne. 1) then
     call mexErrMsgTxt('Input #4 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(5)) .ne. 1) then
     call mexErrMsgTxt('Input #5 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(6)) .ne. 1) then
     call mexErrMsgTxt('Input #6 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(7)) .ne. 1) then
     call mexErrMsgTxt('Input #7 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(8)) .ne. 1) then
     call mexErrMsgTxt('Input #8 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(9)) .ne. 1) then
     call mexErrMsgTxt('Input #9 is not a numeric array.')
  end if

  !     Check sizes of input arguments
  ne  =mxGetN(prhs(3))*mxGetM(prhs(3))  ! number of energy bins
  ndet=mxGetN(prhs(4))*mxGetM(prhs(4))  ! number of detectors
  if     ((mxGetN(prhs(1))*mxGetM(prhs(1))) .ne. 1) then
     call mexErrMsgTxt('Input #1(emode) should be a scalar.')
  elseif ((mxGetN(prhs(2))*mxGetM(prhs(2))) .ne. 1) then
     call mexErrMsgTxt('Input #2(efixed) should be a scalar.')
  elseif ((mxGetN(prhs(5))*mxGetM(prhs(5))) .ne. ndet) then
     call mexErrMsgTxt('Size of #5(det_psi) does not mach that of #4(det_theta)')
  elseif ((mxGetN(prhs(6))*mxGetM(prhs(6))) .ne. 1) then
     call mexErrMsgTxt('Input #6(psi_samp) should be a scalar.')
  elseif ((mxGetN(prhs(7))*mxGetM(prhs(7))) .ne. 4) then
     call mexErrMsgTxt('Input #7(U1) should be a 4-element vector')
  elseif ((mxGetN(prhs(8))*mxGetM(prhs(8))) .ne. 4) then
     call mexErrMsgTxt('Input #8(U2) should be a 4-element vector')
  elseif ((mxGetN(prhs(9))*mxGetM(prhs(9))) .ne. 4) then
     call mexErrMsgTxt('Input #9(U3) should be a 4-element vector')
  end if

  !     Check sizes of input arguments
  ne  =mxGetN(prhs(3))*mxGetM(prhs(3))  ! number of energy bins
  ndet=mxGetN(prhs(4))*mxGetM(prhs(4))  ! number of detectors 

  !     Get pointers to input parameters
  emode_pr    = mxGetPr(prhs(1))
  efixed_pr   = mxGetPr(prhs(2))
  en_pr       = mxGetPr(prhs(3)) 
  det_theta_pr= mxGetPr(prhs(4))
  det_psi_pr  = mxGetPr(prhs(5))
  psi_samp_pr = mxGetPr(prhs(6))
  U1_pr       = mxGetPr(prhs(7))
  U2_pr       = mxGetPr(prhs(8))
  U3_pr       = mxGetPr(prhs(9))

  ! the following calls are not needed as the pointers are sent directly
   !      call mxCopyPtrToReal8(efixed_pr,efixed,1)
  !      call mxCopyPtrToReal8(psi_samp_pr,psi_samp,1)

! this one is somehow still required
		longOne = 1;
        call mxCopyPtrToReal8(emode_pr,emode,longOne)
  !     Create matrices for the return arguments 
#ifdef OBSOLETE
      plhs(1)=mxCreateFull(ndet,ne,0)
      plhs(2)=mxCreateFull(ndet,ne,0)
      plhs(3)=mxCreateFull(longOne,ne,0)            
#else
      plhs(1)   =mxCreateDoubleMatrix(ndet,ne,0) ! these are matlab pointsrs  
      plhs(2)   =mxCreateDoubleMatrix(ndet,ne,0)
      plhs(3)   =mxCreateDoubleMatrix(ndet,ne,0)
      call mexWarnMsgTxt("matrices created")			  
#endif  
    v1_pr     = mxGetPr(plhs(1)) ! these are fortran pointers of the matlab mxArrays created above
    v2_pr     = mxGetPr(plhs(2)) 
    v3_pr     = mxGetPr(plhs(3))

  !     Call the computational subroutine spe2proj_df
  call mexWarnMsgTxt("entering spe2proj_df")		
  call spe2proj_df(emode,%val(efixed_pr),%val(en_pr),ne,%val(det_theta_pr),%val(det_psi_pr),ndet,%val(psi_samp_pr),%val(U1_pr),&
       %val(U2_pr),%val(U3_pr),%val(v1_pr),%val(v2_pr),%val(v3_pr))
  return
end subroutine mexFunction
!
! ===============================================================================
! actual FORTRAN code for the spe2proj_df algorithm
! =============================================================================== 
subroutine spe2proj_df(emode,efixed,en,ne,det_theta,det_psi,ndet,psi_samp,U1,U2,U3,v1,v2,v3)
  ! declare input and output variables
  implicit NONE

  real*8 emode
  mwsize :: ndet, ne 
  real*8 efixed, en(*), det_theta(*), det_psi(*), psi_samp, U1(*), U2(*), U3(*), v1(*), v2(*), v3(*) 

  ! declare local variables   
  integer i, j, k
  real*8 ki, kf, kx, ky, kz, Qx, Qy, Qz, cos_psi, sin_psi

  ! store these numbers for faster calculations
  cos_psi=cos(psi_samp) 
  sin_psi=sin(psi_samp)    
  ki=sqrt(efixed/2.07d0)
  kf=sqrt(efixed/2.07d0)
  emode=1
  do i=1,ndet
     do j=1,ne
        k=i+ndet*(j-1)      ! global index in the (ndet,ne) matrix
        !  choose between direct/indirect geometry configurations
        if (emode.eq.1) then   
           ! For direct-geometry spectrometers like HET, MARI
           ! efixed = monochromatic incident energy ei(meV) 
           kf=sqrt((efixed-en(j))/2.07d0)
        elseif (emode .eq.2) then
           ! For indirect-geometry spectrometers like IRIS
           ! efixed = monochromatic scattered energy (meV) for a white incident beam  
           ! here all detectors are in the horizontal plane with Psi=0
           ! scattering geometry diagram in notebook computing 2, page 2-14
           ki=sqrt((efixed+en(j))/2.07d0)
        else ! error
           ndet=0
           return
        end if
        ! (kx,ky,kz) in spectrometer reference frame
        kx=ki-cos(det_theta(i))*kf
        ky=  -sin(det_theta(i))*cos(det_psi(i))*kf
        kz=  -sin(det_theta(i))*sin(det_psi(i))*kf
        ! (kx,ky,kz) in rotated reference frame
        Qx= cos_psi*kx+sin_psi*ky
        Qy=-sin_psi*kx+cos_psi*ky
        Qz= kz
        ! (v1,v2,v3) projected onto reciprocal space directions
        v1(k)=U1(1)*Qx+U1(2)*Qy+U1(3)*Qz+U1(4)*en(j)
        v2(k)=U2(1)*Qx+U2(2)*Qy+U2(3)*Qz+U2(4)*en(j)
        v3(k)=U3(1)*Qx+U3(2)*Qy+U3(3)*Qz+U3(4)*en(j)
     end do
  end do
  return
end subroutine spe2proj_df
