require "test_helper"

class TurmaAlunosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @turma_aluno = turma_alunos(:one)
  end

  test "should get index" do
    get turma_alunos_url
    assert_response :success
  end

  test "should get new" do
    get new_turma_aluno_url
    assert_response :success
  end

  test "should create turma_aluno" do
    assert_difference("TurmaAluno.count") do
      post turma_alunos_url, params: { turma_aluno: {} }
    end

    assert_redirected_to turma_aluno_url(TurmaAluno.last)
  end

  test "should show turma_aluno" do
    get turma_aluno_url(@turma_aluno)
    assert_response :success
  end

  test "should get edit" do
    get edit_turma_aluno_url(@turma_aluno)
    assert_response :success
  end

  test "should update turma_aluno" do
    patch turma_aluno_url(@turma_aluno), params: { turma_aluno: {} }
    assert_redirected_to turma_aluno_url(@turma_aluno)
  end

  test "should destroy turma_aluno" do
    assert_difference("TurmaAluno.count", -1) do
      delete turma_aluno_url(@turma_aluno)
    end

    assert_redirected_to turma_alunos_url
  end
end
