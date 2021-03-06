require 'rails_helper'

feature 'Registration form' do

  scenario 'username is not available', :js do
    user = create(:user)

    visit new_user_registration_path
    expect(page).to_not have_content I18n.t("devise_views.users.registrations.new.username_is_not_available")

    fill_in "user_username", with: user.username
    check 'user_terms_of_service'

    expect(page).to have_content I18n.t("devise_views.users.registrations.new.username_is_not_available")
  end

  scenario 'username is available', :js do
    visit new_user_registration_path
    expect(page).to_not have_content I18n.t("devise_views.users.registrations.new.username_is_available")

    fill_in "user_username", with: "available username"
    check 'user_terms_of_service'

    expect(page).to have_content I18n.t("devise_views.users.registrations.new.username_is_available")
  end

  scenario 'do not save blank redeemable codes' do
    visit new_user_registration_path(use_redeemable_code: 'true')

    fill_in 'user_username',              with: "NewUserWithCode77"
    fill_in 'user_email',                 with: "new@madrid.es"
    fill_in 'user_password',              with: "password"
    fill_in 'user_password_confirmation', with: "password"
    fill_in 'user_redeemable_code',       with: "            "
    check 'user_terms_of_service'

    click_button 'Register'

    expect(page).to have_content "Thank you for registering"

    new_user = User.last
    expect(new_user.username).to eq("NewUserWithCode77")
    expect(new_user.redeemable_code).to be_nil
  end

  scenario 'Create with invisible_captcha honeypot field' do
    visit new_user_registration_path

    fill_in 'user_username',              with: "robot"
    fill_in 'user_family_name',           with: 'This is the honeypot field'
    fill_in 'user_email',                 with: 'robot@robot.com'
    fill_in 'user_password',              with: 'destroyallhumans'
    fill_in 'user_password_confirmation', with: 'destroyallhumans'
    check 'user_terms_of_service'

    click_button 'Register'

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(current_path).to eq(user_registration_path)
  end

  scenario 'Create organization too fast' do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)
    visit new_user_registration_path

    fill_in 'user_username',              with: "robot"
    fill_in 'user_family_name',           with: 'This is the honeypot field'
    fill_in 'user_email',                 with: 'robot@robot.com'
    fill_in 'user_password',              with: 'destroyallhumans'
    fill_in 'user_password_confirmation', with: 'destroyallhumans'
    check 'user_terms_of_service'

    click_button 'Register'

    expect(page).to have_content 'Sorry, that was too quick! Please resubmit'

    expect(current_path).to eq(new_user_registration_path)
  end


end
