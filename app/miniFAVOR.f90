!  miniFAVOR.f90
!
!  FUNCTIONS:
!  miniFAVOR - Entry point of console application.
!

!****************************************************************************
!
!  PROGRAM: miniFAVOR
!
!  PURPOSE:  Entry point for the console application.
!
!****************************************************************************

    program miniFAVOR

    use I_O
    use calc_RTndt
    use calc_K
    use calc_cpi
    use randomness_m, only: random_samples_t

    implicit none

    ! Variables
    character(len=64) :: fn_IN
    integer, parameter :: n_IN = 15
    integer, parameter :: n_ECHO = n_IN + 1
    integer, parameter :: n_OUT = n_IN + 2
    integer, parameter :: n_DAT = n_IN + 3
    integer :: i, j, num_seeds
    type(random_samples_t), allocatable :: samples(:)

    ! Inputs
    real :: a, b
    integer :: nsim, ntime
    logical :: details
    real, dimension(:), allocatable :: stress, temp
    real :: Cu_ave, Ni_ave, Cu_sig, Ni_sig, fsurf, RTndt0

    ! Outputs
    real, dimension(:), allocatable :: K_hist
    real, dimension(:,:), allocatable :: Chemistry
    real, dimension(:,:), allocatable :: cpi_hist
    real, dimension(:,:), allocatable :: CPI_results

    ! Body of miniFAVOR

    !Get input file name
    call random_seed(size=num_seeds)
    call random_seed(put=[(i, i=1, num_seeds)])

    print *, 'Input file name:'
    read (*,'(a)') fn_IN

    !Read input file
    call read_IN(fn_IN, n_IN, n_ECHO, &
        a, b, nsim, ntime, details, Cu_ave, Ni_ave, Cu_sig, Ni_sig, fsurf, RTndt0, stress, temp)

    !Allocate output arrays
    allocate(K_hist(ntime))
    allocate(Chemistry(nsim,3))
    allocate(cpi_hist(nsim, ntime))
    allocate(CPI_results(nsim,3))
    allocate(samples(nsim))

    !Initialize output arrays
    K_hist =  0.0
    Chemistry = 0.0
    cpi_hist = 0.0
    CPI_results = 0.0

    !Calculate applied stress intensity factor (SIF)
    SIF_loop: do j = 1, ntime
        K_hist(j) = Ki_t(a, b, stress(j))
    end do SIF_loop

    ! This cannot be parallelized or reordered without the results changing
    do i = 1, nsim
      call samples(i)%define()
    end do

    !Start looping over number of simulations
    Vessel_loop: do i = 1, nsim

        !Sample chemistry: Chemistry(i,1) is Cu content, Chemistry(i,2) is Ni content
        call sample_chem(Cu_ave, Ni_ave, Cu_sig, Ni_sig, Chemistry(i,1), Chemistry(i,2), &
            samples(i)%Cu_sig_local, samples(i)%Cu_local, samples(i)%Ni_local)

        !Calculate chemistry factor: Chemistry(i,3) is chemistry factor
        Chemistry(i,3) = CF(Chemistry(i,1), Chemistry(i,2))

        !Calculate RTndt for this vessel trial: CPI_results(i,1) is RTndt
        CPI_results(i,1) = RTndt(a, Chemistry(i,3), fsurf, RTndt0, samples(i)%phi)

        !Start time loop
        Time_loop: do j = 1, ntime
            !Calculate instantaneous cpi(t)
            cpi_hist(i,j) = cpi_t(K_hist(j), CPI_results(i,1), temp(j))
        end do Time_loop

        !Calculate CPI for vessel 'i'
        CPI_results(i,2) = maxval(cpi_hist(i,:))

        !Calculate moving average CPI for trials executed so far
        CPI_results(i,3) = sum(CPI_results(:,2))/i

    end do Vessel_loop

    call write_OUT(fn_IN, n_OUT, n_DAT, &
        a, b, nsim, ntime, details, Cu_ave, Ni_ave, Cu_sig, Ni_sig, fsurf, RTndt0, &
        CPI_results, K_hist, Chemistry)

    end program miniFAVOR
