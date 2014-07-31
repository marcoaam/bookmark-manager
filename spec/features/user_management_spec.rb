require 'spec_helper'
require 'helpers/session'

include SessionHelpers

feature "User signs up" do

  scenario "when being logged out" do    
    lambda { sign_up }.should change(User, :count).by(1)    
    expect(page).to have_content("Welcome, marco@example.com")
    expect(User.first.email).to eq("marco@example.com")        
  end

  scenario "with a password that doesn't match" do
    lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0)
    expect(current_path).to eq('/users')   
    expect(page).to have_content("Password does not match the confirmation")    
  end

  scenario "with an email that is already registered" do    
    lambda { sign_up }.should change(User, :count).by(1)
    lambda { sign_up }.should change(User, :count).by(0)
    expect(page).to have_content("This email is already taken")
  end

end

feature "User signs in" do

  before(:each) do
    User.create(:email => "test@test.com", 
                :password => 'test', 
                :password_confirmation => 'test')
  end

  scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end

end

feature 'User signs out' do

  before(:each) do
    User.create(:email => "test@test.com", 
                :password => 'test', 
                :password_confirmation => 'test')
  end

  scenario 'while being signed in' do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Good bye!") # where does this message go?
    expect(page).not_to have_content("Welcome, test@test.com")
  end

end

feature 'User recovers forgotten password' do

  before(:each) do
    User.create(:email => "marco.army@gmail.com", 
                :password => 'test', 
                :password_confirmation => 'test')
  end

  scenario 'recover password providing the email' do
    sign_in('marco.army@gmail.com', 'wrong')
    click_link "Forgot password?"
    fill_in "email", :with => "marco.army@gmail.com"
    click_button "Recover Password"
    expect(page).to have_content("A email has been sent with a temporary password")
  end

end