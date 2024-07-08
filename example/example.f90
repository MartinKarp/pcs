program example
    use pcg_f
    use cpfloat_f
    use pcs_f
    use, intrinsic :: iso_fortran_env
    use, intrinsic :: iso_c_binding
    implicit none
    
    integer(kind=int64), parameter :: N = 10
    type(pcs_struct),target :: options
    real(kind=real64), allocatable :: test(:)
    real(kind=real64), allocatable :: testout(:)
    real(kind=real64) :: maxdif, maxreldif
    integer :: i
    integer(c_int) :: ierr

    allocate(test(N))
    allocate(testout(N))

    options%fpopts_ptr = c_loc(options%fpopts)
    options%oper = PCS_ARBITRARY_ROUND
    options%arbitrary_amp = 0.1

    do i = 1, N
       test(i) = (i*0.2_real64)**2.0_real64 + 1.32_real64*i
    end do

    print *,'Round to arbitrary fixed precision'
    print *,'Round to closest',options%arbitrary_amp, 'Max dif <',options%arbitrary_amp/2

    ierr = pcs(testout, test, N, options)
    maxdif = 0.0_real64
    maxreldif = 0.0_real64
    do i = 1, N
       print *, 'In:', test(i),'Out:', testout(i)
       maxdif = max(maxdif,abs(test(i)-testout(i)))
       maxreldif = max(maxreldif,abs((test(i)-testout(i))/test(i)))
    end do
    print *, 'Maxdif', maxdif,'Max rel dif', maxreldif

    !! Do rounding with CPFloat
    !!'FP64: precision=53 emax=1023 '
    !!'FP32: 24 127'
    !!'FP16: 11 15'
    !!'bfloat16: 8 127'
    !!'FP8-e4m3: 4 7'
    !!'FP8-e5m2: 3 15'
    !!'Rounding: 1=round to nearest'
    !!'Rounding: 5=Stochastic rounding'
    !!'Rounding: 10=noise'
 
    options%oper = PCS_CPFLOAT
    options%fpopts%precision = 11                !Bits in the significand + 1.
    options%fpopts%emax = 15
    options%fpopts%emin = -14
    options%fpopts%round = CPFLOAT_RND_NE        !Round toward +infinity.

    ierr = pcs(testout, test, N, options)
    print *, 'Round to nearest, FP16 with CPFloat'
    print *, 'Max rel dif <',2.0**(-options%fpopts%precision)
    maxdif = 0.0
    maxreldif = 0.0
    do i = 1, N
       print *, 'In:', test(i),'Out:', testout(i)
       maxdif = max(maxdif,abs(test(i)-testout(i)))
       maxreldif = max(maxreldif,abs((test(i)-testout(i))/test(i)))
    end do
    print *, 'Maxdif', maxdif,'Max rel dif', maxreldif

    options%fpopts%round = CPFLOAT_RND_SP

    ierr = validate_pcs_struct(options)

    if (ierr .ne. 0) print *,'something off in cpfloat opts, ierr: ', ierr

    ierr = pcs(testout, test, N, options)
    print *, 'Stochastic rounding, FP16 with CPFloat'
    print *, 'Max rel dif (if not SR) <',2.0**(-options%fpopts%precision)
    maxdif = 0.0
    maxreldif = 0.0
    do i = 1, N
       print *, 'In:', test(i),'Out:', testout(i)
       maxdif = max(maxdif,abs(test(i)-testout(i)))
       maxreldif = max(maxreldif,abs((test(i)-testout(i))/test(i)))
    end do
    print *, 'Maxdif', maxdif,'Max rel dif', maxreldif

    !!Add uniform noise, set random seed
    call pcg64_srandom(4_8, 1_8)
    options%oper = PCS_UNIFORM_NOISE
    options%arbitrary_amp = 0.1
    ierr = pcs(testout, test, N, options)
    print *, 'Add uniform noise, in interval x*[1-r,1+r] r in U(-0.05,0.05)'
    print *, 'Max rel dif <',options%arbitrary_amp/2
    maxdif = 0.0
    maxreldif = 0.0
    do i = 1, N
       print *, 'In:', test(i),'Out:', testout(i)
       maxdif = max(maxdif,abs(test(i)-testout(i)))
       maxreldif = max(maxreldif,abs((test(i)-testout(i))/test(i)))
    end do
    print *, 'Maxdif', maxdif,'Max rel dif', maxreldif
    deallocate(test)
    deallocate(testout)
    

end program example
