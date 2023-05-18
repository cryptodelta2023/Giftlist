# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToGiftlist service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      GiftListApp::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = GiftListApp::AuthenticateAccount.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      GiftListApp::AuthenticateAccount.call(
        username: credentials['username'], password: 'malword'
      )
    }).must_raise GiftListApp::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      GiftListApp::AuthenticateAccount.call(
        username: 'maluser', password: 'malword'
      )
    }).must_raise GiftListApp::AuthenticateAccount::UnauthorizedError
  end
end
