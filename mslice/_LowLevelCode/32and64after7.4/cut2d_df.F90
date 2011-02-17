!===============================================================================
!     >> mex cut2d_df.f
!     This is a MEX-file for MATLAB.   
!     to take a 1D cut from a 2D data set of pixels with (vx,vy) coordinates 
!     take only pixels with coordinate vy_min<=vy<=vy_max 
!     and rebin data along vx axis [vx_min to vx_max] 
!     24-Oct-2000 version for Digital Visual Fortran 6
!     use passing pointers in Fortran through the %VAL construct
!    $Revision$ ($Date$)
!===============================================================================
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  implicit NONE
#include "fintrf.h"
   mwpointer :: plhs(*), prhs(*)
   integer*4 :: nrhs, nlhs
   character*(40) :: PROG_NAME= 'Fortran Cut2D    (cut2d_df.F90)        '
!123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
!         1         2         3         4         5         6         7         8         9         0
   character*(71) :: PROG_REV = '$Rev::      $ ($Date::                                              $)'C
   character*(111):: REVISION
   
  
  !     <temp> will be temporary mxArray in place of plhs(1),plhs(2),...
  !     temp1, temp2, temp3 will be fortran pointers to temporary arrays 
  ! declare local variables to deal with pointers to variables passed by/to MATLAB
  mwpointer:: vx_pr, vy_pr, pixel_int_pr 
  mwpointer:: pixel_err_pr, grid_pr,  temp1, temp2, temp3,temp
  mwpointer:: x_pr, intensity_pr, error_int_pr, perm_pr, number_pix_pr,temp_pr
  ! declare calling functions
  mwpointer:: mxGetPr,mxCalloc,mxCreateCharMatrixFromStrings,mxCreatedoublematrix; 
  mwsize   :: mxGetM, mxGetN, mxIsNumeric 
  ! declare local operating variables of the interface funnction
  mwsize :: n, m,final_npixel,one
  integer ndet, ne
  real*8 grid(5), vx_min, vx_max, bin_vx,vy_min, vy_max, vvy(1), eps

  ! Returns code SVN version
  if(nrhs==0 .AND. nlhs==1)then
    one = 1
  	REVISION =  PROG_NAME//PROG_REV
	plhs(1) = mxCreateCharMatrixFromStrings(one,REVISION)
    return
   end if
  
  
  !     Check for proper number of MATLAB input and output arguments 
  if (nrhs .ne. 5) then
     call mexErrMsgTxt ('Five inputs (vx,vy,pixel_int,pixel_err,grid) required.')
  elseif (nlhs .ne. 6) then
     call mexErrMsgTxt('Six outputs (x,intensity,err_int,perm,number_pix,vy) required.')
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
  end if

  !     Check sizes of input arguments
  ndet=mxGetM(prhs(1))
  ne  =mxGetN(prhs(1)) 
  if     ((mxGetM(prhs(2)).ne.ndet).or.(mxGetN(prhs(2)).ne.ne)) then
     call mexErrMsgTxt('Size of input #2 does not mach that of input #1')
  elseif ((mxGetM(prhs(3)).ne.ndet).or.(mxGetN(prhs(3)).ne.ne)) then
     call mexErrMsgTxt('Size of input #3 does not mach that of input #1')
  elseif ((mxGetM(prhs(4)).ne.ndet).or.(mxGetN(prhs(4)).ne.ne)) then
     call mexErrMsgTxt('Size of input #4 does not mach that of input #1')
  elseif ((mxGetN(prhs(5))*mxGetM(prhs(5))) .ne. 5) then
     call mexErrMsgTxt('Input #5 grid should have 5 elements.') 
  end if

  !     Get vx,vy,pixel_int,pixel_err and grid parameters
  vx_pr= mxGetPr(prhs(1))
  vy_pr= mxGetPr(prhs(2))
  pixel_int_pr= mxGetPr(prhs(3))
  pixel_err_pr= mxGetPr(prhs(4))
  grid_pr     = mxGetPr(prhs(5))
  call mxCopyPtrToReal8(grid_pr,grid,5)
  vx_min=grid(1)
  vx_max=grid(2)
  bin_vx=grid(3)
  vy_min=grid(4)
  vy_max=grid(5)
  eps=1.0d-5*(vx_max-vx_min) ! this will be a small number (0 for practical purposes) in units of vx-axis
  !     if bin_x=0 by convention do not bin data along vx axis, for each detector bin along the energy axis
  if (bin_vx .lt. eps) then  ! use binning along the energy axis for each detector 
     n=ndet ! all detectors can contribute
     ! keep vx_min and vx_max as they are
  else ! normal binnig along the vx axis
     n=int((vx_max+bin_vx-(vx_min-bin_vx/2.0d0))/bin_vx) ! total number of bins 
     ! redefine vx_min and vx_max to include -bin_vx/2 on the left and +(bin_vx/2 or bin_vx) on the right
     ! pass these numbers to the cut2d_df subroutine for faster comparisons of pixel inclusion criteria 
     vx_min=vx_min-bin_vx/2.0d0
     vx_max=vx_min+dfloat(n)*bin_vx
  end if

  !     Create matrices for the return arguments (operating workspace for the subroutine cut2d_df)
  plhs(1)	    =mxCreatedoublematrix(1,n,0)
  plhs(2)	    =mxCreatedoublematrix(1,n,0)
  plhs(3)       =mxCreatedoublematrix(1,n,0)
  plhs(4)       =mxCreatedoublematrix(ndet*ne,1,0)
  plhs(5)       =mxCreatedoublematrix(1,n,0)
  x_pr          =mxGetPr(plhs(1))
  intensity_pr  =mxGetPr(plhs(2))
  error_int_pr  =mxGetPr(plhs(3))
  perm_pr       =mxGetPr(plhs(4))
  number_pix_pr =mxGetPr(plhs(5))

  !     Allocate space for temporary arrays, temp1 are fortran pointers
  temp1=mxCalloc(ndet*ne,4) ! integer*4
  temp2=mxCalloc(ndet*ne,4) ! integer*4
  temp3=mxCalloc(ndet*ne,4) ! integer*4

  !     Call the computational subroutine cut2d_df
  call cut2d_df(%val(vx_pr),%val(vy_pr),%val(pixel_int_pr),%val(pixel_err_pr), ndet, ne, ndet*ne,&
       vx_min,vx_max,bin_vx,eps,n,vy_min, vy_max,%val(x_pr),%val(intensity_pr),%val(error_int_pr),&
       m,%val(perm_pr),%val(number_pix_pr),final_npixel,vvy(1),%val(temp1),%val(temp2),%val(temp3))

  !     Clear space for temporary arrays
  call mxFree(temp1)
  call mxFree(temp2) 
  call mxFree(temp3) 

  !     Reduce size of output arrays x,intensity,error_int,perm,number_pix to useful data only  
  ! deal with permutation matrix first
  temp=mxCreatedoublematrix(final_npixel,1,0)
  temp_pr= mxGetPr(temp)
  call reduce_output(m,n,%val(perm_pr),%val(temp_pr))
  call mxDestroyArray(plhs(4))
  plhs(4)=temp

  if (m .lt. n) then
     ! deal with x,intensity,error,number_pix now
     temp=mxCreatedoublematrix(1,m,0)
     temp_pr= mxgetpr(temp)
     call reduce_output(m,n,%val(x_pr),%val(temp_pr))
     call mxDestroyArray(plhs(1))
     plhs(1)=temp

     temp=mxCreatedoublematrix(1,m,0)
     temp_pr= mxgetpr(temp)
     call reduce_output(m,n,%val(intensity_pr),%val(temp_pr))
     call mxDestroyArray(plhs(2))
     plhs(2)=temp         

     temp=mxCreatedoublematrix(1,m,0)
     temp_pr= mxgetpr(temp)
     call reduce_output(m,n,%val(error_int_pr),%val(temp_pr))
     call mxDestroyArray(plhs(3))
     plhs(3)=temp 

     temp=mxCreatedoublematrix(1,m,0)
     temp_pr= mxgetpr(temp)
     call reduce_output(m,n,%val(number_pix_pr),%val(temp_pr))
     call mxDestroyArray(plhs(5))
     plhs(5)=temp 
  end if
  plhs(6)       =mxCreatedoublematrix(1,1,0)
  call mxCopyReal8ToPtr(vvy,mxGetPr(plhs(6)),1)


  return
