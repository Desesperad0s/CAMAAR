require "application_system_test_case"

class QuestaosTest < ApplicationSystemTestCase
  setup do
    @questao = questaos(:one)
  end

  test "visiting the index" do
    visit questaos_url
    assert_selector "h1", text: "Questaos"
  end

  test "should create questao" do
    visit questaos_url
    click_on "New questao"

    fill_in "Enunciado", with: @questao.enunciado
    click_on "Create Questao"

    assert_text "Questao was successfully created"
    click_on "Back"
  end

  test "should update Questao" do
    visit questao_url(@questao)
    click_on "Edit this questao", match: :first

    fill_in "Enunciado", with: @questao.enunciado
    click_on "Update Questao"

    assert_text "Questao was successfully updated"
    click_on "Back"
  end

  test "should destroy Questao" do
    visit questao_url(@questao)
    click_on "Destroy this questao", match: :first

    assert_text "Questao was successfully destroyed"
  end
end
