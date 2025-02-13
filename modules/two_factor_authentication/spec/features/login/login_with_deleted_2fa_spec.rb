require_relative "../../spec_helper"
require_relative "../shared_two_factor_examples"

RSpec.describe "Login after 2FA deleted 2FA was deleted (REGRESSION)",
               :js,
               with_settings: {
                 plugin_openproject_two_factor_authentication: {
                   "active_strategies" => %i[developer totp]
                 }
               } do
  include SharedTwoFactorExamples
  let(:user_password) { "bob!" * 4 }
  let(:user) do
    create(:user,
           login: "bob",
           password: user_password,
           password_confirmation: user_password)
  end

  let!(:device1) { create(:two_factor_authentication_device_sms, user:, active: true, default: false) }
  let!(:device2) { create(:two_factor_authentication_device_totp, user:, active: true, default: true) }

  it "works correctly when not switching 2fa method" do
    first_login_step

    # ensure that no 2fa device is stored in the session
    session_data = Sessions::UserSession.last.data
    expect(session_data["two_factor_authentication_device_id"]).to be_nil

    # destroy all 2fa devices
    user.otp_devices.destroy_all

    # make sure we can sign in without 2fa
    first_login_step
    expect_logged_in
  end

  it "works correctly when the 2fa method was switched before deleting" do
    first_login_step
    switch_two_factor_device(device1)

    # ensure that the selected 2fa device is stored in the session
    session_data = Sessions::UserSession.last.data
    expect(session_data["two_factor_authentication_device_id"]).to eq(device1.id)

    # destroy all 2fa devices
    user.otp_devices.destroy_all

    # make sure we can sign in without 2fa
    first_login_step
    expect_logged_in
  end
end