end subroutine mexFunction
!
! ===============================================================================
! actual FORTRAN code for the cut2d_df algorithm
! distribute all data points into bins, then take average over each bin
! =============================================================================== 
subroutine cut2d_df(vx,vy,pixel_int,pixel_err,ndet,ne,Npixels,vx_min,vx_max,bin_vx,&
     eps,n,vy_min,vy_max,x,intensity,error_int,m,perm,number_pix,final_npixel,vvy,&
     pixel_index1,pixel_index2,pixel_index3)
  ! declare input and output variables
  implicit NONE
  !     m = number of bins with data, 
  !     n = total number of bins	
  mwsize :: m, n,final_npixel
  integer ndet, ne, Npixels, pixel_index1(*), pixel_index2(*), pixel_index3(*)
  integer bin_index(n), cumm_npixels(n)
  real*8 vx(*), vy(*), pixel_int(*), pixel_err(*),  vx_min, vx_max, bin_vx, eps, vy_min,&
       vy_max, x(*), intensity(*),error_int(*), perm(Npixels),number_pix(n), vvy
  ! declare local variables   
  integer i, k, j, l
  ! initialize to zero the number of pixel per bin,x,intensity,error_int 
  do i=1,n
     number_pix(i)=0.0d0
     x(i)         =0.0d0
     intensity(i) =0.0d0
     error_int(i) =0.0d0
  end do
  ! run through all pixels and if contributing then distribute then into bins
  vvy=0.0d0 ! will contain partial sum of vy values 
  final_npixel=0   ! will contain final number of pixels going into the cut
  ! choose between normal binning along the vx axis (bin_vx >0) and binning along the energy axis only (bin_vx=0) 
  if (bin_vx .gt. eps) then  ! normal binning along the vx-axis 
     do j=1,ndet
        do l=1,ne
           k=j+ndet*(l-1)   ! global index in the (ndet,ne) matrix 
           ! run energy index first, then detector index 
           if ((vx(k).ge.vx_min).and.(vx(k).lt.vx_max).and.(vy(k).ge.vy_min).and.(vy(k).le.vy_max).and. &
                (pixel_int(k) .gt. -1d+30)) then ! also test if pixel is not masked  
              i=int((vx(k)-vx_min)/bin_vx+1.0d0)! index of bin along vx
              number_pix(i)=number_pix(i)+1.0d0 ! number of pixels so far in bin i
              final_npixel=final_npixel+1 ! increase total number of contributing pixels  
              x(i)         =x(i)+vx(k)    ! sum vx values
              vvy          =vvy +vy(k)    ! sum vy values
              intensity(i) =intensity(i)+pixel_int(k)    ! sum intensity values
              error_int(i) =error_int(i)+pixel_err(k)**2 ! sum errors squared
              pixel_index1(final_npixel)=i ! store bin index for current pixel 
              pixel_index2(final_npixel)=int(number_pix(i)) ! store order of pixel in bin i
              pixel_index3(final_npixel)=k ! store global index in (det,en) matrix for current pixel
           end if
        end do ! l=1,ne	
     end do    ! j=1,ndet
  else     ! binning along the energy axis for each contributing detector
     do j=1,ndet
        do l=1,ne
           k=j+ndet*(l-1)   ! global index in the (ndet,ne) matrix 
           ! run energy index first, then detector index 
           if ((vx(k).ge.vx_min).and.(vx(k).lt.vx_max).and.(vy(k).ge.vy_min).and.(vy(k).le.vy_max).and. &
                (pixel_int(k) .gt. -1d+30)) then ! also test if pixel is not masked  
              number_pix(j)=number_pix(j)+1.0d0 ! number of pixels so far in bin j
              final_npixel=final_npixel+1 ! increase total number of contributing pixels  
              x(j)         =x(j)+vx(k) ! sum vx values
              vvy          =vvy +vy(k) ! sum vy values
              intensity(j) =intensity(j)+pixel_int(k) ! sum intensity values
              error_int(j) =error_int(j)+pixel_err(k)**2 ! sum errors squared
              pixel_index1(final_npixel)=j ! store bin index for current pixel 
              pixel_index2(final_npixel)=int(number_pix(j)) ! store order of pixel in bin j
              pixel_index3(final_npixel)=k ! store global index in (det,en) matrix for current pixel
           end if
        end do ! l=1,ne	
     end do    ! j=1,ndet
  end if
  m=0  ! will contain final number of bins with pixels in them 
  ! if no contributing pixels then return
  if (final_npixel .eq. 0) then 
     return
  end if
  ! take the average over each bin and count number of bins with data 	
  cumm_npixels(1)=0 
  do i=1,n
     if (number_pix(i) .ge. 1.0d0) then
        m=m+1  ! move on to next bin with pixels
        bin_index(i) =m  ! former bin i becomes true bin m 
        number_pix(m)=number_pix(i)  
        x(m)         =x(i)/number_pix(m) ! average vx values
        intensity(m) =intensity(i)/number_pix(m) ! average intensity values
        error_int(m) =sqrt(error_int(i))/number_pix(m) ! average errors squared
        if (m .ge. 2) then  ! compute cummulative sums of contributing pixels up to the current bin
           cumm_npixels(m)=cumm_npixels(m-1)+int(number_pix(m-1))
        end if
     end if
  end do
  ! determine average of vy and vz values per cut
  vvy=vvy/dfloat(final_npixel)
  ! determine true pixel order 
  do k=1,final_npixel
     i=cumm_npixels(bin_index(pixel_index1(k)))+pixel_index2(k) 
     ! i=integer*4 global index of current pixel into the 
     perm(i)=dfloat(pixel_index3(k))  ! (real*8=double) sequence of contributing pixels 
  end do
  !     x(1:m) vx values in bins, (m+1:end) discard
  !     intensity(1:m) intensity per bins, (m+1:end) discard 
  !     same with error_in(1:m), and number_pix(1:m)
  !     perm(1:final_npixel) sequence of pixels in the order they go in bins, (final_pixel+1:Npixels) discard
  return
end subroutine cut2d_df

subroutine reduce_output (m,n,full,reduced)
  mwsize::m,n
  real*8,intent(in)::full(n)
  real*8,intent(inout)::reduced(m)
  reduced(1:m)=full(1:m)
end subroutine reduce_output
