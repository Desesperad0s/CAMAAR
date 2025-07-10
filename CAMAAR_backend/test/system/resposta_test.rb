require "application_system_test_case"

class RespostaTest < ApplicationSystemTestCase
  setup do
    @respostum = resposta(:one)
  end

  test "visiting the index" do
    visit resposta_url
    assert_selector "h1", text: "Resposta"
  end

  test "should create respostum" do
    visit resposta_url
    click_on "New respostum"

    fill_in "Content", with: @respostum.content
    click_on "Create Respostum"

    assert_text "Respostum was successfully created"
    click_on "Back"
  end

  test "should update Respostum" do
    visit respostum_url(@respostum)
    click_on "Edit this respostum", match: :first

    fill_in "Content", with: @respostum.content
    click_on "Update Respostum"

    assert_text "Respostum was successfully updated"
    click_on "Back"
  end

  test "should destroy Respostum" do
    visit respostum_url(@respostum)
    click_on "Destroy this respostum", match: :first

    assert_text "Respostum was successfully destroyed"
  end
end
