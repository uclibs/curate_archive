require 'spec_helper'

describe CurationConcern::GenericWorkActor do
  include ActionDispatch::TestProcess
  let(:user) { FactoryGirl.create(:person_with_user).user }
  let(:file) { curate_fixture_file_upload('files/image.png', 'image/png') }
  let(:file_path) { __FILE__}
  let(:file_content) { File.read(file_path)}
  let(:cloud_resource_url){ {"selected_files"=>{"0"=>{"url"=>"file://#{file_path}", "expires"=>"nil"}}}}

  subject {
    CurationConcern.actor(curation_concern, user, attributes)
  }

  describe '#create' do
    let(:curation_concern) { GenericWork.new(pid: CurationConcern.mint_a_pid )}
    let (:cloud_resource) { CloudResource.new(curation_concern, user, cloud_resource_url)}

    describe 'failure' do
      let(:attributes) { {} }

      it 'returns false' do
        CurationConcern::BaseActor.any_instance.should_receive(:save).and_return(false)
        subject.stub(:attach_files).and_return(true)
        subject.stub(:create_linked_resource).and_return(true)
        subject.create.should be_false
      end
    end

    describe 'valid attributes' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }

      describe 'with a file' do
        let(:attributes) {
          user.person.save!
          FactoryGirl.attributes_for(:generic_work, visibility: visibility).tap {|a|
            a[:files] = file
            a[:editors_attributes] = { '0' => { 'id' => user.person.pid,
                                                '_destroy' => ''},
                                       '1' => { 'id' => '', '_destroy' => '',
                                                'name' => '' } }
            a[:editor_groups_attributes] = { '0' => { 'id' => '',
                                                      '_destroy' => '' } }
          }
        }

        describe 'authenticated visibility' do
          it 'should stamp each file with the access rights' do
            subject.create.should be_true
            expect(curation_concern).to be_persisted
            curation_concern.date_uploaded.should == Date.today
            curation_concern.date_modified.should == Date.today
            curation_concern.depositor.should == user.user_key
            expect(curation_concern.edit_users).to eq [user.user_key]
            expect(curation_concern.representative).to_not be_nil

            curation_concern.generic_files.count.should == 1
            # Sanity test to make sure the file we uploaded is stored and has same permission as parent.
            generic_file = curation_concern.generic_files.first
            expect(generic_file.content.content).to eq file.read
            expect(generic_file.filename).to eq 'image.png'

            expect(curation_concern).to be_authenticated_only_access
            expect(generic_file).to be_authenticated_only_access
          end
        end

        describe 'AccessPermissionsCopyWorker' do
          describe "#new" do
            it "should accept ( :pid_for_object_to_copy_permissions_from ) as a parameter" do
              expect { AccessPermissionsCopyWorker.new( :pid_for_object_to_copy_permissions_from ) }.to_not raise_error
            end
            it "should not accept ( :foo, :bar ) as parameters" do
              expect { AccessPermissionsCopyWorker.new( :foo, :bar ) }.to raise_error
            end
          end
        end
      end

      describe 'with multiple files file' do
        let(:attributes) {
          FactoryGirl.attributes_for(:generic_work, visibility: visibility).tap {|a|
            a[:files] = [file, file]
          }
        }

        describe 'authenticated visibility' do
          it 'should stamp each file with the access rights' do
            subject.create.should be_true
            expect(curation_concern).to be_persisted
            curation_concern.date_uploaded.should == Date.today
            curation_concern.date_modified.should == Date.today
            curation_concern.depositor.should == user.user_key

            curation_concern.generic_files.count.should == 2
            # Sanity test to make sure the file we uploaded is stored and has same permission as parent.

            expect(curation_concern).to be_authenticated_only_access
          end
        end
  
        describe 'AccessPermissionsCopyWorker' do
          describe "#new" do
            it "should accept ( :pid_for_object_to_copy_permissions_from ) as a parameter" do
              expect { AccessPermissionsCopyWorker.new( :pid_for_object_to_copy_permissions_from ) }.to_not raise_error
            end
            it "should not accept ( :foo, :bar ) as parameters" do
              expect { AccessPermissionsCopyWorker.new( :foo, :bar ) }.to raise_error
            end
          end
        end
      end    

      describe 'with linked resources' do
        let(:attributes) {
          FactoryGirl.attributes_for(:generic_work, visibility: visibility, linked_resource_urls: ['http://www.youtube.com/watch?v=oHg5SJYRHA0', "http://google.com"])
        }

        describe 'authenticated visibility' do
          it 'should stamp each link with the access rights' do
            subject.create.should be_true
            expect(curation_concern).to be_persisted
            curation_concern.date_uploaded.should == Date.today
            curation_concern.date_modified.should == Date.today
            curation_concern.depositor.should == user.user_key

            curation_concern.generic_files.count.should == 0
            curation_concern.linked_resources.count.should == 2
            # Sanity test to make sure the file we uploaded is stored and has same permission as parent.
            link = curation_concern.linked_resources.first
            expect(link.url).to eq 'http://www.youtube.com/watch?v=oHg5SJYRHA0'
            expect(curation_concern).to be_authenticated_only_access
          end
        end
   
         describe 'AccessPermissionsCopyWorker' do
          describe "#new" do
            it "should accept ( :pid_for_object_to_copy_permissions_from ) as a parameter" do
              expect { AccessPermissionsCopyWorker.new( :pid_for_object_to_copy_permissions_from ) }.to_not raise_error
            end
            it "should not accept ( :foo, :bar ) as parameters" do
              expect { AccessPermissionsCopyWorker.new( :foo, :bar ) }.to raise_error
            end
          end
        end
      end

      describe 'with cloud resources' do
        let(:attributes) {
          FactoryGirl.attributes_for(:generic_work, visibility: visibility,
                                     cloud_resources: cloud_resource.resources_to_ingest)
        }

        describe 'authenticated visibility' do
          it 'should attach the files from cloud' do
            subject.create.should be_true
            expect(curation_concern).to be_persisted
            curation_concern.date_uploaded.should == Date.today
            curation_concern.date_modified.should == Date.today
            curation_concern.depositor.should == user.user_key

            curation_concern.generic_files.count.should == 1
            curation_concern.linked_resources.count.should == 0
            # Sanity test to make sure the file we uploaded is stored and has same permission as parent.
            generic_file = curation_concern.generic_files.first
            expect(generic_file.filename).to eq File.basename(__FILE__)
            expect(generic_file.content.content).to eq file_content
            expect(curation_concern).to be_authenticated_only_access
          end
        end

         describe 'AccessPermissionsCopyWorker' do
          describe "#new" do
            it "should accept ( :pid_for_object_to_copy_permissions_from ) as a parameter" do
              expect { AccessPermissionsCopyWorker.new( :pid_for_object_to_copy_permissions_from ) }.to_not raise_error
            end
            it "should not accept ( :foo, :bar ) as parameters" do
              expect { AccessPermissionsCopyWorker.new( :foo, :bar ) }.to raise_error
            end
          end
        end
      end
    end

    describe '#update' do
      let(:curation_concern) { FactoryGirl.create(:generic_work, user: user)}

      describe 'failure' do
        let(:attributes) {{}}

        it 'returns false' do
          CurationConcern::BaseActor.any_instance.should_receive(:save).and_return(false)
          subject.update.should be_false
        end
      end

      describe 'adding to collections' do
        let!(:collection1) { FactoryGirl.create(:collection, user: user) }
        let!(:collection2) { FactoryGirl.create(:collection, user: user) }
        let(:attributes) {
          FactoryGirl.attributes_for(:generic_work,
                                     visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                                     collection_ids: [collection2.pid])
        }
        before do
          curation_concern.apply_depositor_metadata(user.user_key)
          curation_concern.save!
          collection1.add_member(curation_concern)
        end

        it "should add to collections" do
          reload = GenericWork.find(curation_concern.pid)
          expect(reload.collections).to eq [collection1]

          subject.update.should be_true

          reload = GenericWork.find(curation_concern.pid)
          expect(reload.identifier).to be_blank
          expect(reload).to be_persisted
          expect(reload).to be_open_access
          expect(reload.collections.count).to eq 1
          expect(reload.collections).to eq [collection2]
          expect(subject.visibility_changed?).to be_true
        end
      end
    end
  end
end
