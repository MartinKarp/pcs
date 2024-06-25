!Provides fortran wrapper for functionalities in cpfloat
!Introcudes the modules pcg_f (for random numbers) and cpfloat_f for rounding
! cpfloat is described in:
! Massimiliano Fasi and Mantas Mikaitis. CPFloat: A C Library for Simulating Low-precision Arithmetic.
! ACM Trans. Math. Softw. 49, 2, Article 18 (June 2023), 32 pages.
! https://doi.org/10.1145/3585515

module pcg_f
  use, intrinsic :: iso_fortran_env
  use, intrinsic :: iso_c_binding
  implicit none

  !same as pcg32_random_t
  type, public, bind(c) :: pcg_state_setseq_64
     integer(c_int64_t) :: state
     integer(c_int64_t) :: inc
  end type

  !same as pcg64_random_t
  type, public, bind(c) :: pcg_state_setseq_128
     integer(c_int64_t) :: state
     integer(c_int64_t) :: inc
  end type
  interface
    integer(c_int32_t) function pcg32_random()&
        bind(c, name="pcg32_random")
      use, intrinsic :: iso_c_binding
    end function pcg32_random
  end interface
  interface
    subroutine pcg32_srandom(initstate, initseq)& 
        bind(c, name="pcg32_srandom")
      use, intrinsic :: iso_c_binding
      integer(c_int64_t), value :: initstate
      integer(c_int64_t), value :: initseq
    end subroutine pcg32_srandom
  end interface

  interface
    integer(c_int64_t) function pcg64_random()&
        bind(c, name="pcg64_random")
      use, intrinsic :: iso_c_binding
    end function pcg64_random
  end interface
  interface
    subroutine pcg64_srandom(initstate, initseq)&
        bind(c, name="pcg64_srandom")
      use, intrinsic :: iso_c_binding
      integer(c_int64_t), value :: initstate
      integer(c_int64_t), value :: initseq
    end subroutine pcg64_srandom
  end interface
end module pcg_f


module cpfloat_f
  use, intrinsic :: iso_fortran_env
  use, intrinsic :: iso_c_binding
  use pcg_f
  implicit none
  type, public, bind(c) :: optstruct
      character(c_char) :: format(15)
      integer(c_int) :: precision
      integer(c_int) :: emin
      integer(c_int) :: emax
      integer(c_int) :: explim
      integer(c_int) :: infinity
      integer(c_int) :: round
      integer(c_int) :: saturation
      integer(c_int) :: subnormal
      integer(c_int) :: flip 
      real(c_double) :: p 
      type(c_ptr) :: bitseed = C_NULL_PTR
      type(c_ptr) :: randseedf = C_NULL_PTR
      type(c_ptr) :: randseed = C_NULL_PTR
   end type optstruct

  integer(c_int), public, parameter :: CPFLOAT_EXPRANGE_STOR = 0
  integer(c_int), public, parameter :: CPFLOAT_EXPRANGE_TARG = 1

  integer(c_int), public, parameter :: CPFLOAT_INF_NO = 0
  integer(c_int), public, parameter ::  CPFLOAT_INF_USE = 1

  integer(c_int), public, parameter :: CPFLOAT_RND_NA = -1
  ! Use round-to-nearest with ties-to-zero. */
  integer(c_int), public, parameter :: CPFLOAT_RND_NZ =  0
  ! Use round-to-nearest with ties-to-even. */
  integer(c_int), public, parameter :: CPFLOAT_RND_NE =  1
  ! Use round-toward-+&infin;. */
  integer(c_int), public, parameter :: CPFLOAT_RND_TP =  2
  ! Use round-toward-&minus;&infin;. */
  integer(c_int), public, parameter :: CPFLOAT_RND_TN =  3
  ! Use round toward zero */
  integer(c_int), public, parameter ::  CPFLOAT_RND_TZ =  4
  ! Stochastic rounding with proportional probabilities. */
  integer(c_int), public, parameter ::  CPFLOAT_RND_SP =  5
  ! Stochastic rounding with equal probabilities. */
  integer(c_int), public, parameter ::  CPFLOAT_RND_SE =  6
  ! Use round-to-odd. */
  integer(c_int), public, parameter ::  CPFLOAT_RND_OD =  7
  ! Do not perform rounding. 
  integer(c_int), public, parameter ::  CPFLOAT_NO_RND =  8

  integer(c_int), public, parameter ::  CPFLOAT_SAT_NO = 0
  ! Use saturation arithmetic. 
  integer(c_int), public, parameter ::  CPFLOAT_SAT_USE = 1

  integer(c_int), public, parameter ::  CPFLOAT_SOFTERR_NO = 0
  ! Soft errors in fraction of target-format floating-point representation.
  integer(c_int), public, parameter ::  CPFLOAT_SOFTERR_FRAC = 1
  ! Soft errors anywhere in target-format floating-point representation. 
  integer(c_int), public, parameter ::  CPFLOAT_SOFTERR_FP = 2

  ! Support storage of subnormal numbers.
  integer(c_int), public, parameter ::  CPFLOAT_SUBN_RND = 0
  integer(c_int), public, parameter ::  CPFLOAT_SUBN_USE = 1
  interface
     integer(c_int) function cpfloat_intf(y,x,n,fpopts)&
          bind(c, name='cpfloat')
       use, intrinsic :: iso_c_binding
       import optstruct
       implicit none
       integer(c_size_t), value :: n
       real(kind=c_double) :: y(n), x(n)
       type(optstruct) :: fpopts
     end function cpfloat_intf
  end interface

  interface
     integer(c_int) function cpfloat_validate_optstruct_intf(fpopts)&
          bind(c, name='cpfloat_validate_optstruct')
       use, intrinsic :: iso_c_binding
       import optstruct
       implicit none
       type(optstruct) :: fpopts
     end function cpfloat_validate_optstruct_intf
  end interface

  interface
      type(optstruct) function cpfloat_init_optstruct_intf()&
          bind(c, name='init_optstruct')
       use, intrinsic :: iso_c_binding
       import optstruct
       implicit none
     end function cpfloat_init_optstruct_intf
  end interface
  contains

    function cpfloat_validate_optstruct(fpopts) result(ierr)
       use, intrinsic :: iso_c_binding
       implicit none
       type(optstruct) :: fpopts
       integer :: ierr
       ierr = cpfloat_validate_optstruct_intf(fpopts)
    end function cpfloat_validate_optstruct

    function cpfloat_init_optstruct() result(fpopts)
      use, intrinsic :: iso_c_binding
      implicit none
      type(optstruct) :: fpopts
      fpopts = cpfloat_init_optstruct_intf()
    end function cpfloat_init_optstruct

    function cpfloat(y,x,n,fpopts) result(ierr)
       use, intrinsic :: iso_c_binding
       implicit none
       integer(c_size_t), value :: n
       real(c_double) :: y(n), x(n)
       type(optstruct) :: fpopts
       integer(c_int) :: ierr
       ierr = cpfloat_intf(y,x,n,fpopts)
     end function cpfloat
