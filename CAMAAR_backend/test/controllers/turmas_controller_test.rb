require "test_helper"

class TurmasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @turma = turmas(:one)
    @turma1 = turmas(:two)
  end

  test "should get index" do
    get turmas_url, as: :json
    assert_response :success
  end

  test "should get new" do
    get new_turma_url, as: :json
    assert_response :success
  end

  test "should create turma" do
    assert_difference("Turma.count") do
      post turmas_url, params: { turma: { code: @turma.code, number: @turma.number, semester: @turma.semester, time: @turma.time } }, as: :json
    end

    assert_response :created
  end

  test "should show turma" do
    get turma_url(@turma), as: :json
    assert_response :ok

    turmaResposta = JSON.parse(response.body)

    assert_equal @turma.code, turmaResposta["code"]
    assert_equal @turma.number, turmaResposta["number"]
    assert_equal @turma.semester, turmaResposta["semester"]
    assert_equal @turma.time, turmaResposta["time"]
  end

  test "should get edit" do
    get edit_turma_url(@turma), as: :json
    assert_response :success
  end

  test "should update turma" do
    patch turma_url(@turma), params: {id: @turma.id, turma: { code: @turma1.code, number: @turma1.number, semester: @turma1.semester, time: @turma1.time } }, as: :json
    assert_response :ok

    turmaResposta = JSON.parse(response.body)

    assert_equal @turma.id, turmaResposta["id"]
    assert_equal @turma1.code, turmaResposta["code"]
  end

  test "should destroy turma" do
    assert_difference("Turma.count", -1) do
      delete turma_url(@turma), as: :json
    end

    assert_response :no_content
  end
end
