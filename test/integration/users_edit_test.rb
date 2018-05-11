require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
    assert_select "div.alert", text: "The form contains 4 errors."
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email

    assert_nil session[:forwarding_url]
    log_in_as(@user)
    assert_redirected_to user_url(@user)
  end

  test "layout links for logged-in and non-logged-in users" do  
    get root_path  
    assert_template 'static_pages/home'  
    assert_select "a[href=?]", root_path, count: 2  
    assert_select "a[href=?]", help_path  
    assert_select "a[href=?]", about_path  
    assert_select "a[href=?]", contact_path  
    assert_select "a[href=?]", signup_path  
    assert_select "a[href=?]", login_path  
    log_in_as(@user)  
    get root_path  
    assert_select "a[href=?]", root_path, count: 2  
    assert_select "a[href=?]", help_path  
    assert_select "a[href=?]", about_path  
    assert_select "a[href=?]", contact_path  
    assert_select "a[href=?]", login_path, count: 0  
    assert_select "a[href=?]", users_path  
    assert_select "a[href=?]", logout_path  
    assert_select "a[href=?]", "#", text: "Account"  
    assert_select "a[href=?]", user_path(@user)  
    assert_select "a[href=?]", edit_user_path(@user)  
  end
end