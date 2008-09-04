!==============================================================================================   
!     >> mex slice_df.f
!     This is a MEX-file for MATLAB.   
!     to take a slice from a 3D data set of pixels with (vx,vy,vz) coordinates 
!     take only pixels with coordinate  vz_min<vz<vz_max and plot intensity 
!     (error calculated as well) onto a rectangular 2d grid in the 
!     (vx,vy) plane [vx_min to vx_max] and [vy_min to vy_max] 
!     10-Oct-2000 version for Digital Visual Fortran 6
!     use passing pointers in Fortran through the %VAL construct
!    
!     Dickon Champion 21-Feb-2008 
!     compiled for PC (32 bit)/ Linux (32 &64 bit) file converted to fortran 90, 
!     using an interface to the matlab functions to avoid the use of the %VAL construct
!     should compile with the following compilers for linux: g95,gfortran,ifort
!==============================================================================================	
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  !-----------------------------------------------------------------------
  !     (integer) Replace integer by integer*4 on the DEC Alpha and the
  !     SGI 64-bit platforms
  implicit NONE
  integer plhs(*), prhs(*)
  integer nrhs, nlhs
  ! declare local variables to deal with pointers to variables passed by/to MATLAB
  integer,pointer:: vx_pr, vy_pr, vz_pr, pixel_int_pr, pixel_err_pr, grid_pr
  integer,pointer:: intensity_pr, error_int_pr
  ! declare calling functions
  integer:: mxCreateFull, mxGetM, mxGetN, mxIsNumeric
  ! declare local operating variables of the interface function
  integer:: ndet, ne, n, m
  real*8 ::grid(8), vx_min, vx_max, bin_vx, &
       vy_min, vy_max, bin_vy, vz_min, vz_max
  interface
     function mxgetpr(pm)
       integer,pointer :: mxgetpr
       integer :: pm
     end function mxgetpr
  end interface
  interface
     subroutine mxcopyptrtoreal8(pm,array,n)
       integer,pointer :: pm
       integer::n
       real*8:: array(n)
     end subroutine mxcopyptrtoreal8
  end interface
  !     Check for proper number of MATLAB input and output arguments 
  if (nrhs .ne. 6) then
     call mexErrMsgTxt('Six inputs (vx,vy,vz,pixel_int,pixel_err,grid) required.')
  elseif (nlhs .ne. 2) then
     call mexErrMsgTxt('Two outputs (intensity,err_int) required.')
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
  elseif ((mxGetM(prhs(5)).ne.ndet).or.(mxGetN(prhs(5)).ne.ne)) then
     call mexErrMsgTxt('Size of input #5 does not mach that of input #1')
  elseif ((mxGetM(prhs(6))*mxGetN(prhs(6))) .ne. 8) then
     call mexErrMsgTxt('Input #6 grid should have 8 elements.') 
  end if

  !     Get vx,vy,vz,pixel_int,pixel_err and grid parameters
  vx_pr=>mxGetPr(prhs(1))
  vy_pr=>mxGetPr(prhs(2))
  vz_pr=>mxGetPr(prhs(3)) 
  pixel_int_pr=>mxGetPr(prhs(4))
  pixel_err_pr=>mxGetPr(prhs(5))
  grid_pr=>mxGetPr(prhs(6))
  call mxCopyPtrToReal8(grid_pr,grid,8)

  vx_min=grid(1)
  vx_max=grid(2)
  bin_vx=grid(3)
  vy_min=grid(4)
  vy_max=grid(5)
  bin_vy=grid(6)
  vz_min=grid(7)
  vz_max=grid(8)     
  n=int((vx_max+bin_vx-(vx_min-bin_vx/2.0d0))/bin_vx)
  m=int((vy_max+bin_vy-(vy_min-bin_vy/2.0d0))/bin_vy)

  !     Create matrices for the return arguments
  plhs(1)   =mxCreateFull(m,n,0)
  plhs(2)   =mxCreateFull(m,n,0)
  intensity_pr =>mxGetPr(plhs(1))
  error_int_pr =>mxGetPr(plhs(2))

  !     Call the computational subroutine slice_df
  call slice_df(vx_pr,vy_pr,vz_pr, &
       pixel_int_pr,pixel_err_pr, ndet*ne, & 
       vx_min-bin_vx/2.0d0,bin_vx,n, &
       vy_min-bin_vy/2.0d0,bin_vy,m,vz_min,vz_max, &
       intensity_pr,error_int_pr)

  return
end subroutine mexFunction
!
! ===============================================================================
! actual FORTRAN code for the bin2dall_df algorithm
! distribute all data points into bins, then take average over each bin
! =============================================================================== 
subroutine slice_df(vx,vy,vz, &
     pixel_int,pixel_err,Npixels, &
     vx_min,bin_vx,n, &
     vy_min,bin_vy,m,vz_min,vz_max, &
     intensity,error_int)
  ! declare input and output variables
  implicit NONE
  !     m = number of rows, 
  !     n = number of columns	
  integer m, n, number_pts(m*n), Npixels
  real*8 vx(*), vy(*), vz(*), pixel_int(*), pixel_err(*), &
       vx_min, bin_vx, vy_min, bin_vy, vz_min, vz_max,&
       intensity(*),error_int(*)
  real*8 vx_max, vy_max
  ! declare local variables   
  integer i, j, ij, k
  ! initialize to zero the number of points and cummulative intensity in each bin
  do i=1,m
     do j=1,n
        ij=i+m*(j-1)
        number_pts(ij)=0
        intensity(ij)=0.0d0
        error_int(ij)=0.0d0
     end do
  end do
  ! run through all pixels and if contributing then distribute then into bins
  vx_max=vx_min+dfloat(n)*bin_vx
  vy_max=vy_min+dfloat(m)*bin_vy 
  do k=1,Npixels
     if ((vx(k).ge.(vx_min)).and.(vx(k).lt.vx_max).and. & 
          (vy(k).ge.(vy_min)).and.(vy(k).lt.vy_max).and. &
          (vz(k).ge.(vz_min)).and.(vz(k).le.vz_max).and. &
          (pixel_int(k) .gt. -1d+30)) then    ! also test if pixel is not masked
        i=int((vy(k)-vy_min)/bin_vy+1.0d0)
        j=int((vx(k)-vx_min)/bin_vx+1.0d0)
        ij=i+m*(j-1)
        number_pts(ij)=number_pts(ij)+1
        intensity(ij)=intensity(ij)+pixel_int(k)
        error_int(ij)=error_int(ij)+pixel_err(k)**2 
     end if
  end do
  ! take the average over each bin	
  do i=1,m
     do j=1,n
        ij=i+m*(j-1)
        if (number_pts(ij) .ge. 1) then
           intensity(ij)=intensity(ij)/dfloat(number_pts(ij))
           error_int(ij)=sqrt(error_int(ij))/dfloat(number_pts(ij))
        else
           intensity(ij)=-1d+30
           error_int(ij)=0.0d0
        end if
     end do
  end do

  return
end subroutine slice_df

