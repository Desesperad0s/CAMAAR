require "application_system_test_case"

class AlternativasTest < ApplicationSystemTestCase
  setup do
    @alternativa = alternativas(:one)
  end

  test "visiting the index" do
    visit alternativas_url
    assert_selector "h1", text: "Alternativas"
  end

  test "should create alternativa" do
    visit alternativas_url
    click_on "New alternativa"

    fill_in "Content", with: @alternativa.content
    click_on "Create Alternativa"

    assert_text "Alternativa was successfully created"
    click_on "Back"
  end

  test "should update Alternativa" do
    visit alternativa_url(@alternativa)
    click_on "Edit this alternativa", match: :first

    fill_in "Content", with: @alternativa.content
    click_on "Update Alternativa"

    assert_text "Alternativa was successfully updated"
    click_on "Back"
  end

  test "should destroy Alternativa" do
    visit alternativa_url(@alternativa)
    click_on "Destroy this alternativa", match: :first

    assert_text "Alternativa was successfully destroyed"
  end
end
