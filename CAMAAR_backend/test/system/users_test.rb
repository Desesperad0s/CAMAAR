require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "should create user" do
    visit users_url
    click_on "New user"

    fill_in "Email", with: @user.email
    fill_in "Forms answered", with: @user.forms_answered
    fill_in "Major", with: @user.major
    fill_in "Name", with: @user.name
    fill_in "Password", with: @user.password
    fill_in "Registration", with: @user.registration
    fill_in "Role", with: @user.role
    click_on "Create User"

    assert_text "User was successfully created"
    click_on "Back"
  end

  test "should update User" do
    visit user_url(@user)
    click_on "Edit this user", match: :first

    fill_in "Email", with: @user.email
    fill_in "Forms answered", with: @user.forms_answered
    fill_in "Major", with: @user.major
    fill_in "Name", with: @user.name
    fill_in "Password", with: @user.password
    fill_in "Registration", with: @user.registration
    fill_in "Role", with: @user.role
    click_on "Update User"

    assert_text "User was successfully updated"
    click_on "Back"
  end

  test "should destroy User" do
    visit user_url(@user)
    click_on "Destroy this user", match: :first

    assert_text "User was successfully destroyed"
  end
end
