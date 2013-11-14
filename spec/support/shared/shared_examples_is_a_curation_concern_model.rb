shared_examples 'is_a_curation_concern_model' do
  CurationConcern::FactoryHelpers.load_factories_for(self, described_class)

  it 'is registered for classification' do
    expect(Curate.configuration.registered_curation_concern_types).to include(described_class.name)
  end

  describe 'collectibility' do
    subject { FactoryGirl.build(default_work_factory_name) }
    let(:collection) { double }
    it '#can_be_member_of_collection?' do
      expect(subject.can_be_member_of_collection?(collection)).to eq(true)
    end
  end

  describe 'its test support factories', factory_verification: true do
    it {
      expect {
        FactoryGirl.create(default_work_factory_name)
      }.to_not raise_error
    }
    it {
      expect {
        FactoryGirl.create(private_work_factory_name)
      }.to_not raise_error
    }
    it {
      expect {
        FactoryGirl.create(public_work_factory_name)
      }.to_not raise_error
    }
  end
end
