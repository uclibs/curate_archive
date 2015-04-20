class DelegateEditorAssignWorker
  class GrantError < RuntimeError

    def initialize(url_string)
      super(url_string)
    end
  end

  def queue_name
    :assign_delegate
  end

  attr_accessor :pids, :grantor, :grantee, :grantor_pid, :grantee_pid

  def initialize(pids)
    if pids[:grantor].nil?
      raise GrantError.new("No Grantor found.")
    end
    if pids[:grantee].nil?
      raise GrantError.new("No Grantee found.")
    end
    @grantor_pid = pids[:grantor]
    @grantee_pid = pids[:grantee]
  end

  def run

     grantor = ActiveFedora::Base.find(@grantor_pid, cast: true)
     grantee = ActiveFedora::Base.find(@grantee_pid, cast: true)

     type = [Article, Dataset, Document, GenericWork, Image]
     type.each do |klass|
       klass.find_each('edit_access_person_ssim' => grantor.email) do |work|
           work.edit_users += [grantee.email]
           work.save!
           grantee = ActiveFedora::Base.find(grantee.pid, cast: true)
           grantee.work_ids += [work.pid]
           grantee.save!

           if work.respond_to?(:generic_files)
	     work.generic_files.each do |file|
               file.edit_users = work.edit_users
               file.edit_groups = work.edit_groups
               file.save!
             end    
           end
       end
     end
  end
end
