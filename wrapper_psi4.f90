subroutine cc(froz, socc, docc, orbs, actocc_in, actunocc_in, &
        etol, maxiter, keep_amps, ifrhf, &
    onebody, twobody, erepul, eref_psi4)

    ! CC(t;3) main driver. This routine receives input information from PSI4 and
    ! runs the corresponding CCSDt, L-CCSD, and moment-correction codes.

    ! In:
    !    sys:

    use, intrinsic :: iso_fortran_env, only: error_unit
    use :: iso_c_binding, only: c_char, c_null_char

    use integrals, only: write_integrals

    implicit none

    ! Molecular system from PSI4
    integer, intent(in) :: froz
    integer, intent(in) :: socc
    integer, intent(in) :: docc
    integer, intent(in) :: orbs
    integer, intent(in) :: actocc_in, actunocc_in

    ! Integrals
    real(kind=8), intent(in) :: onebody(orbs, orbs)
    real(kind=8), intent(in) :: twobody(orbs, orbs, orbs, orbs)

    real(kind=8), intent(in) :: erepul, eref_psi4
    real(kind=8) :: eref
    real(kind=8) :: ccpq_energy(4)

    integer :: diis_space
    integer :: occ_a, occ_b

    ! Calculation parameters
    integer, intent(in) :: etol
    integer, intent(in) :: maxiter
    logical, intent(in) :: keep_amps
    logical, intent(in) :: ifrhf
    real(kind=8) :: shift
    character(len=100) :: label

    logical :: restart
    integer :: ifr, idiis
    integer :: itol
    integer :: actocc, actunocc

    ! CC variables
    real(kind=8) :: ecor

    ! IO and filemanagement
    character(len=500) :: io

    call print_header()

    label = 'test'
    diis_space = 5
    restart = .false.

    ! [TODO] these are the variables needed
    occ_a = socc + docc
    occ_b = docc

    itol = etol

    shift = 0.0d0

    ! [TODO] the C arrays could be deallocated
    call write_integrals(onebody, twobody, orbs)

    actocc = max(occ_b-actocc_in, froz)
    actunocc = min(occ_a+actunocc_in, orbs)

    ! Open binary file
    call solve_cc(occ_a, occ_b, orbs, froz, actocc, actunocc, &
        shift,itol, &
        erepul, eref, ecor, ccpq_energy, &
        diis_space, restart, maxiter, &
        'onebody.inp', 'twobody.inp', label)


    call print_summary(erepul + eref, ecor, ccpq_energy)

end subroutine cc