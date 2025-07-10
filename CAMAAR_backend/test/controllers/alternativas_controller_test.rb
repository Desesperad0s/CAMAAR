require "test_helper"

class AlternativasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alternativa = alternativas(:one)
  end

  test "should get index" do
    get alternativas_url
    assert_response :success
  end

  test "should get new" do
    get new_alternativa_url
    assert_response :success
  end

  test "should create alternativa" do
    assert_difference("Alternativa.count") do
      post alternativas_url, params: { alternativa: { content: @alternativa.content } }
    end

    assert_redirected_to alternativa_url(Alternativa.last)
  end

  test "should show alternativa" do
    get alternativa_url(@alternativa)
    assert_response :success
  end

  test "should get edit" do
    get edit_alternativa_url(@alternativa)
    assert_response :success
  end

  test "should update alternativa" do
    patch alternativa_url(@alternativa), params: { alternativa: { content: @alternativa.content } }
    assert_redirected_to alternativa_url(@alternativa)
  end

  test "should destroy alternativa" do
    assert_difference("Alternativa.count", -1) do
      delete alternativa_url(@alternativa)
    end

    assert_redirected_to alternativas_url
  end
end
