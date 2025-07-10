require "application_system_test_case"

class TurmaAlunosTest < ApplicationSystemTestCase
  setup do
    @turma_aluno = turma_alunos(:one)
  end

  test "visiting the index" do
    visit turma_alunos_url
    assert_selector "h1", text: "Turma alunos"
  end

  test "should create turma aluno" do
    visit turma_alunos_url
    click_on "New turma aluno"

    click_on "Create Turma aluno"

    assert_text "Turma aluno was successfully created"
    click_on "Back"
  end

  test "should update Turma aluno" do
    visit turma_aluno_url(@turma_aluno)
    click_on "Edit this turma aluno", match: :first

    click_on "Update Turma aluno"

    assert_text "Turma aluno was successfully updated"
    click_on "Back"
  end

  test "should destroy Turma aluno" do
    visit turma_aluno_url(@turma_aluno)
    click_on "Destroy this turma aluno", match: :first

    assert_text "Turma aluno was successfully destroyed"
  end
end
