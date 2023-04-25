# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, giftlists, giftinfos'
    create_accounts
    create_owned_giftlists
    create_giftinfos
    add_followers
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_giftlists.yml")
GIFTLIST_INFO = YAML.load_file("#{DIR}/giftlists_seed.yml")
GIFTINFO_INFO = YAML.load_file("#{DIR}/giftinfos_seed.yml")
FOLLOWER_INFO = YAML.load_file("#{DIR}/giftlists_followers.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    GiftListApp::Account.create(account_info)
  end
end

def create_owned_giftlists
  OWNER_INFO.each do |owner|
    account = GiftListApp::Account.first(username: owner['username'])
    owner['giftlist_name'].each do |giftlist_name|
      giftlist_data = GIFTLIST_INFO.find { |giftlist| giftlist['list_name'] == giftlist_name }
      GiftListApp::CreateGiftlistForOwner.call(
        owner_id: account.id, giftlist_data:
      )
    end
  end
end

def create_giftinfos
  giftinfo_info_each = GIFTINFO_INFO.each
  giftlists_cycle = GiftListApp::Giftlists.all.cycle
  loop do
    giftinfo_info = giftinfo_info_each.next
    giftlist = giftlists_cycle.next
    GiftListApp::CreateGiftinfoForGiftlist.call(
      giftlist_id: giftlist.id, giftinfo_data: giftinfo_info
    )
  end
end

def add_followers
  follower_info = FOLLOWER_INFO
  follower_info.each do |follower|
    giftlist = GiftListApp::Giftlist.first(list_name: follower['giftlist_name'])
    follower['follower_email'].each do |email|
      GiftListApp::AddFollowerToGiftlist.call(
        email:, giftlist_id: giftlist.id
      )
    end
  end
end
