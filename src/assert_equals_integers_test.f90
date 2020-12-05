module assert_equals_integers_test
    implicit none
    private
    public :: test_assert_equals_integers

    character(len=*), parameter :: BOTH_MESSAGE = "Both Message"
    character(len=*), parameter :: SUCCESS_MESSAGE = "Success Message"
    character(len=*), parameter :: FAILURE_MESSAGE = "Failure Message"
contains
    function test_assert_equals_integers() result(tests)
        use vegetables, only: test_item_t, describe, it, INTEGER_GENERATOR

        type(test_item_t) :: tests

        type(test_item_t) :: individual_tests(2)

        individual_tests(1) = it("passes with the same integer", INTEGER_GENERATOR, check_pass_for_same_integer)
        individual_tests(2) = it("fails with different integers", check_fail_for_different_integers)
        tests = describe("assert_equals with integers", individual_tests)
    end function

    pure function check_pass_for_same_integer(the_input) result(result_)
        use iso_varying_string, only: var_str
        use vegetables, only: &
                input_t, &
                integer_input_t, &
                result_t, &
                assert_equals, &
                assert_that, &
                fail

        class(input_t), intent(in) :: the_input
        type(result_t) :: result_

        type(result_t) :: example_result
        type(result_t) :: example_result_c
        type(result_t) :: example_result_s
        type(result_t) :: example_result_cc
        type(result_t) :: example_result_cs
        type(result_t) :: example_result_sc
        type(result_t) :: example_result_ss
        integer :: input

        select type (the_input)
        type is (integer_input_t)
            input = the_input%value_
            example_result = assert_equals(input, input)
            example_result_c = assert_equals(input, input, BOTH_MESSAGE)
            example_result_s = assert_equals(input, input, var_str(BOTH_MESSAGE))
            example_result_cc = assert_equals( &
                    input, input, SUCCESS_MESSAGE, FAILURE_MESSAGE)
            example_result_cs = assert_equals( &
                    input, input, SUCCESS_MESSAGE, var_str(FAILURE_MESSAGE))
            example_result_sc = assert_equals( &
                    input, input, var_str(SUCCESS_MESSAGE), FAILURE_MESSAGE)
            example_result_ss = assert_equals( &
                    input, input, var_str(SUCCESS_MESSAGE), var_str(FAILURE_MESSAGE))
            result_ = &
                    assert_that( &
                            example_result%passed(), &
                            example_result%verbose_description(.false.)) &
                    .and.assert_that( &
                            example_result_c%passed(), &
                            example_result_c%verbose_description(.false.)) &
                    .and.assert_that( &
                            example_result_s%passed(), &
                            example_result_s%verbose_description(.false.)) &
                    .and.assert_that( &
                            example_result_cc%passed(), &
                            example_result_cc%verbose_description(.false.)) &
                    .and.assert_that( &
                            example_result_cs%passed(), &
                            example_result_cs%verbose_description(.false.)) &
                    .and.assert_that( &
                            example_result_sc%passed(), &
                            example_result_sc%verbose_description(.false.)) &
                    .and.assert_that( &
                            example_result_ss%passed(), &
                            example_result_ss%verbose_description(.false.))
        class default
            result_ = fail("Expected to get an integer")
        end select
    end function

    pure function check_fail_for_different_integers() result(result_)
        use iso_varying_string, only: var_str
        use vegetables, only: result_t, assert_equals, assert_not

        type(result_t) :: result_

        type(result_t) :: example_result
        type(result_t) :: example_result_c
        type(result_t) :: example_result_s
        type(result_t) :: example_result_cc
        type(result_t) :: example_result_cs
        type(result_t) :: example_result_sc
        type(result_t) :: example_result_ss

        example_result = assert_equals(1, 2)
        example_result_c = assert_equals(1, 2, BOTH_MESSAGE)
        example_result_s = assert_equals(1, 2, var_str(BOTH_MESSAGE))
        example_result_cc = assert_equals( &
                1, 2, SUCCESS_MESSAGE, FAILURE_MESSAGE)
        example_result_cs = assert_equals( &
                1, 2, SUCCESS_MESSAGE, var_str(FAILURE_MESSAGE))
        example_result_sc = assert_equals( &
                1, 2, var_str(SUCCESS_MESSAGE), FAILURE_MESSAGE)
        example_result_ss = assert_equals( &
                1, 2, var_str(SUCCESS_MESSAGE), var_str(FAILURE_MESSAGE))

        result_ = &
                assert_not( &
                        example_result%passed(), &
                        example_result%verbose_description(.false.)) &
                .and.assert_not( &
                        example_result_c%passed(), &
                        example_result_c%verbose_description(.false.)) &
                .and.assert_not( &
                        example_result_s%passed(), &
                        example_result_s%verbose_description(.false.)) &
                .and.assert_not( &
                        example_result_cc%passed(), &
                        example_result_cc%verbose_description(.false.)) &
                .and.assert_not( &
                        example_result_cs%passed(), &
                        example_result_cs%verbose_description(.false.)) &
                .and.assert_not( &
                        example_result_sc%passed(), &
                        example_result_sc%verbose_description(.false.)) &
                .and.assert_not( &
                        example_result_ss%passed(), &
                        example_result_ss%verbose_description(.false.))
    end function
end module