end module cpfloat_f

module pcs_f
  use, intrinsic :: iso_fortran_env
  use, intrinsic :: iso_c_binding
  use pcg_f
  use cpfloat_f
  implicit none
  type, public, bind(c) :: pcs_struct
      integer(c_int) :: oper
      real(c_double) :: arbitrary_amp
      type(c_ptr) :: fpopts_ptr
      type(optstruct) :: fpopts
  end type pcs_struct

  integer(kind=c_int), public, parameter :: PCS_CPFLOAT = 0
  integer(kind=c_int), public, parameter :: PCS_UNIFORM_NOISE = 1
  integer(kind=c_int), public, parameter :: PCS_ARBITRARY_ROUND = 2

  interface
     integer(c_int) function pcs_intf(y,x,n,opts)&
          bind(c, name='pcs')
       use, intrinsic :: iso_c_binding
       import pcs_struct
       implicit none
       integer(c_size_t), value :: n
       real(kind=c_double) :: y(n), x(n)
       type(pcs_struct) :: opts
     end function pcs_intf
  end interface

  interface
     integer(c_int) function validate_pcs_struct_intf(opts)&
          bind(c, name='validate_pcs_struct')
       use, intrinsic :: iso_c_binding
       import pcs_struct
       implicit none
       type(pcs_struct) :: opts
     end function validate_pcs_struct_intf
  end interface

  interface
    type(pcs_struct) function init_pcs_struct_intf()&
          bind(c, name='init_pcs_struct')
       use, intrinsic :: iso_c_binding
       import pcs_struct
       implicit none
     end function init_pcs_struct_intf
  end interface
  contains

    function validate_pcs_struct(opts) result(ierr)
      use, intrinsic :: iso_c_binding
      implicit none
      type(pcs_struct) :: opts
      integer(c_int) :: ierr
      ierr = validate_pcs_struct_intf(opts)
    end function validate_pcs_struct

    function pcs(y,x,n,pcsopts) result(ierr)
       use, intrinsic :: iso_c_binding
       implicit none
       integer(c_size_t) :: n
       real(c_double) :: y(n), x(n)
       type(pcs_struct) :: pcsopts
       integer(c_int) :: ierr
       ierr = pcs_intf(y,x,n,pcsopts)
     end function pcs

end module pcs_f
