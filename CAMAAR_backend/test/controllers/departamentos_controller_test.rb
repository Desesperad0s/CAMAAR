require "test_helper"

class DepartamentosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @departamento = departamentos(:one)
    @departamento1 = departamentos(:two)
  end

  test "should get index" do
    get departamentos_url
    assert_response :success
  end

  test "should get new" do
    get new_departamento_url, as: :json
    assert_response :success
  end

  test "should create departamento" do
    assert_difference("Departamento.count") do
      post departamentos_url, params: { departamento: { abreviation: @departamento.abreviation, code: @departamento.code, name: @departamento.name } }, as: :json
    end

    assert_response :success

    depResult = JSON.parse(response.body)

    assert_equal @departamento.code, depResult["code"]
  end

  test "should show departamento" do
    get departamento_url(@departamento), as: :json
    assert_response :success

    depResult = JSON.parse(response.body)

    assert_equal @departamento.code, depResult["code"]
  end

  test "should get edit" do
    get edit_departamento_url(@departamento), as: :json
    assert_response :success
  end

  test "should update departamento" do
    patch departamento_url(@departamento), params: { departamento: { abreviation: @departamento1.abreviation, code: @departamento1.code, name: @departamento1.name } }, as: :json
    assert_response :success

    depResult = JSON.parse(response.body)

    assert_equal @departamento.id, depResult["id"]
    assert_equal @departamento1.code, depResult["code"]
  end

  test "should destroy departamento" do
    assert_difference("Departamento.count", -1) do
      delete departamento_url(@departamento), as: :json
    end

    assert_response :no_content
  end
end
