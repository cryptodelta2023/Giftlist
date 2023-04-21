Sequel.seed(:development) do
    def run
      puts 'Seeding accounts, giftlists, giftinfos'
      create_accounts
      create_owned_giftlists
      create_giftinfos
      add_collaborators
    end
  end

  require 'yaml'
  DIR = File.dirname(__FILE__)
  ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
  OWNER_INFO = YAML.load_file("#{DIR}/owners_giftlists.yml")
  PROJ_INFO = YAML.load_file("#{DIR}/giftlists_seed.yml")
  DOCUMENT_INFO = YAML.load_file("#{DIR}/giftinfos_seed.yml")
  CONTRIB_INFO = YAML.load_file("#{DIR}/giftlists_collaborators.yml")

  def create_accounts
    ACCOUNTS_INFO.each do |account_info|
      Credence::Account.create(account_info)
    end
  end

  def create_owned_giftlists
    OWNER_INFO.each do |owner|
      account = Credence::Account.first(username: owner['username'])
      owner['proj_name'].each do |proj_name|
        proj_data = PROJ_INFO.find { |proj| proj['name'] == proj_name }
        Credence::CreateProjectForOwner.call(
          owner_id: account.id, giftlist_data: proj_data
        )
      end
    end
  end

  def create_giftinfos
    doc_info_each = DOCUMENT_INFO.each
    giftlists_cycle = Credence::Project.all.cycle
    loop do
      doc_info = doc_info_each.next
      giftlist = giftlists_cycle.next
      Credence::CreateDocumentForProject.call(
        giftlist_id: giftlist.id, giftinfo_data: doc_info
      )
    end
  end

  def add_collaborators
    contrib_info = CONTRIB_INFO
    contrib_info.each do |contrib|
      proj = Credence::Project.first(name: contrib['proj_name'])
      contrib['collaborator_email'].each do |email|
        collaborator = Credence::Account.first(email: email)
        proj.add_collaborator(collaborator)
      end
    end
  end
