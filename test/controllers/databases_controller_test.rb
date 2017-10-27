require 'test_helper'

class DatabasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @database = databases(:one)
  end

  test "should get index" do
    get databases_url
    assert_response :success
  end

  test "should get new" do
    get new_database_url
    assert_response :success
  end

  test "should create database" do
    assert_difference('Database.count') do
      post databases_url, params: { database: { data: @database.data, number: @database.number } }
    end

    assert_redirected_to database_url(Database.last)
  end

  test "should show database" do
    get database_url(@database)
    assert_response :success
  end

  test "should get edit" do
    get edit_database_url(@database)
    assert_response :success
  end

  test "should update database" do
    patch database_url(@database), params: { database: { data: @database.data, number: @database.number } }
    assert_redirected_to database_url(@database)
  end

  test "should destroy database" do
    assert_difference('Database.count', -1) do
      delete database_url(@database)
    end

    assert_redirected_to databases_url
  end
end
